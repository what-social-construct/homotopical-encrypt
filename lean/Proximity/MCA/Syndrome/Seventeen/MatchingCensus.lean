module

public import Proximity.MCA.Syndrome.Seventeen.Coordinates
public import Proximity.MCA.Syndrome.Seventeen.Domain
public import Mathlib.Data.Finset.Card

@[expose] public section

/-!
# Perfect-matching incidence charts over `𝔽₁₇`

Order the eight sites by their original indices. Pair the least remaining
site with one of the other remaining sites, and repeat. The three free
choices have sizes seven, five, and three, and the last pair is forced.

The table proposes a basis and reconstruction certificate for each
kernel of the four linear Plücker equations. Lean checks these against
the original rows, so the proof is independent of how the table was computed.
-/

set_option autoImplicit false
set_option maxRecDepth 8192
set_option maxHeartbeats 4000000

namespace ProximityCoding.MCA.Syndrome.Seventeen.MatchingCensus

open scoped Matrix

local notation "K" => ZMod 17

local instance : Fact (Nat.Prime 17) := ⟨prime17⟩

/-- Partner indices after removing the least remaining site at each step. -/
abbrev MatchingChoice := Fin 7 × Fin 5 × Fin 3

def choosePair {n : ℕ} (sites : Fin (n + 2) → Fin 8) (j : Fin (n + 1)) :
    (Fin 8 × Fin 8) × (Fin n → Fin 8) :=
  ((sites 0, sites j.succ), fun i => sites (j.succAbove i).succ)

/-- The four pairs in increasing order of their least site indices. -/
def matching (choice : MatchingChoice) : Fin 4 → Fin 8 × Fin 8 :=
  let first := choosePair (fun i : Fin 8 => i) choice.1
  let second := choosePair first.2 choice.2.1
  let third := choosePair second.2 choice.2.2
  ![first.1, second.1, third.1, (third.2 0, third.2 1)]

theorem matchingChoice_card : Fintype.card MatchingChoice = 105 := by decide

/-- Every proposed matching uses eight distinct endpoints. -/
theorem matching_endpoints_nodup (choice : MatchingChoice) :
    ((List.ofFn (matching choice)).flatMap fun pair => [pair.1, pair.2]).Nodup := by
  revert choice
  decide

theorem matching_card :
    ((Finset.univ : Finset MatchingChoice).image (fun choice => List.ofFn (matching choice))).card =
      105 := by decide

/-- The four incidence equations, using the original quotient minors. -/
def constraints (choice : MatchingChoice) : Matrix (Fin 4) (Fin 6) K :=
  fun i => quotientMinors (site (matching choice i).1) (site (matching choice i).2)

