#!/usr/bin/env python3
"""Export exact per-entry Lean import closures and their manuscript evidence.

This is a local packaging/static-verification tool. It neither invokes Palomar
nor treats an archive or source scan as compilation or protected verification.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from urllib.parse import unquote, urlsplit
import zipfile


ROOT = Path(__file__).resolve().parents[1]
MARKER = "PALOMAR_PACKAGE_MANIFEST.json"
PIPELINE = "14aa8d6b3c2f14a8540605e37144560b9a00e7e7"
ENTRIES = {
    "paper1": ("Palomar/PaperOne", "papers/paper1", 46, 21,
               "Hidden Hodge targets and discrete closest vectors"),
    "paper3-coding": ("Palomar/PaperThree", "papers/proximity-prize", 52, 36,
                      "Capacity-radius proximity: coding entry"),
    "paper3-application": ("Palomar/PaperThree/Application", "papers/proximity-prize", 22, 10,
                           "Capacity-radius proximity: original-cochain application"),
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def code_only(source):
    """Mask Lean comments/strings while retaining source positions/newlines."""
    result = list(source)
    i, depth, string, line_comment = 0, 0, False, False
    while i < len(source):
        ch, pair = source[i], source[i:i + 2]
        if line_comment:
            if ch == "\n":
                line_comment = False
            else:
                result[i] = " "
            i += 1
        elif depth:
            if pair == "/-":
                result[i:i + 2] = [" ", " "]
                depth += 1
                i += 2
            elif pair == "-/":
                result[i:i + 2] = [" ", " "]
                depth -= 1
                i += 2
            else:
                if ch != "\n":
                    result[i] = " "
                i += 1
        elif string:
            if ch == "\\" and i + 1 < len(source):
                result[i] = " "
                if source[i + 1] != "\n":
                    result[i + 1] = " "
                i += 2
            else:
                if ch != "\n":
                    result[i] = " "
                if ch == '"':
                    string = False
                i += 1
        elif pair == "--":
            result[i:i + 2] = [" ", " "]
            line_comment = True
            i += 2
        elif pair == "/-":
            result[i:i + 2] = [" ", " "]
            depth = 1
            i += 2
        elif ch == '"':
            result[i] = " "
            string = True
            i += 1
        else:
            i += 1
    if depth or string:
        raise ValueError("Unterminated Lean comment/string")
    return "".join(result)


def imports(raw):
    result = []
    for line in code_only(raw).splitlines():
        match = re.match(r"^\s*(?:(?:public|private|meta)\s+)*import\s+(?:all\s+)?(.+?)\s*$", line)
        if match:
            result.extend(match[1].split())
    return result


def local_modules():
    return {".".join(p.relative_to(ROOT / "lean").with_suffix("").parts): p
            for p in (ROOT / "lean").rglob("*.lean")
            if p.name != "lakefile.lean" and
            not any(part.startswith(".") for part in p.relative_to(ROOT / "lean").parts)}


def closure(roots, modules):
    reached, todo = set(), list(roots)
    local_roots = {name.split(".")[0] for name in modules}
    while todo:
        name = todo.pop()
        if name in reached:
            continue
        if name not in modules:
            raise ValueError(f"Missing local root: {name}")
        reached.add(name)
        for target in imports(modules[name].read_text()):
            if target in modules:
                todo.append(target)
            elif target.split(".")[0] in local_roots:
                raise ValueError(f"Unresolved local import {target} in {name}")
    return reached


def source_bytes(relative):
    path = ROOT / relative
    if not path.is_relative_to(ROOT) or not path.resolve().is_relative_to(ROOT):
        raise ValueError(f"Source outside repository: {relative}")
    current = ROOT
    for part in relative.parts:
        current /= part
        if current.is_symlink():
            raise ValueError(f"Refusing source symlink: {relative}")
    return path.read_bytes()


def generated_lakefile(selected, config):
    original = source_bytes(Path("lean/lakefile.lean")).decode()
    package = re.search(r"(?ms)^package\s+.+?(?=^@\[default_target\])", original)
    dependency = re.search(r'(?ms)^require mathlib from git\s+"[^"\n]+"\s+@\s+"[0-9a-f]{40}"\s*$', original)
    if not package or not dependency:
        raise ValueError("Unexpected canonical Lake configuration; review the generator")
    groups = {}
    for name in sorted(selected):
        if name not in (config["challenge_module"], config["solution_module"]):
            groups.setdefault(name.split(".")[0], []).append(name)
    chunks = ["import Lake\nopen Lake DSL\n", package[0].strip()]
    for family, names in sorted(groups.items()):
        roots = ",\n    ".join("`" + name for name in names)
        chunks.append(f'lean_lib {family} where\n  srcDir := "."\n  roots := #[{roots}]')
    chunks.append('@[default_target]\nlean_lib Palomar where\n  srcDir := "."\n'
                  f'  roots := #[`{config["solution_module"]}]')
    chunks.append('lean_lib PalomarChallenge where\n  srcDir := "."\n'
                  f'  roots := #[`{config["challenge_module"]}]')
    chunks.append(dependency[0].strip())
    return ("\n\n".join(chunks) + "\n").encode()


def workflow(entry):
    base = ENTRIES[entry][0]
    return f"""name: Protected Palomar preflight

