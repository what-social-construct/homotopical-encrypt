#!/usr/bin/env python3
"""Stage an allowlisted Lean/manuscript review package without Git history."""

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import zipfile


ROOT = Path(__file__).resolve().parents[1]
MARKER = "PUBLIC_REVIEW_MANIFEST.json"
DOCS = (
    "CATEGORICAL_ARCHITECTURE", "COCHAIN_PROXIMITY_TRACE", "PAPER_OUTLINE",
    "PROTOCOL_PARITY_QUEUE", "PROXIMITY", "PROXIMITY_ASSUMPTIONS",
    "PROXIMITY_PAPER_OUTLINE", "PROXIMITY_NOVELTY_COMPARISON", "MATH_STORAGE_VALIDATION",
    "SEMANTIC_OWNERSHIP", "SEMANTIC_PARITY_QUEUE", "PALOMAR_SUBMISSION_PLAN",
)
WORKFLOW = """name: Lean and manuscript review
on: [push, pull_request, workflow_dispatch]
jobs:
  lean:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install elan
        run: |
          curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --default-toolchain none
          echo "$HOME/.elan/bin" >> $GITHUB_PATH
      - uses: actions/cache@v4
        with:
          path: |
            lean/.lake
            ~/.elan/toolchains
          key: ${{ runner.os }}-lean-${{ hashFiles('lean/lean-toolchain', 'lean/lakefile.lean', 'lean/lake-manifest.json') }}
      - name: Fetch pinned Mathlib cache
        working-directory: lean
        run: lake exe cache get
      - name: Build proofs and transition examples
        working-directory: lean
        run: lake build && lake build Protocol.Core Protocol.Ledger.Examples Protocol.Ledger.EvidenceExamples Protocol.Storage.Core Protocol.Storage.Examples Protocol.Storage.AnchorExamples Protocol.Storage.CanonicalRS Protocol.Storage.CanonicalThreeLevel Protocol.Storage.CanonicalCalibration HCP.AxisFamily TCB.HCPAxisFamily
  manuscripts:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install TeX
        run: sudo apt-get update && sudo apt-get install -y latexmk texlive-latex-extra texlive-fonts-recommended lmodern
      - name: Build Paper 1
        working-directory: papers/paper1
        run: latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
      - name: Build Paper 3
        working-directory: papers/proximity-prize
        run: latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
"""


def source_files():
    paths = [ROOT / name for name in ("LICENSE", "PUBLIC_REVIEW.md", "SEMANTIC-PARITY.md")]
    paths += [ROOT / "docs" / f"{name}.md" for name in DOCS]
    paths.append(Path(__file__).resolve())
    scanned_roots = []
    for folder, extensions in (("lean", {".lean", ".md"}),
                               ("papers/paper1", {".tex", ".bib", ".md", ".pdf"}),
                               ("papers/proximity-prize", {".tex", ".bib", ".md", ".pdf"}),
                               ("papers/paper2", {".tex", ".bib", ".md", ".pdf"})):
        scanned_roots.append(ROOT / folder)
        for path in scanned_roots[-1].rglob("*"):
            relative = path.relative_to(ROOT)
            if any(part.startswith(".") for part in relative.parts):
                continue
            if path.is_symlink() or (path.is_file() and path.suffix in extensions):
                paths.append(path)
    paths += [ROOT / "lean" / name for name in
              ("lean-toolchain", "lake-manifest.json")]
    for path in sorted(set(paths + scanned_roots)):
        if not path.is_relative_to(ROOT) or not path.resolve().is_relative_to(ROOT):
            raise ValueError(f"Refusing source outside repository: {path}")
        current = ROOT
        for part in path.relative_to(ROOT).parts:
            current /= part
            if current.is_symlink():
                raise ValueError(f"Refusing source symlink: {current.relative_to(ROOT)}")
    return sorted(set(paths))


def stage(destination: Path, refresh: bool):
    destination = destination.resolve()
    if ROOT == destination or ROOT.is_relative_to(destination):
        raise ValueError("Destination must not replace the repository or its parent")
    if any(destination.is_relative_to(ROOT / folder)
           for folder in ("lean", "papers", "docs", "scripts", ".git")):
        raise ValueError("Destination must be outside source and Git directories")
    if destination.exists() and not (refresh and (destination / MARKER).is_file()):
        raise ValueError("Destination exists; --refresh requires an exporter-created manifest")
    archive = destination.with_suffix(".zip")
    if archive.exists() and not (refresh and (destination / MARKER).is_file()):
        raise ValueError("Refusing to replace an archive without its managed source folder")
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="review-stage-", dir=destination.parent) as tmp:
        tree = Path(tmp) / destination.name
        tree.mkdir()
        for source in source_files():
            target = tree / source.relative_to(ROOT)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
        shutil.copyfile(ROOT / "PUBLIC_REVIEW.md", tree / "README.md")
        workflow = tree / ".github/workflows/review.yml"
        workflow.parent.mkdir(parents=True)
        workflow.write_text(WORKFLOW)
        (tree / ".gitignore").write_text(
            "lean/.lake/\n.DS_Store\n*.aux\n*.bbl\n*.blg\n*.fdb_latexmk\n"
            "*.fls\n*.log\n*.out\n*.toc\n*.synctex.gz\noutput/\n")
        checkpoint = subprocess.run(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True,
            capture_output=True, check=False,
        ).stdout.strip() or None
        inventory = {
            str(path.relative_to(tree)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(tree.rglob("*")) if path.is_file()
        }
        (tree / MARKER).write_text(json.dumps({
            "format_version": 1,
            "scope": "current Lean sources, corresponding manuscripts and selected documentation",
            "source_checkpoint": checkpoint,
            "source": "working tree including uncommitted additions; no Git history",
            "validation": "see PUBLIC_REVIEW.md; source presence does not assert build success",
            "sha256": inventory,
        }, indent=2) + "\n")
        if destination.exists():
            shutil.rmtree(destination)
        shutil.move(str(tree), destination)
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as bundle:
        for path in sorted(destination.rglob("*")):
            if path.is_file():
                info = zipfile.ZipInfo(str(Path(destination.name) / path.relative_to(destination)),
                                       date_time=(1980, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                bundle.writestr(info, path.read_bytes())
    return destination, archive, len(inventory)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path,
                        default=ROOT / "output/public-review/lean-manuscripts-review")
    parser.add_argument("--refresh", action="store_true")
    args = parser.parse_args()
    destination, archive, count = stage(args.output, args.refresh)
    print(f"Staged {count} files plus manifest: {destination}")
    print(f"ZIP: {archive}")


if __name__ == "__main__":
    main()