/-- Proposed row reductions in lexicographic order of the partner indices.
The first number has the pivot columns as its set bits. The second packs
the augmented reduction `[R | T]`, with `R = T * constraints`, into
forty base-17 digits in row-major order, least significant digit first.
The identities in `kernel_certificate` check the data against the
original quotient minors. -/
def reductionTable : Array (ℕ × ℕ) := #[
  (23, 11850795255834047968612743942054982634264971342062),
  (15, 11001281336204060633900476262413875364378717408642),
  (15, 13334853010539403701557856792618196131117701527264),
  (15, 14959847073223173850029181640603437448723119156386),
  (15, 10305755198622826876591319532302890436170440022478),
  (15, 9776482750652035653769385338768926283800163639133),
  (15, 13850863896215206345998345812843582173636389393515),
  (15, 12395469879490743749180279136173922458453053084177),
  (15, 12993754597048998237657490470883581204017578031287),
  (15, 731781108879804142380461713051481075003339910123),
  (15, 11824411774097784707030293105488482289388461282927),
  (15, 4607013676665955329939865419574613576566425927439),
  (15, 13902126106327086652554360780874744188820816550828),
  (23, 10548768377321394722615745319646608168393541004495),
  (11, 1300933324845070420364605262991049661350330095349),
  (15, 7925561731843436742794993578124153865348240513862),
  (23, 8832028720345867415482143303217943428178970197946),
  (23, 16509089579169405763218482899758408178470228738299),
  (15, 13057458546361687689198065247451633031886286112619),
  (15, 2409927491329571792988776705916824112984644155544),
  (15, 12965901141849309330330397786309661596250295810445),
  (15, 3368926840093133991184773541175929993407261891906),
  (15, 2202352117639691348312692470661365304136086173140),
  (15, 1829177954741096314058230902774824804941962886267),
  (15, 13699394395247747191810514155538409401023081025521),
  (15, 9667839083312106386618392231750831064154822099144),
  (15, 12993745700811401041086918334693413964144296704719),
  (15, 2506324452511653111667668974951128271831279985985),
  (23, 13173483318555546391523418126288257927187408754641),
  (23, 8241986714889270621391329983070393873688753876556),
  (15, 5075972328564261119062599703050124571888844499623),
  (23, 3547395716594552006968580343933502225091640193016),
  (11, 1313590626880444859076439518861410402096293651778),
  (15, 3218312062867141430518201748945402874490126058541),
  (15, 144479146528963891026530277745774653422448242206),
  (15, 5193894778257335068725518642271501939542491156882),
  (15, 4154730007399227140709751543799956218154189513236),
  (15, 9002261808524825014613700228149343706476809251591),
  (15, 259458308156526352509594081740648241863543753122),
  (15, 1458934762041713979680058380454298443143584060901),
  (23, 4000103668260798508695301328248384102923667058766),
  (15, 14338369163581660869448809958394134035268952916578),
  (15, 15900711086710240942423238950432046672549140622756),
  (15, 8914720715946541883081228726882519356142069963660),
  (15, 16355733430432409458290300340840296378967331657523),
  (15, 5847655103883041291858135937699990164138090219281),
  (15, 1148007617448378696840553129626162372363481352123),
  (15, 15945838994515634546597623127580125843427004236582),
  (15, 1308533494666186092483253165108497753173551050436),
  (15, 3901811163069543497806359256497782730325046970234),
  (15, 1148001458510801024707687303646155634816953016233),
  (15, 13392658750172773287139241489056979870220960967978),
  (37, 1256632767720610611365858764310600905911369081115),
  (15, 15435963779794939636757144265221815583347085079002),
  (15, 14649334630455868418776563961550614348535028537156),
  (15, 9231570705969315894572743249711849358292835439328),
  (15, 520825846845733872179002314359772570956680287280),
  (15, 5202134753045564604026667303423755995372194200753),
  (15, 8805034819418502294864937896255043841102264205428),
  (15, 13132346442867065738774371726123982112099028394701),
  (15, 1186380538860202968500192361981393091530748902663),
  (15, 13908452020036298738606678022224992851383653331071),
  (15, 8105493738553079023953808614637967288539281938931),
  (23, 15246733105008102511807176287228784392149555475212),
  (15, 15662338969742145836722783862307830441212416585746),
  (15, 13095860893810269071131569145085252786579025950238),
  (11, 1927469775606264490622718313686985071242872722830),
  (15, 16410797073975900553956238649816446460406264973679),
  (23, 2832467555481432130273706055638894964524980790553),
  (15, 3104394291566295990019437011695653241483649329912),
  (15, 7826198899823852488892167417805347598416782865919),
  (15, 11843835696079612697227967991014403134503467115291),
  (15, 12427751611157046235651845619019713884556731042411),
  (15, 14855635103973131690135080640334413304951463050301),
  (15, 16174508731056196350869968090790425465461204109241),
  (15, 3801176168183342854749405443246225165930831363404),
  (15, 6056485532288349765404643589155920869138479261824),
  (15, 13693912940379438381521453182194237370823100093657),
  (23, 2908411367691861222532603889541846581720196934428),
  (15, 15037054836389886057022198277310434928817977732773),
  (15, 4492899503680856278432394595960424333499582402658),
  (23, 4980625768230150443009134581423268409008909465885),
  (15, 8674234714575667840076396873779000996744969094595),
  (15, 15463175336785364840370852663889164294893289080855),
  (15, 11926314141573453882135671407335886008852063443312),
  (15, 924378629542108750306457872930491541795711268518),
  (15, 4100307577741480698128738699343064713265865750280),
  (15, 9624786737628794825003336353928081047139627512448),
  (23, 15325224664603682427566706438998305848491206631953),
  (23, 4157680098474749213839104887092874011132042998766),
  (23, 6439798635619458220844644956821695441917752629731),
  (15, 7610384919988545411952803109298741776708719091599),
  (15, 15765903566166328341122166774252391124182900649527),
  (15, 8357802848014230688801489026094938176590806630418),
  (15, 11364122854013600628374578754430897749278193110325),
  (15, 11433526558336047824190060630332021781151049011803),
  (15, 11764726874035285751181512618648908785518461244086),
  (15, 3129275716992577394132936477358090046049529135844),
  (15, 16168190344935648292538622687414732485962079325289),
  (15, 226759137353460214977537955658101527480338650344),
  (15, 3470608854453286130224456926129551967659208323694),
  (15, 1180479591868047623591390366950361865680040202913),
  (15, 12477545941028478069901555174141434174841057586662),
  (23, 5304643393507816073624148927096341692496764393895),
  (11, 1300933324845233659872845681947814417379797030757)
]

