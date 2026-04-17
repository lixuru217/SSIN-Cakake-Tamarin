# SSIN-Cahake Core Tamarin Model

## Scope
This model targets the instantiated SSIN-Cahake core handshake in Section VI of `cakake-2nd.pdf`, specifically:
- Section VI-C `Pre-Authentication`
- Section VI-D `Mutual Authentication and Key Exchange`

It does not target the abstract Cahake protocol of Sections IV-V.

## Modeled Roles And Terms
- `UEi`: user equipment
- `SA`: serving satellite, modeled as protocol-following / passive within the modeled scope
- `SB`: target satellite
- `Mi`, `MB`: pre-authentication ephemeral public values
- `Qi`, `QB`: public challenge / response values
- `V1`, `V2`: integrity values carried on the public channel
- `TS1`-`TS6`: freshness values
- `Kshared`, `SKiB`: shared secret and derived session key

## Explicit Abstractions
- Section VI-A / VI-B trusted setup and registration are abstracted as long-term key initialization and public identity-hash initialization via `InitEntity`.
  - The paper's certificateless tuple `PKi = (pki, Pi)` is collapsed into one symbolic public-key term `pk(ltk)`.
  - The paper's `hi = H1(IDi, Di, pki, Pi)` and `hB = H1(IDB, DB, pkB, PB)` are compressed into `hid(A, D, pk(ltk))`.
- The secure tunnel messages `N1`-`N4` are modeled as ideal confidential and authentic relay steps through `SA`, not as concrete AEAD ciphertext terms.
- In the extracted VI-D prose block, the paper makes the responder-side equation
  - `QB = mB · (hi · Ppub,i + pki + Pi)` with `QB · SKi = MB`
  explicit, while the initiator-side Step 1 text says only that `UEi` computes `Qi` from `mi` and `SB`'s public key and the explicit verification relation is `M'_i = Qi · SKB = Mi`.
  The model therefore abstracts both public challenges as recoverability under the peer's long-term secret key:
  - `Qi = aenc(Mi, pkSB)`
  - `QB = aenc(MB, pkUEi)`
- `TS1`-`TS6` are modeled as fresh values rather than wall-clock timestamps.
  - The `CheckTS4`, `CheckTS5`, and `CheckTS6` action facts that appear in the rules
    are **instrumentation annotations only**; they impose no restriction.
    No `restriction` statement enforces a timestamp-freshness window or uniqueness
    condition on these facts. Replay protection in the model relies entirely on
    Tamarin's fresh-value axiom applied to `~TS5` (generated in `UEi_Public_Send`)
    and `~TS6` (generated in `SB_Public_Recv_Send`), which makes them globally unique
    across all rule firings by construction.
- `Kshared` is modeled with symbolic Diffie-Hellman:
  - `Mi = 'g'^mIsec`
  - `MB = 'g'^mBsec`
  - `Kshared = Mi^mBsec = MB^mIsec`
- `SKiB` is modeled as `skdf(Kshared, UEi, Di, SB, DB, TS5, TS6)`, matching the Section VI-D dependency structure.

## Pre-Protocol Assumptions

The following assumptions are implicit in the model rules and must be stated
explicitly for any reviewer reading the model.

- **UEi knows SB's domain label `DB` before the protocol starts.**
  In `UEi_PreAuth_1`, `$DB` is a free public variable supplied by `UEi`.
  If `UEi` supplies the wrong value, `SB_PreAuth_3` cannot fire because the
  `!Hi($SB, $DB, ...)` lookup will not match. The model therefore silently requires
  UEi to hold the correct `DB`. In a real SSIN deployment, `DB` is broadcast as
  part of the satellite's public identity.
- **UEi knows SB's public key `pkSB` before the protocol starts.**
  `UEi_PreAuth_1` performs `!Pk($SB, pkSB)` before any message is sent. UEi
  must have SB's public key available from the satellite PKI infrastructure
  before initiating pre-authentication.
- **`CacheUEi` is a passive trace annotation only.**
  The action fact `CacheUEi(UEi, SB, hi, hB, Mi, MB)` in `UEi_Public_Send`
  records the pre-authentication cache state as a trace label. It is not
  referenced in any lemma or restriction and performs no verification function.

## Out Of Scope
- Section VI-E batch verification
- any Tamarin claim about Theorem 5 or batch-verification soundness
- any Tamarin claim that all of Section VII has been verified
- KCI or compromise-oracle coverage from Section VII
- stronger collaborator behavior than protocol-following / passive `SA`
- a proof of PFS under compromise queries

## Environment
- `tamarin-prover`: `/usr/local/bin/tamarin-prover`
- `tamarin-prover --version`: `1.12.0`
- `maude`: `/usr/local/Cellar/maude/2.7.1_1/bin/maude`
- `dot`: `/usr/local/bin/dot`

## Commands Run

**Canonical rerun entry point** (uses `run_ssin_proofs.sh`, logs to `ssin_proof_logs/`):

```sh
cd tamarin
./run_ssin_proofs.sh
```

The individual commands executed by that script are listed below for reference.
Run from `/Users/lixuru/Documents/Stu_codes/Cakake-Tamarin/tamarin`.

```sh
/usr/local/bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --parse-only ssin_cahake_core.spthy