on:
  workflow_dispatch:
    inputs:
      request_id:
        description: Fresh 12-character lowercase alphanumeric request identifier
        required: true
        type: string

permissions:
  contents: read

jobs:
  preflight:
    uses: PalomarRegistry/PalomarSubmission/.github/workflows/submission.yml@{PIPELINE}
    with:
      repository: ${{{{ github.repository }}}}
      commit: ${{{{ github.sha }}}}
      pipeline_commit: {PIPELINE}
      request_id: ${{{{ inputs.request_id }}}}
      mode: full
      execution_profile: palomar-standard-v1
      options: '{{"project_path":"lean","comparator_config_path":"lean/{base}/comparator.json","formalization_metadata_path":"lean/{base}/formalization.yaml","authorization_relationship":"I am a responsible author or maintainer"}}'
""".encode()


def rewrite_readme(raw, relative, inventory):
    """Keep the reviewed crosswalk with usable local manuscript/licence links."""
    changes = []

    def replace(match):
        label, target = match.groups()
        parsed = urlsplit(target)
        if parsed.scheme or parsed.netloc:
            prefix = "/what-social-construct/homotopical-encrypt/blob/"
            if parsed.netloc == "github.com" and parsed.path.startswith(prefix):
                parts = parsed.path[len(prefix):].split("/", 1)
                if len(parts) == 2 and parts[1] in inventory:
                    replacement = Path(os.path.relpath(ROOT / parts[1], ROOT / relative.parent)).as_posix()
                    changes.append({"original": target, "replacement": replacement,
                                    "reason": "Use bundled manuscript; metadata retains immutable upstream provenance"})
                    return f"[{label}]({replacement})"
            return match[0]
        if not parsed.path:
            return match[0]
        path = (ROOT / relative.parent / unquote(parsed.path)).resolve()
        if not path.is_relative_to(ROOT):
            raise ValueError(f"README link escapes source repository: {target}")
        resolved = path.relative_to(ROOT).as_posix()
        if resolved in inventory:
            return match[0]
        if path.name == "LICENSE":
            replacement = Path(os.path.relpath(ROOT / "LICENSE", ROOT / relative.parent)).as_posix()
            changes.append({"original": target, "replacement": replacement,
                            "reason": "Correct relative link to bundled root licence"})
            return f"[{label}]({replacement})"
        if not path.exists():
            raise ValueError(f"Broken source README link: {target}")
        replacement = f"{label} (separately packaged companion; upstream path `{resolved}`)"
        changes.append({"original": target, "replacement": replacement,
                        "reason": "Companion excluded; upstream repository is private"})
        return replacement

    return re.sub(r"(?<!!)\[([^\]]+)\]\(([^)]+)\)", replace, raw), changes


def root_readme(entry, config, checkpoint, selected_count, challenge_count, solution_count):
    base, paper, targets, main, title = ENTRIES[entry]
    application_note = (
        "Paper 3 has two separately packaged configurations for the same manuscript. "
        "The companion is outside this package; the entry crosswalk identifies it "
        "as separately packaged. Metadata's companion_config is an upstream-context "
        "path to that separate entry, rather than a bundled file.\n\n"
        if entry != "paper1" else "")
    return f"""# {title}

This local release candidate contains one selected formalization entry and its
actual Lean proof/import closure. Its [scope and statement crosswalk](lean/{base}/README.md)
and [metadata](lean/{base}/formalization.yaml) state the hypotheses and limitations.
The [configuration](lean/{base}/comparator.json) selects **{targets} declarations**:
{main} manuscript-facing and {targets - main} supporting. These are coverage counts.

