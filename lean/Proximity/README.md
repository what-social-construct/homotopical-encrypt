# Proximity mathematics

This hierarchy contains Paper 3's coding, projection and distance results.
Paper 2 supplies the actual cochain payload, source construction, layout,
decoder/context and authentication contracts used by the application.

| Modules | Mathematical role |
|---|---|
| `Core/` | Reed–Solomon/interleaved words, Hamming metrics, plane/pair/line equivalences, systematic interpolation and lift/metric obstructions. |
| `Capacity/`, `ListDecoding/` | Constructed smooth family, capacity-grid equality, next-shell and fractional-list phase split, and the exact one-codeword list threshold. |
| `MCA/` | Same-set agreement, bad-challenge certificates/spectra and finite/real thresholds. |
| `Application/` | Explicit source-validity, calibration and distance comparisons. |
| `Concrete/GrassmannianPlucker/` | Full projective subspace/projector reconstruction; encoded/digest recovery is separate. |
| `Concrete/ProjectionChain/`, `Concrete/CochainPlane/` | Composition through the original cochain payload and actual extraction; near-side comparisons do not imply a far bound. |
| `Concrete/CanonicalRS/` | Canonical application maps, profile comparisons and separate legacy cited-bound interfaces. |

The standalone [ProximityCoding aggregate](../ProximityCoding.lean) collects
the generic coding proofs and smooth-domain instances.
The independent [coding entry](../Palomar/PaperThree/README.md)
selects 52 declarations; the [native application entry](../Palomar/PaperThree/Application/README.md)
selects 22. Full projective reconstruction and the full-HCP exact-component
obstruction remain canonical auxiliary results outside those selections.

The declared systematic modular profile has intrinsic integral coboundary
validity, actual original-payload extraction and the proved comparison
`d_C ≤ d_P = D_RS ≤ 2*d_C`. Its capacity-far raw examples and restricted
challenge statements are proved. Stronger Euclidean/full-HCP comparisons,
arbitrary fixed-mix preservation and primitive security are separate claims.

See the [manuscript](../../papers/paper3/README.md) and
[live mathematical parity register](../../papers/paper3/SEMANTIC_PARITY.md).

## Polynomial agreement certificates and tensor prices

Let \(P_0,P_1\) interpolate the received pair on the \(n\) evaluation points,
and let \(L(X)=\prod_i(X-a_i)\). Choose multipliers \(h_0,h_1\) of degree
at most \(t\) and set \(R=(h_0P_0+h_1P_1)\bmod L\). If
\(k+t\le D=\deg R<n\), every valid pair agrees with the received pair at
at most \(D\) sites. At each common match,
\(R-h_0f_0-h_1f_1\) vanishes, where the codeword polynomials \(f_0,f_1\)
have degree below \(k\). Their combination \(h_0f_0+h_1f_1\) has degree
below \(D\), so the difference has degree \(D\). The relative pair distance
is at least \((n-D)/n\). [Finite agreement certificate](Core/PolynomialAgreement.lean)

For fixed \(t,D\), solve the homogeneous linear equations that set every
coefficient of \(R\) above \(D\) to zero. A solution with a nonzero coefficient
at \(D\) exists exactly when that coefficient is nonzero on some vector of
the solution-space basis. The search uses the received pair and the evaluation
points alone.

