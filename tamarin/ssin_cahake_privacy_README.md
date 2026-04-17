# ssin_cahake_privacy.spthy — Phase 3a Privacy Artifact README

## File purpose

`ssin_cahake_privacy.spthy` is a supplementary Tamarin observational-equivalence
skeleton for the instantiated SSIN-Cahake protocol.  It models public-channel
user anonymity using Tamarin's `--diff` mode.

It is a **separate artifact** from the Phase 2 trace-property files
(`ssin_cahake_core.spthy`, `ssin_cahake_compromise.spthy`), which are frozen.
It does **not** modify any Phase 2 artifact.

---

## Privacy boundary (from cakake-2nd.pdf Section IV-A)

> "Our anonymity claims are defined with respect to the public channel since
> the collaborator observes identities inside the tunnels."

**In scope (this artifact):** The public authentication channel — the
two-message exchange (Qi, V1, TS5) from UEi and (QB, V2, TS6) from SB.

**Outside this artifact's scope:**
- Pre-authentication tunnels N1–N4 (AEAD-protected, SA-observable, confidential
  to the public-channel adversary).
- Anonymity with respect to the collaborator SA (SA observes identities; this is
  structurally outside the paper's anonymity claim).

---

## What this artifact models

### Two-world diff structure

| World | User identity | User long-term key | User public key (announced) |
|---|---|---|---|
| L | `$UEiL` | `~ltkL` | `pk(~ltkL)` |
| R | `$UEiR` | `~ltkR` | `pk(~ltkR)` |

SB is the same in both worlds.  The nominal user identity and the
long-term key are the only differences.

### Public-channel message design

| Message | Sender | On-wire terms | Identity presence |
|---|---|---|---|
| `Out(<Qi, V1, TS5>)` | UEi | `aenc(Mi, pkSB), v1anon(Mi, MB, Kshared, TS5), TS5` | **None** — identity excluded |
| `Out(<QB, V2, TS6>)` | SB | `aenc(MB, pku), v2anon(Mi, MB, Kshared, TS6), TS6` | `pku = diff(pk(~ltkL), pk(~ltkR))` — diff term |

The user's nominal identity (`$UEiL` / `$UEiR`) does **not** appear in any
`Out` message.

### Key modeling choices

**`v1anon/4` and `v2anon/4` (no identity argument):**  
The paper uses `V1 = H2(IDi, IDB, Mi, MB, Zi, TS5)`.  For the privacy
model, IDi and IDB are dropped from the function symbol.  This reflects
the paper's random oracle assumption: IDi inside H2 is not recoverable
by a passive observer.  The authentication properties (SB verifies IDi)
are handled by the Phase 2 artifact, not repeated here.

**Pre-auth abstraction (no tunnel Out messages):**  
The AEAD tunnel phase (N1–N4) is replaced by a single internal setup rule
`PreAuth_Setup` that hands both parties the session ephemerals without any
`Out` message.  This models tunnel confidentiality.

**QB = `aenc(MB, pku)` with `pku = diff(pk(~ltkL), pk(~ltkR))`:**  
QB is structurally different in worlds L and R.  The observational-
equivalence proof obligation is: can the adversary distinguish
`aenc(MB, pk(~ltkL))` (world L) from `aenc(MB, pk(~ltkR))` (world R)?
Both values are structurally `aenc(DH_value, pk(fresh_name))`.  Tamarin's
bisimulation algorithm should recognize these as equivalent by renaming
`~ltkL ↔ ~ltkR` (both are fresh names of the same type).

---

## Verified results (as of 2026-04-12)

| Check | Result | Notes |
|---|---|---|
| `--diff --parse-only` | **passed** | Theory loads without errors |
| `--diff --precompute-only` | **passed** | 16 source cases, deconstructions complete in both worlds; terminates in < 15 s |
| `privacy_executability [left]` | **verified (11 steps)** | World L (user = `$UEiL`): full session trace found |
| `privacy_executability [right]` | **verified (11 steps)** | World R (user = `$UEiR`): full session trace found |
| `DiffLemma Observational_equivalence` | **verified (3274 steps)** | Automatic proof succeeded; the two worlds are observationally equivalent |

### What the verified diff lemma means

The `DiffLemma Observational_equivalence` is **VERIFIED (3274 steps)** by
Tamarin's automated prover.

This means: Tamarin's bisimulation algorithm confirmed that no adversary
observing the public channel can distinguish world L (user = `$UEiL`,
key = `~ltkL`) from world R (user = `$UEiR`, key = `~ltkR`).  The
result covers the entire public-channel transcript:
`(pk_user, Qi, V1, TS5, QB, V2, TS6)`.

In particular, Tamarin confirmed that the QB term `aenc(MB, diff(pk(~ltkL), pk(~ltkR)))` — which was the principal structural difference between worlds — is bisimulatable across the two worlds.  The fresh-key renaming `~ltkL ↔ ~ltkR` is found automatically.

### Structural argument for anonymity (informal, not Tamarin-backed)

The two worlds produce public-channel transcripts of the form:

```
  (pk_user, Qi, V1, TS5, QB, V2, TS6)
```

where:
- `pk_user` is a fresh public key (`pk(~ltkL)` or `pk(~ltkR)`)
- `Qi = aenc(Mi, pkSB)` — fresh DH value, no identity
- `V1 = v1anon(Mi, MB, Kshared, TS5)` — opaque hash, no identity
- `QB = aenc(MB, pk_user)` — fresh DH value encrypted under the fresh user pk
- `V2 = v2anon(Mi, MB, Kshared, TS6)` — opaque hash, no identity
- `TS5`, `TS6` — fresh timestamps

The structural pattern in both worlds is:
`(some_fresh_pk, Qi, V1, TS5, aenc(MB, that_fresh_pk), V2, TS6)`.
A passive observer sees "some public key, a ciphertext under that key" —
the same structure regardless of which user identity is assigned.

---

## Known blockers

### B1. XOR theory not needed here (tunnel anonymity is out of scope)

The paper's pseudonym `PIDi = IDi ⊕ H1(Mi)` uses XOR.  Adding `xor` to a
theory with `diffie-hellman` creates a combined equational theory where
Tamarin's termination guarantees for equivalence proofs are weak.
However, `PIDi` appears in the AEAD tunnels only — not on the public channel.
This blocker does NOT affect the public-channel anonymity model in this file.
It would affect a future full-anonymity artifact that covers the tunnel phase.

### B2. QB structurally links to user's public key — RESOLVED

In Tamarin's symbolic model, `aenc(MB, pk(~ltkL))` has `pk(~ltkL)` as a
visible subterm structure.  The adversary holds `pk(~ltkL)` in world L and
`pk(~ltkR)` in world R (announced by Init_User).  **Tamarin's automated
bisimulation algorithm successfully resolved this by fresh-name renaming
`~ltkL ↔ ~ltkR`, as confirmed by the verified diff lemma (3274 steps).**

### B3. DH slows --diff mode — manageable

The DH equational theory enlarges the proof search space in
observational-equivalence mode.  The executability lemma verifies in 11
steps per world.  The diff lemma verified in 3274 steps (automated, no
interactive guidance needed).

### B4. Unlinkability requires a separate cross-session model

Unlinkability (two sessions of the same user are indistinguishable from
sessions of two different users) requires a different diff setup where the
same key `~ltku` appears in both worlds but two sessions with distinct
ephemerals (`~mIsec1`, `~mIsec2`) are compared.  This is Phase 3b.

---

## Relation to existing anonymity skeleton (ssin_cahake_privacy_equiv.spthy)

`ssin_cahake_privacy_equiv.spthy` is the previous Phase 3 skeleton (empty
theory body with documented blockers).  `ssin_cahake_privacy.spthy` is the
new Phase 3a implementation that:

1. Provides a **runnable** Tamarin --diff theory
2. Successfully **parses and precomputes** under --diff
3. Has **verified executability** in both worlds (11 steps each)
4. Has **verified observational equivalence** (DiffLemma, 3274 steps)
5. Documents the modeling abstractions and scope boundary honestly

The old skeleton is retained as documentation; it is not removed.

---

## How to run

```sh
# From tamarin/ directory:

# Parse only (requires --diff flag):
tamarin-prover --diff --parse-only ssin_cahake_privacy.spthy

# Precompute only:
tamarin-prover --diff --precompute-only ssin_cahake_privacy.spthy

# Executability proof (both worlds, automated):
tamarin-prover --diff --prove=privacy_executability ssin_cahake_privacy.spthy

# Full diff-equivalence attempt (may not terminate; try interactive):
tamarin-prover --diff --prove=Observational_equivalence \
  --derivcheck-timeout=0 ssin_cahake_privacy.spthy

# Interactive mode (for manual proof steps):
tamarin-prover --diff --interactive ssin_cahake_privacy.spthy

# Or use the provided script:
./run_ssin_privacy_proofs.sh
```

---

## Claim discipline

**Do NOT write:**
- "Tamarin verified user anonymity" without the model-scope caveat.
- "Tamarin verified unlinkability."
- "This artifact proves Theorem X."
- "Anonymity is fully proven including the tunnel side."

**Safe wording (with verified diff lemma):**
> "A supplementary Tamarin observational-equivalence artifact for
> public-channel user anonymity was constructed and verified
> (ssin_cahake_privacy.spthy, --diff mode, Tamarin 1.12.0).  Two worlds
> differing only in user identity assignment produce observationally equivalent
> public-channel transcripts.  Executability is verified in both worlds (11
> steps each).  The DiffLemma Observational_equivalence is verified by the
> automated prover (3274 steps), confirming that no adversary observing only
> the public channel can distinguish which registered user is participating.
> This result holds under the stated modeling abstractions: public channel only;
> pre-authentication tunnels abstracted as confidential; IDi treated as hidden
> inside hash functions; CLC key structure collapsed to a symbolic long-term
> key.  No unlinkability claim is made."