The canonical [manuscript PDF]({paper}/main.pdf) and [TeX source]({paper}/main.tex)
are unchanged contextual evidence. The selected formalization covers the stated
groups, rather than every claim or future direction in the full manuscript.
{application_note}
The upstream development repository is currently private. Immutable upstream
URLs in the unchanged metadata record provenance; use the bundled manuscript
and local crosswalk for review navigation.

The source checkpoint is `{checkpoint}`. The package contains {selected_count}
local Lean modules: Challenge's closure has {challenge_count}, Solution's has
{solution_count}. The files retain their original module paths and source bytes.
The generated Lake file defaults to the selected Solution; Challenge is a
separate explicit build. No other paper's entry, plans, archives, runtime or
dependency/build caches are included. [MIT licence](LICENSE).

From `lean/`, reproduce the entry checks with the pinned toolchain:

```sh
lake exe cache get
LEAN_NUM_THREADS=1 lake build {config['challenge_module']}
LEAN_NUM_THREADS=1 lake build
LEAN_NUM_THREADS=1 lake comparator --config {base}/comparator.json
```

The last command requires the supported Linux sandbox. The development entry
passed local macOS comparison and Lean/NanoDa replay; that diagnostic disabled
the Linux sandbox. **This slim package has not yet passed protected preflight.**
Packaging/static checks do not substitute for a clean build, definition
comparison, dependency audit or kernel replay on these exact packaged inputs.

The [manual-only preflight workflow](.github/workflows/palomar-preflight.yml)
pins verifier pipeline `{PIPELINE}` and selects this entry at `github.sha`.
It is prepared for a separately authorized immutable public release; the local
exporter performs no push, upload, workflow dispatch or registry submission.