/usr/local/bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --quit-on-warning --precompute-only ssin_cahake_core.spthy

/usr/local/bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=executability_ssin_core ssin_cahake_core.spthy

/usr/local/bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=session_key_secrecy_sb_core ssin_cahake_core.spthy

/usr/local/bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=session_key_secrecy_uei_core ssin_cahake_core.spthy

/usr/local/bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=agreement_sb_on_uei_core ssin_cahake_core.spthy

/usr/local/bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=agreement_uei_on_sb_core ssin_cahake_core.spthy

/usr/local/bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=no_replay_sb_accept_core ssin_cahake_core.spthy

/usr/local/bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=no_inconsistent_acceptance_core ssin_cahake_core.spthy
```

## Run Structure Note
- The model contains 7 lemmas, and the recorded workflow uses 9 runs in total: `--parse-only`, `--precompute-only`, and 7 dedicated `--prove=<lemma>` invocations.
- Each lemma was proved in a dedicated Tamarin invocation.
- In each individual lemma log file, the non-target lemmas appear as `analysis incomplete (1 steps)` by design because they were not the target of that invocation.

## Output-Backed Status

| Check or lemma | Status | Tamarin summary |
|---|---|---|
| `parse-only` | passed | theory loaded successfully |
| `wellformedness` | passed | `24` raw / `24` refined sources, deconstructions complete |
| `executability_ssin_core` | verified | `verified (10 steps)` |
| `session_key_secrecy_sb_core` | verified | `verified (7 steps)` |
| `session_key_secrecy_uei_core` | verified | `verified (7 steps)` |
| `agreement_sb_on_uei_core` | verified | `verified (11 steps)` |
| `agreement_uei_on_sb_core` | verified | `verified (11 steps)` |
| `no_replay_sb_accept_core` | verified | `verified (2 steps)` |
| `no_inconsistent_acceptance_core` | verified | `verified (4 steps)` |

## Manual Intervention
- Renamed the internal ephemeral-secret variables to `mIsec` and `mBsec` to avoid Tamarin capitalization and sort clashes with `Mi` and `MB`.
- Corrected the Section VI-C timestamp alignment so that Step 2 uses `TS2` and Step 4 uses `TS4`.
- Used `--derivcheck-timeout=0` for proof invocations because the default derivation-check timeout could abort otherwise successful proof runs under `--quit-on-warning`.

## Interpretation Limits
- The Tamarin-backed secrecy claims are only for the absence of long-term-key or ephemeral-key compromise, because this model does not include `Corrupt` or `StateReveal` style compromise interfaces.
- The Tamarin-backed agreement-style lemmas only establish matching prior honest sends of the peer's public-phase message. They do not, by themselves, prove full non-injective agreement on the entire session tuple or restate the Section VII explicit-authentication theorem.
- The model complements, but does not replace, the paper's collaborator-augmented CK-derived AKE model.