To obtain the geometric bound, put a tagged summand in the tensor \(T_m\) for
each codeword, with an \(m\)-bit wire from the hub to every matching site.
Write \(\ell_{(1)}\ge\cdots\ge\ell_{(n)}\) for the hub-to-site lengths in
decreasing order, and \(C\) for the pair code. Each summand costs at most
\(m\sum_{j=1}^D\ell_{(j)}\). The ordinary sum is a local restriction of the
direct sum, so its price is at most
\(m\sum_{j=1}^D\ell_{(j)}+W(S)\log_2|C|\), where \(W(S)\) is the mean width
of the placed sites including the hub. [Euclidean tensor prices](https://github.com/openai/math/blob/main/preprints/Euclidean-geometry-in-the-asymptotic-spectrum-of-tensors-November-24-2026/build/intro.tex)

Codewords with the same agreement set share the same wire tensor. Summing
their tags first keeps one summand per agreement set. The logarithmic factor
can therefore use the smaller of \(|C|\) and \(\sum_{j=0}^D\binom nj\).

On \(\mathbb F_7^\times\) with \(k=1\), take \(P_0=X^3\) and
\(P_1=X^4+X^2\). The smallest degree of a nonzero constant combination is
\(3\), giving a distance bound of \(1/2\). The multipliers \((-X,1)\) give
\(R=X^2\) and improve the bound to \(2/3\). The constant pair \((1,6)\)
matches at \(2\) and \(4\), so the distance is exactly \(2/3\).

For a second example, use Paper 3's canonical domain with \(n=4096\),
\(k=1024\), and \(a_i=1331^i\) in \(\mathbb F_{12289}\). Choose a set
\(B\) of \(1025\) evaluation points and let \(R(X)=\prod_{a\in B}(X-a)\).
Take \(P_0=X^{3069}R\) and \(P_1=XP_0+R\). The received columns have
degrees \(4094\) and \(4095\), so the best constant-fold degree bound on
distance is \(2/4096\). The multipliers \((-X,1)\) give the response \(R\)
of degree \(1025\). Both received columns vanish on \(B\), so the zero
pair attains the agreement cap and the distance is exactly \(3071/4096\).
[Canonical domain](../../papers/paper3/sections/07-application-interface.tex#L421)

When a certified pair comes from the systematic modular cochain profile,
the existing comparison \(D_{\mathrm{RS}}\le 2d_C\) also gives
\(d_C\ge(n-D)/(2n)\) for that same cochain. [Modular comparison](../../papers/paper3/sections/07-application-interface.tex#L381)

### Certificate boundary and closure

Fix a received pair \(w\), a multiplier budget \(t\), and a response degree
\(k+t\le D<n\), where \(k>0\). Write each multiplier with \(t+1\)
coefficients and normalize the response to \(X^D+\sum_{s<D}r_sX^s\).
The exact feasibility test is the following linear system, with one row
per evaluation point \(a_i\).

\[
\sum_{j=0}^1\sum_{s=0}^t w_{ij}a_i^s h_{js}
  -\sum_{s<D}a_i^s r_s=a_i^D\qquad(i\in I).
\]

A solution gives a certificate directly. Every certificate of this exact
budget and response degree yields a solution by dividing by its nonzero
leading coefficient. For a given \(D\), the largest budget \(t=D-k\)
subsumes all smaller budgets. Multiplying all the witness polynomials
by \(X^s\) preserves the evaluation identities and raises the response
degree and budget by \(s\). Thus feasible degrees form an upper interval
in \([k,n-1]\), and elimination with binary search finds its first degree.
An empty search gives the bound zero. [Normalized coefficient system](Core/PolynomialAgreement/Boundary.lean)

For fixed data and budgets, a nonempty normalized solution set is an affine
translate of the coefficient matrix's kernel. Allowing larger upper bounds
on \(t\) and \(D\) retains all earlier witnesses. The received-word locus
has a different closure property. Over an infinite field extension, the
words \((\lambda\operatorname{eval}(X^D),0)\) certify at degree \(D\) for
\(\lambda\ne0\), using the constant multiplier \(1/\lambda\). At \(\lambda=0\),
the required response would vanish at all \(n>D\) sites. Thus the projected
received-word locus need not be Zariski closed.

Over the algebraic closure \(K\), let \(J\subset K[w,h,r]\) be generated by
the row equations after moving the right sides to the left. Eliminating the
multiplier and response coefficients gives the exact Zariski closure
\(V(J\cap K[w])\) of the projected locus. This elimination construction is
the algebraic closure statement. Lean proves the finite coefficient-system
equivalence and affine kernel description above. [Closure theorem for elimination](https://math.mit.edu/~setia/4370fa19.pdf)

At four sites with \(t=0,D=1\), the closure has one explicit equation.
Writing \(a=(a_i)_i\) and \(\mathbf 1=(1)_i\), it is
\(\det[\,\mathbf1, a,w_0,w_1\,]=0\). At a point on this hypersurface,
the received columns are dependent modulo \(\operatorname{span}(\mathbf1,a)\).
Choose a nonzero linear combination whose result lies in that span.
If its \(a\) coefficient vanishes, add \(\lambda a\) to either received
column with nonzero coefficient in the combination. For \(\lambda\ne0\)
the perturbed word has a degree-one certificate. This constructs the
original point as a limit in the Zariski closure.

### Completeness and sharpness by error count

Let \(e\) be the true whole-pair error count and let \(d_{\min}=n-k+1\),
with \(1\le k\le n\). For \(e>0\), the best bound from the coefficient
search is at least \(\min(e,d_{\min}-e)\). In particular it reaches the
true count for \(2e\le d_{\min}\), including equality. For \(e=0\), the
zero bound is exact. Since RS interpolation gives \(e\le n-k\), every
invalid pair admits a positive certificate. [Completeness construction](Core/PolynomialAgreement/Completeness.lean)

For the existence proof take a nearest pair \(c\) and its agreement set
\(B\), of size \(M=n-e\). Set \(D=\max(M,k+e-1)\) and take
\(Q=X^{D-M}\prod_{i\in B}(X-a_i)\). At each mismatched site, choose two
values whose dot product with the nonzero error symbol \(w_i-c_i\) is
\(Q(a_i)\). Interpolating the two value lists on those \(e\) sites gives
multipliers of degree at most \(e-1\). If \(f_0,f_1\) encode \(c\), then
\(R=Q+h_0f_0+h_1f_1\) has degree \(D\) and satisfies the certificate
equations on every site. The existence proof uses a nearest witness.
The coefficient search only uses \(w\) and the evaluation sites.

On a nonzero evaluation domain, the guarantee is sharp on every error
shell \(1\le e\le n-k\). Choose \(B\) of size \(M=n-e\), put
\(V_B=\prod_{i\in B}(X-a_i)\) and \(s=M-k+1\), and receive
\(w_i=(V_B(a_i)/a_i^s,0)\). The zero pair agrees on \(B\). A larger
agreement would give more than \(M\) roots of \(V_B-X^sf_0\), a nonzero
polynomial of degree at most \(M\) with constant term \(V_B(0)\ne0\).
Any certificate of response degree \(D\) forces \(X^sR\) and \(h_0V_B\)
to agree at all \(n\) sites. Their degrees are \(D+s\) and at most
\(D+s-1\), so \(D+s\ge n\). Thus the best certified count on this family
is exactly \(\min(e,d_{\min}-e)\). [Sharpness construction](Core/PolynomialAgreement/Sharpness.lean)

For example, on \(\mathbb F_5^\times\) with \(k=1\), take \(B=\{1\}\).
The received first column \((a-1)/a\) takes four distinct values and the
second column is zero. The true count is three, immediately above the
closed half-distance count two. The first feasible degree is three,
using the constant multiplier on the first column and response
\(1-X^3\), so the certified count is one.

On the 4,096-site canonical domain, the same sharpness construction with
\(|B|=1025\) has true count \(3071\) and best certified count \(2\).
The earlier polynomial-weighted example attains \(3071\) at that same
error count, so exactness beyond half also depends on the received pair.