[Packaging manifest]({MARKER}) records exact source copies, generated files,
README navigation rewrites, source-input hashes and selected-input changes
relative to the source checkpoint. The copied metadata's development validation
record is historical evidence, rather than a protected result for this package.
""".encode()


def package_files(entry, checkpoint, modules):
    base, paper, targets, _, _ = ENTRIES[entry]
    config_path = Path("lean") / base / "comparator.json"
    config = json.loads(source_bytes(config_path))
    if len(config["theorem_names"]) != targets:
        raise ValueError(f"Unexpected target count for {entry}; update the scoped description")
    challenges = closure([config["challenge_module"]], modules)
    solutions = closure([config["solution_module"]], modules)
    selected = challenges | solutions
    if challenges != {config["challenge_module"]}:
        raise ValueError("Independent Challenge imports project implementation")
    if config["challenge_module"] in solutions:
        raise ValueError("Solution imports Challenge")
    paths = {Path("LICENSE"), Path("lean/lean-toolchain"), Path("lean/lake-manifest.json"),
             config_path, Path("lean") / base / "formalization.yaml"}
    paths.update(modules[name].relative_to(ROOT) for name in selected)
    paths.update(p.relative_to(ROOT) for p in (ROOT / paper).rglob("*")
                 if p.is_file() and p.suffix in {".tex", ".bib", ".pdf", ".sty", ".cls", ".png", ".jpg", ".eps"})
    contents = {p.as_posix(): source_bytes(p) for p in sorted(paths)}
    readme_path = Path("lean") / base / "README.md"
    original_readme = source_bytes(readme_path)
    readme, rewrites = rewrite_readme(original_readme.decode(), readme_path, contents)
    contents[readme_path.as_posix()] = readme.encode()
    contents["lean/lakefile.lean"] = generated_lakefile(selected, config)
    contents["README.md"] = root_readme(entry, config, checkpoint, len(selected), len(challenges), len(solutions))
    contents[".github/workflows/palomar-preflight.yml"] = workflow(entry)
    contents[".gitignore"] = b"lean/.lake/\n.DS_Store\n*.aux\n*.bbl\n*.blg\n*.fdb_latexmk\n*.fls\n*.log\n*.out\n*.toc\n*.synctex.gz\n"
    inputs = {p.as_posix(): sha(source_bytes(p)) for p in paths | {readme_path, Path("lean/lakefile.lean"), Path(__file__).relative_to(ROOT)}}
    dirty = []
    for relative, expected in sorted(inputs.items()):
        committed = subprocess.run(["git", "show", f"{checkpoint}:{relative}"], cwd=ROOT, capture_output=True)
        if committed.returncode or sha(committed.stdout) != expected:
            dirty.append(relative)
    manifest = {
        "format_version": 1, "entry": entry, "source_checkpoint": checkpoint,
        "scope": "one selected entry, actual local Lean proof closure and corresponding manuscript evidence",
        "challenge_module": config["challenge_module"], "solution_module": config["solution_module"],
        "comparator_config": config_path.as_posix(),
        "metadata": f"lean/{base}/formalization.yaml", "configured_theorems": targets,
        "challenge_closure": sorted(challenges), "solution_closure": sorted(solutions),
        "local_modules": sorted(selected), "source_input_sha256": dict(sorted(inputs.items())),
        "selected_inputs_changed_from_checkpoint": dirty,
        "byte_identical_source_copies": sorted(p.as_posix() for p in paths),
        "documentation_transformations": [{"file": readme_path.as_posix(), "navigation_rewrites": rewrites}],
        "generated_files": ["README.md", ".gitignore", "lean/lakefile.lean", ".github/workflows/palomar-preflight.yml"],
        "default_build": config["solution_module"], "pipeline_commit": PIPELINE,
        "verification": {"static_package_check": "see --verify", "protected_linux_preflight": "NOT RUN",
                         "clean_package_build": "NOT RUN by exporter", "publication_or_submission": "NOT PERFORMED"},
        "sha256": {p: sha(data) for p, data in sorted(contents.items())},
    }
    contents[MARKER] = (json.dumps(manifest, indent=2) + "\n").encode()
    return contents, manifest


def safe_destination(path):
    path = path.absolute()
    for ancestor in (path, *path.parents):
        if ancestor.is_symlink():
            raise ValueError(f"Refusing destination with a symlink: {ancestor}")
    path = path.resolve()
    if path == ROOT or ROOT.is_relative_to(path):
        raise ValueError("Destination must not replace repository or ancestor")
    if path.is_relative_to(ROOT) and not path.is_relative_to(ROOT / "output"):
        raise ValueError("An in-repository destination must be under output/")
    return path


def verify(destination):
    manifest = json.loads((destination / MARKER).read_text())
    if manifest.get("entry") not in ENTRIES or manifest.get("format_version") != 1:
        raise ValueError("Unrecognized package manifest")
    actual = {p.relative_to(destination).as_posix() for p in destination.rglob("*") if p.is_file()}
    if actual != set(manifest["sha256"]) | {MARKER}:
        raise ValueError("Package inventory differs from manifest")
    for relative, expected in manifest["sha256"].items():
        path = destination / relative
        if Path(relative).is_absolute() or not path.resolve().is_relative_to(destination):
            raise ValueError(f"Package inventory escapes destination: {relative}")
        if path.is_symlink() or sha(path.read_bytes()) != expected:
            raise ValueError(f"Package content differs: {relative}")
        if {".git", ".lake", ".aws", ".codex", ".agents", ".DS_Store"} & set(Path(relative).parts):
            raise ValueError(f"Disallowed package path: {relative}")
    for relative in manifest["byte_identical_source_copies"]:
        expected = manifest["source_input_sha256"][relative]
        if manifest["sha256"][relative] != expected or sha(source_bytes(Path(relative))) != expected:
            raise ValueError(f"Packaged source differs from canonical input: {relative}")
    local = {".".join(p.relative_to(destination / "lean").with_suffix("").parts): p
             for p in (destination / "lean").rglob("*.lean") if p.name != "lakefile.lean"}
    if set(local) != set(manifest["local_modules"]):
        raise ValueError("Packaged Lean modules differ from proof closure")
    if set(local) != set(manifest["challenge_closure"]) | set(manifest["solution_closure"]):
        raise ValueError("Package contains modules outside the selected import closures")
    for root, key in [(manifest["challenge_module"], "challenge_closure"), (manifest["solution_module"], "solution_closure")]:
        if closure([root], local) != set(manifest[key]):
            raise ValueError(f"Packaged import closure differs: {root}")
    for name, path in local.items():
        code = code_only(path.read_text())
        if not re.match(r"\s*module\b", code) or not re.search(r"@\[\s*expose\s*\]\s+public\s+section\b", code):
            raise ValueError(f"Missing new module/public-section header: {name}")
        if len(path.read_text().splitlines()) > 10000:
            raise ValueError(f"Lean module exceeds source size cap: {name}")
        if name != manifest["challenge_module"] and re.search(r"\b(sorry|admit|sorryAx)\b", code):
            raise ValueError(f"Implementation proof hole: {name}")
        if re.search(r"\bnative_decide\b|^\s*(?:(?:public|private|protected)\s+)*axiom\s", code, re.M):
            raise ValueError(f"Native/custom axiom in selected closure: {name}")
    challenge = local[manifest["challenge_module"]]
    if len(challenge.read_text().splitlines()) > 1000 or challenge.stat().st_size > 100 * 1024:
        raise ValueError("Challenge exceeds size cap")
    links = 0
    for path in destination.rglob("*.md"):
        for target in re.findall(r"(?<!!)\[[^\]]+\]\(([^)]+)\)", path.read_text()):
            parsed = urlsplit(target)
            if parsed.scheme or parsed.netloc or not parsed.path:
                continue
            resolved = (path.parent / unquote(parsed.path)).resolve()
            if not resolved.is_relative_to(destination) or not resolved.exists():
                raise ValueError(f"Broken local Markdown link in {path}: {target}")
            links += 1
    archive = destination.with_suffix(".zip")
    if archive.is_symlink():
        raise ValueError("Refusing archive symlink")
    with zipfile.ZipFile(archive) as bundle:
        if bundle.testzip() is not None or set(bundle.namelist()) != {f"{destination.name}/{p}" for p in actual}:
            raise ValueError("ZIP inventory/integrity differs")
        for relative in actual:
            if bundle.read(f"{destination.name}/{relative}") != (destination / relative).read_bytes():
                raise ValueError(f"ZIP content differs: {relative}")
        if any(info.date_time != (1980, 1, 1, 0, 0, 0) for info in bundle.infolist()):
            raise ValueError("Non-deterministic ZIP timestamps")
    return {"entry": manifest["entry"], "files_including_manifest": len(actual), "lean_modules": len(local),
            "challenge_closure": len(manifest["challenge_closure"]), "solution_closure": len(manifest["solution_closure"]),
            "local_markdown_links": links, "zip_bytes": archive.stat().st_size, "zip_sha256": sha(archive.read_bytes()),
            "selected_inputs_changed_from_checkpoint": manifest["selected_inputs_changed_from_checkpoint"],
            "static_verification": "PASS", "protected_linux_preflight": "NOT RUN"}


def stage(destination, contents, entry, refresh):
    archive = destination.with_suffix(".zip")
    if archive.is_symlink():
        raise ValueError("Refusing archive symlink")
    if destination.exists():
        marker = destination / MARKER
        if not refresh or not marker.is_file() or json.loads(marker.read_text()).get("entry") != entry:
            raise ValueError("Existing destination requires --refresh and its matching managed manifest")
    elif archive.exists():
        raise ValueError("Refusing to replace archive without managed source folder")
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="palomar-stage-", dir=destination.parent) as tmp:
        tree = Path(tmp) / destination.name
        tree.mkdir()
        for relative, data in contents.items():
            target = tree / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
        if destination.exists():
            shutil.rmtree(destination)
        shutil.move(str(tree), destination)
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as bundle:
        for path in sorted(destination.rglob("*")):
            if path.is_file():
                info = zipfile.ZipInfo(f"{destination.name}/{path.relative_to(destination).as_posix()}",
                                       date_time=(1980, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = 0o100644 << 16
                bundle.writestr(info, path.read_bytes())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--entry", choices=["all", *ENTRIES], default="all")
    parser.add_argument("--output-dir", type=Path, default=ROOT / "output/palomar-slim")
    parser.add_argument("--refresh", action="store_true")
    parser.add_argument("--verify", action="store_true", help="Verify existing trees/ZIPs without replacing files")
    args = parser.parse_args()
    output = safe_destination(args.output_dir)
    selected_entries = list(ENTRIES) if args.entry == "all" else [args.entry]
    checkpoint = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    modules = local_modules()
    results = []
    for entry in selected_entries:
        destination = safe_destination(output / entry)
        if not args.verify:
            contents, _ = package_files(entry, checkpoint, modules)
            stage(destination, contents, entry, args.refresh)
        results.append(verify(destination))
    print(json.dumps({"source_checkpoint": checkpoint, "output_directory": str(output), "packages": results}, indent=2))


if __name__ == "__main__":
    main()