def reduction (choice : MatchingChoice) : ℕ × ℕ :=
  reductionTable[(choice.1.val * 5 + choice.2.1.val) * 3 + choice.2.2.val]!

def digit (data row col : ℕ) : K := (data / 17 ^ (10 * row + col) % 17 : ℕ)

def pivotColumns (choice : MatchingChoice) : List (Fin 6) :=
  (List.finRange 6).filter (fun j => (reduction choice).1.testBit j.val)

def freeColumns (choice : MatchingChoice) : List (Fin 6) :=
  (List.finRange 6).filter (fun j => !(reduction choice).1.testBit j.val)

def kernelDimension (choice : MatchingChoice) : ℕ := (freeColumns choice).length

def basis (choice : MatchingChoice) : Matrix (Fin 6) (Fin (kernelDimension choice)) K :=
  fun i j =>
    let free := (freeColumns choice).get j
    match (pivotColumns choice).idxOf? i with
    | some row => -digit (reduction choice).2 row free.val
    | none => if i = free then 1 else 0

def freeProjection (choice : MatchingChoice) : Matrix (Fin (kernelDimension choice)) (Fin 6) K :=
  fun i j => if j = (freeColumns choice).get i then 1 else 0

def eliminationCertificate (choice : MatchingChoice) : Matrix (Fin 6) (Fin 4) K :=
  fun i j =>
    match (pivotColumns choice).idxOf? i with
    | some row => digit (reduction choice).2 row (j.val + 6)
    | none => 0

/-- Checked equations for the kernel basis, its left inverse, and reconstruction on the kernel. -/
theorem kernel_certificate (choice : MatchingChoice) :
    freeProjection choice * basis choice = 1 ∧
    constraints choice * basis choice = 0 ∧
    basis choice * freeProjection choice = 1 - eliminationCertificate choice * constraints choice := by
  revert choice
  decide +kernel

/-- A vector in the kernel is recovered from its free coordinates. -/
theorem reconstruct_of_constraint_zero (choice : MatchingChoice) (v : Fin 6 → K)
    (h : constraints choice *ᵥ v = 0) :
    basis choice *ᵥ (freeProjection choice *ᵥ v) = v := by
  rw [Matrix.mulVec_mulVec, (kernel_certificate choice).2.2, Matrix.sub_mulVec,
    Matrix.one_mulVec, ← Matrix.mulVec_mulVec, h, Matrix.mulVec_zero, sub_zero]

theorem constraint_mulVec_basis (choice : MatchingChoice) (u : Fin (kernelDimension choice) → K) :
    constraints choice *ᵥ (basis choice *ᵥ u) = 0 := by
  rw [Matrix.mulVec_mulVec, (kernel_certificate choice).2.1, Matrix.zero_mulVec]

