module

public import TCB.PrimitiveChecks

@[expose] public section

/-!
# Local views of one cell directory

Every entry of a patch names the same digest as the authoritative lookup.
Restriction filters cell identifiers and gluing combines two patches checked
against the same authority. The gluing law concerns the resulting lookup
function, so shared entries may occur in both input lists.
-/

set_option autoImplicit false

namespace HomotopicalEncryption.Protocol.Storage.CellDirectory

variable {Cell : Type*} [BEq Cell]

/-- A local directory view whose entries agree with one authoritative directory. -/
structure Patch (authority : List (Cell × TCB.Hash32)) where
  entries : List (Cell × TCB.Hash32)
  bound : ∀ entry ∈ entries, authority.lookup entry.1 = some entry.2

namespace Patch

variable {authority : List (Cell × TCB.Hash32)}

/-- Validate every supplied entry against the authoritative lookup. -/
def check (authority entries : List (Cell × TCB.Hash32)) : Option (Patch authority) :=
  if checked : entries.all (fun entry => decide (authority.lookup entry.1 = some entry.2)) then
    some ⟨entries, by simpa only [List.all_eq_true, decide_eq_true_eq] using checked⟩
  else none

theorem check_isSome_iff (authority entries : List (Cell × TCB.Hash32)) :
    (check authority entries).isSome ↔
      ∀ entry ∈ entries, authority.lookup entry.1 = some entry.2 := by
  have test :
      entries.all (fun entry => decide (authority.lookup entry.1 = some entry.2)) = true ↔
        ∀ entry ∈ entries, authority.lookup entry.1 = some entry.2 := by
    simp only [List.all_eq_true, decide_eq_true_eq]
  unfold check
  split
  · rename_i checked
    exact ⟨fun _ => test.mp checked, fun _ => rfl⟩
  · rename_i failed
    exact ⟨fun hit => Bool.noConfusion hit, fun bound => (failed (test.mpr bound)).elim⟩

/-- A successful check keeps the supplied entries. -/
theorem entries_of_check_eq_some {entries : List (Cell × TCB.Hash32)} {patch : Patch authority}
    (checked : check authority entries = some patch) : patch.entries = entries := by
  unfold check at checked
  split at checked
  · cases Option.some.inj checked
    rfl
  · contradiction

/-- Resolve the digest locally within this patch. -/
def resolve (patch : Patch authority) (cell : Cell) : Option TCB.Hash32 :=
  patch.entries.lookup cell

/-- A local hit names the authoritative digest for that cell. -/
theorem resolve_sound [LawfulBEq Cell] (patch : Patch authority) {cell : Cell}
    {digest : TCB.Hash32} (found : patch.resolve cell = some digest) :
    authority.lookup cell = some digest := by
  obtain ⟨before, after, entries, _⟩ := List.lookup_eq_some_iff.mp found
  apply patch.bound (cell, digest)
  rw [entries]
  simp

/-- Two patches of the same authority agree wherever both name a cell. -/
theorem overlap_agrees [LawfulBEq Cell] (left right : Patch authority) {cell : Cell}
    {first second : TCB.Hash32} (leftFound : left.resolve cell = some first)
    (rightFound : right.resolve cell = some second) : first = second :=
  Option.some.inj ((left.resolve_sound leftFound).symm.trans (right.resolve_sound rightFound))

/-- Keep only the entries at cells selected by the smaller patch. -/
def restrict (patch : Patch authority) (keep : Cell → Bool) : Patch authority where
  entries := patch.entries.filter fun entry => keep entry.1
  bound entry present := patch.bound entry (List.mem_filter.mp present).1

/-- Restricted lookup retains the original answer at every selected cell. -/
@[simp] theorem resolve_restrict [LawfulBEq Cell] (patch : Patch authority)
    (keep : Cell → Bool) (cell : Cell) :
    (patch.restrict keep).resolve cell = if keep cell then patch.resolve cell else none := by
  change (patch.entries.filter fun entry => keep entry.1).lookup cell =
    if keep cell then patch.entries.lookup cell else none
  generalize patch.entries = entries
  induction entries with
  | nil => simp
  | cons entry entries ih =>
    rcases entry with ⟨key, digest⟩
    cases same : cell == key with
    | false => cases kept : keep key <;> simp [List.lookup_cons, same, kept, ih]
    | true =>
      have equal : cell = key := beq_iff_eq.mp same
      subst key
      cases kept : keep cell <;> simp [kept, ih]

/-- Combine the local views over their union. Any shared entries agree. -/
def glue (left right : Patch authority) : Patch authority where
  entries := left.entries ++ right.entries
  bound entry present := (List.mem_append.mp present).elim (left.bound entry) (right.bound entry)

@[simp] theorem resolve_glue (left right : Patch authority) (cell : Cell) :
    (left.glue right).resolve cell = (left.resolve cell).or (right.resolve cell) :=
  List.lookup_append

/-- Every local hit survives on the union, including hits in shared cells. -/
theorem resolve_glue_eq_some_iff [LawfulBEq Cell] (left right : Patch authority) (cell : Cell)
    (digest : TCB.Hash32) :
    (left.glue right).resolve cell = some digest ↔
      left.resolve cell = some digest ∨ right.resolve cell = some digest := by
  rw [resolve_glue, Option.or_eq_some_iff]
  constructor
  · rintro (leftFound | ⟨_, rightFound⟩)
    · exact Or.inl leftFound
    · exact Or.inr rightFound
  · rintro (leftFound | rightFound)
    · exact Or.inl leftFound
    · cases leftFound : left.resolve cell with
      | none => exact Or.inr ⟨rfl, rightFound⟩
      | some first =>
        exact Or.inl (congrArg some (overlap_agrees left right leftFound rightFound))

/-- The two patches determine the unique lookup function on their union. -/
theorem resolve_glue_unique (left right : Patch authority) (candidate : Cell → Option TCB.Hash32)
    (extendsLeft : ∀ cell digest, left.resolve cell = some digest → candidate cell = some digest)
    (extendsRight : ∀ cell digest, right.resolve cell = some digest → candidate cell = some digest)
    (absent : ∀ cell, left.resolve cell = none → right.resolve cell = none → candidate cell = none) :
    candidate = (left.glue right).resolve := by
  funext cell
  rw [resolve_glue]
  cases leftFound : left.resolve cell with
  | some digest => exact extendsLeft cell digest leftFound
  | none =>
    cases rightFound : right.resolve cell with
    | some digest => exact extendsRight cell digest rightFound
    | none => exact absent cell leftFound rightFound

end Patch

end HomotopicalEncryption.Protocol.Storage.CellDirectory