theorem freeProjection_mulVec_basis (choice : MatchingChoice)
    (u : Fin (kernelDimension choice) → K) :
    freeProjection choice *ᵥ (basis choice *ᵥ u) = u := by
  rw [Matrix.mulVec_mulVec, (kernel_certificate choice).1, Matrix.one_mulVec]

/-- The actual matching kernel is linearly equivalent to its computed free coordinates. -/
def kernelEquiv (choice : MatchingChoice) :
    (Fin (kernelDimension choice) → K) ≃ₗ[K] LinearMap.ker (constraints choice).mulVecLin where
  toFun u := ⟨basis choice *ᵥ u, constraint_mulVec_basis choice u⟩
  invFun v := freeProjection choice *ᵥ v.val
  left_inv := freeProjection_mulVec_basis choice
  right_inv v := Subtype.ext (reconstruct_of_constraint_zero choice v.val v.property)
  map_add' u v := by
    apply Subtype.ext
    change basis choice *ᵥ (u + v) = basis choice *ᵥ u + basis choice *ᵥ v
    exact Matrix.mulVec_add _ _ _
  map_smul' a u := by
    apply Subtype.ext
    change basis choice *ᵥ (a • u) = a • (basis choice *ᵥ u)
    exact Matrix.mulVec_smul _ _ _

/-- The Plücker quadratic on the six signed minors. -/
def quadratic (v : Fin 6 → K) : K := v 0 * v 5 - v 1 * v 4 + v 2 * v 3

def basisVector (choice : MatchingChoice) (j : ℕ) : Fin 6 → K :=
  if h : j < kernelDimension choice then fun i => basis choice i ⟨j, h⟩ else 0

/-- The polarized form, equal to twice the symmetric Gram form in characteristic seventeen. -/
def polar (u v : Fin 6 → K) : K := quadratic (u + v) - quadratic u - quadratic v

def binaryDiscriminant (choice : MatchingChoice) : K :=
  let u := basisVector choice 0
  let v := basisVector choice 1
  polar u v ^ 2 - 4 * quadratic u * quadratic v

def ternaryDeterminant (choice : MatchingChoice) : K :=
  let u := basisVector choice 0
  let v := basisVector choice 1
  let w := basisVector choice 2
  let a := polar u u
  let b := polar u v
  let c := polar u w
  let d := polar v v
  let e := polar v w
  let g := polar w w
  a * (d * g - e ^ 2) - b * (b * g - c * e) + c * (b * e - c * d)

inductive ChartKind
  | split
  | doubleRoot
  | nonsplit
  | smoothConic
  | other
  deriving DecidableEq

/-- Classify the binary quadratic or rank-three ternary quadratic on the kernel. -/
def classify (choice : MatchingChoice) : ChartKind :=
  match kernelDimension choice with
  | 2 =>
    let u := basisVector choice 0
    let v := basisVector choice 1
    let disc := binaryDiscriminant choice
    if disc = 0 then
      if quadratic u = 0 ∧ quadratic v = 0 ∧ polar u v = 0 then .other else .doubleRoot
    else if disc ^ 8 = 1 then .split else .nonsplit
  | 3 => if ternaryDeterminant choice ≠ 0 then .smoothConic else .other
  | _ => .other

theorem squareCriterion (a : K) : a ^ 8 = 1 ↔ a ≠ 0 ∧ ∃ x : K, x ^ 2 = a := by
  revert a
  decide

def count (kind : ChartKind) : ℕ :=
  ((Finset.univ : Finset MatchingChoice).filter (fun choice => classify choice = kind)).card

theorem census :
    (count .split, count .doubleRoot, count .nonsplit, count .smoothConic, count .other) =
      (36, 36, 28, 5, 0) := by
  decide +kernel

/-- In each smooth conic chart the first basis vector gives a rational point. -/
theorem conic_base_point (choice : MatchingChoice) (h : classify choice = .smoothConic) :
    basisVector choice 0 ≠ 0 ∧ quadratic (basisVector choice 0) = 0 := by
  revert choice
  decide +kernel

end ProximityCoding.MCA.Syndrome.Seventeen.MatchingCensus
