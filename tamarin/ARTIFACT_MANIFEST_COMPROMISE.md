# Artifact Manifest — SSIN-Cahake Compromise-Aware Model

## Scope

This manifest covers the Priority-2 symbolic verification of the instantiated
SSIN-Cahake core handshake under compromise.  The model (`ssin_cahake_compromise.spthy`)
extends the Milestone-2 baseline (`ssin_cahake_core.spthy`) with:

- Long-term-key (LT) compromise oracle: `Compromise_LT`  → `CorruptLT(A)`
- Ephemeral-key (EP) compromise oracle for UEi: `Compromise_EP_UEi` → `CorruptEP(UEi, mIsec)`
- Ephemeral-key (EP) compromise oracle for SB: `Compromise_EP_SB` → `CorruptEP(SB, mBsec)`

Paper scope: Section VI-C (Pre-Authentication) and Section VI-D (Mutual Authentication
and Key Exchange) of `cakake-2nd.pdf`, with compromise interfaces aligned with
Section VII.

It does **not** cover:
- The Milestone-1 abstract Cahake model (`cahake_abstract.spthy`)
- The abstract KCI extension (`cahake_abstract_kci.spthy`)
- Section VI-E batch verification
- Theorem 5

## Toolchain

| Tool | Binary | Version |
|---|---|---|
| `tamarin-prover` | `/usr/local/bin/tamarin-prover` | `1.12.0` |
| `maude` | `/usr/local/Cellar/maude/2.7.1_1/bin/maude` | `2.7.1` |
| `dot` (graphviz) | `/usr/local/bin/dot` | `11.0.0` |

## Model File

```
tamarin/ssin_cahake_compromise.spthy
```

The protocol rules are structurally identical to the Milestone-2 baseline.
The only extensions are the persistent ephemeral facts (`!EphUEi`, `!EphSB`)
added to two pre-auth rules and the three compromise-oracle rules.

## Proof Script and Logs

| File | Role |
|---|---|
| `tamarin/run_ssin_compromise_proofs.sh` | Canonical proof script (15 active steps) |
| `tamarin/ssin_compromise_proof_logs/` | Log directory — three distinct log sets (see below) |

Default invocation:

```sh
cd tamarin
./run_ssin_compromise_proofs.sh
```

### Log Set Inventory

The log directory contains three distinct sets of log files:

| Log set | File pattern | Count | Status |
|---|---|---|---|
| **Active canonical logs** | `01_parse_only.log` … `12_kci_ake_secrecy_uei_t4.log` | 15 files | Current — produced by `run_ssin_compromise_proofs.sh` on the revised model (v1tag/6, v2tag/6) |
| **Archived old-model logs** | `old_model_08_kci_ea_sb_core.log`, `old_model_09_kci_ea_uei_core.log` | 2 files | Audit only — falsifications from old model (v1tag/4, v2tag/5); retained as historical evidence |
| **Supplementary re-run logs** | `r2_*.log` (13 files) | 13 files | Cross-verification re-run on the revised model; step counts match active canonical logs; not the canonical output set |

The **active canonical logs** are the authoritative proof record.  The `r2_*` logs are a supplementary verification run confirming the same results; they are not the canonical output and are not referenced in per-lemma step counts below.

## Per-Lemma Status — Current Verified Set (revised model, v1tag/6, v2tag/6)

Step counts sourced from active canonical log files (confirmed; r2_* re-run independently corroborates).

| Step | Log file | Lemma | Kind | Result | Steps |
|---|---|---|---|---|---|
| 01 | `01_parse_only.log` | (parse only) | — | OK | — |
| 02 | `02_wellformedness.log` | (wellformedness) | — | OK | — |
| 03 | `03_executability_kci.log` | `executability_kci` | exists-trace | **verified** | 10 |
| 04 | `04_executability_with_lt_corrupt.log` | `executability_with_lt_corrupt` | exists-trace | **verified** | 11 |
| 04b | `04b_executability_with_uei_lt_corrupt.log` | `executability_with_uei_lt_corrupt` | exists-trace | **verified** | 11 |
| 05 | `05_no_replay_sb_accept_core.log` | `no_replay_sb_accept_core` | all-traces | **verified** | 2 |
| 06 | `06_no_replay_uei_accept_core.log` | `no_replay_uei_accept_core` | all-traces | **verified** | 8 |
| 07 | `07_no_inconsistent_acceptance_core.log` | `no_inconsistent_acceptance_core` | all-traces | **verified** | 4 |
| 08 | `08_kci_ea_sb_lt_clean.log` | `kci_ea_sb_lt_clean` | all-traces | **verified** | 11 |
| 09 | `09_kci_ea_uei_lt_clean.log` | `kci_ea_uei_lt_clean` | all-traces | **verified** | 12 |
| 09b | `09b_kci_ea_uei_kci_proper.log` | `kci_ea_uei_kci_proper` | all-traces | **verified** | 12 |
| 09c | `09c_kci_ea_sb_kci_proper.log` | `kci_ea_sb_kci_proper` | all-traces | **verified** | 11 |
| 10 | `10_fresh_secrecy_sb_kci.log` | `fresh_secrecy_sb_kci` | all-traces | **verified** | 12 |
| 11 | `11_fresh_secrecy_uei_kci.log` | `fresh_secrecy_uei_kci` | all-traces | **verified** | 12 |
| 12 | `12_kci_ake_secrecy_uei_t4.log` | `kci_ake_secrecy_uei_t4` | all-traces | **verified** | 12 |

### Old-Model Falsification Record — Archived (audit only)

The following logs record falsifications from the old model (v1tag/4, v2tag/5 — no DH binder).
They have been renamed with the `old_model_` prefix so the active log set is unambiguous.

| Archived log file | Lemma at time of run | Result | Status |
|---|---|---|---|
| `old_model_08_kci_ea_sb_core.log` | `kci_ea_sb_core` (old model) | **falsified** (7 steps) | CLOSED — DH binder in v1tag/6; see `kci_ea_sb_kci_proper` |
| `old_model_09_kci_ea_uei_core.log` | `kci_ea_uei_core` (old model) | **falsified** (12 steps) | CLOSED — DH binder in v2tag/6; see `kci_ea_uei_kci_proper` |

These logs are retained as audit evidence only.  The current model has the corresponding
lemmas commented out (as `kci_ea_sb_FALSIFIED` / `kci_ea_uei_FALSIFIED`) and replaced by
the verified lemmas `kci_ea_sb_kci_proper` / `kci_ea_uei_kci_proper`.

## KCI-EA Model-to-Paper Mismatch — CLOSED (2026-04-11)

**This section previously reported a "paper discrepancy" with the paper's Theorem 3
G2 argument.  That finding was incorrect and is retracted here.**

**Original finding (old model, v1tag/4 — SUPERSEDED):**
In the old symbolic model (`v1tag/4`, without the DH binder), the SB-accepting KCI-EA
direction was FALSIFIED in 7 steps: `Corrupt(SB)` → `adec(Qi, ltkSB) = Mi` →
forge `v1tag(UEi, SB, Mi, TS5')`.  This led to an incorrect "paper discrepancy"
note claiming the paper's G2 argument overlooked adversarial recovery of Mi.

**Why the old note was wrong:**
The paper's G2 argument (§VII Proof 3, cakake-2nd.pdf p. 9) is stated within
Theorem 3's game, where `ltkSB` is excluded by the freshness condition ("SB remains
uncorrupted prior to the tested acceptance event").  The paper explicitly states:
"Without the long-term key of SB, or a state-reveal query on the tested session,
A cannot recover Mi."  Within Theorem 3's scope, both conditions are denied to A.
The paper's G2 argument is correct.

The old attack was in the **SB-accepting** direction, which is outside Theorem 3's
claimed scope (Theorem 3 is UEi-accepting only).  Additionally, the old symbolic
model lacked the DH binder in V1, which the current paper (cakake-2nd.pdf, §VI-D)
includes as `Zi = mi·MB`.

**Current status (revised model, v1tag/6 — VERIFIED):**
After correcting the model to `v1tag/6` (with `Kshared = MB^mIsec`):
- `kci_ea_uei_kci_proper`: UEi-accepting trace-level proxy — **VERIFIED (12 steps)**.
  NOT a proof of Theorem 3. Corrupt(UEi) allowed; NOT Corrupt(SB) before i;
  NOT CorruptEP on either party.
- `kci_ea_sb_kci_proper`: SB-accepting supplementary trace-level proxy — **VERIFIED (11 steps)**.
  NOT claimed in Theorem 3 (UEi-accepting only). Corrupt(SB) allowed; NOT Corrupt(UEi)
  before i; NOT CorruptEP on either party.
  The DH binder closes the old forgery: knowing Mi from ltkSB + Qi does not give
  Kshared = Mi^mBsec without mBsec (CDH); mBsec excluded by cleanliness guard.

**Provable replacements (non-KCI fallbacks, retained):**
`kci_ea_sb_lt_clean` and `kci_ea_uei_lt_clean` prove message-origin evidence
under the additional restriction that the accepting party's own LT key was NOT
corrupted before acceptance.  These are the non-KCI case lemmas.

**Safe reviewer-facing wording (SB side, KCI):**
> "In the SB-accepting direction, symbolic KCI-resilient explicit authentication
>  holds when both parties' ephemeral secrets are uncompromised before acceptance
>  and UEi's long-term key is uncorrupted before acceptance; SB's long-term-key
>  corruption does not enable adversarial impersonation due to the DH binder in V1."

**Safe reviewer-facing wording (UEi side, KCI):**
> "In the UEi-accepting direction, symbolic KCI-resilient explicit authentication
>  holds when both parties' ephemeral secrets are uncompromised before acceptance
>  and SB's long-term key is uncorrupted before acceptance; UEi's long-term-key
>  corruption does not enable adversarial impersonation due to the DH binder in V2."

## Claims Map

**NOTE: This file is superseded by `ARTIFACT_MANIFEST_M2.md` for full coverage.**
The table below reflects the current verified lemma set (revised model, v1tag/6, v2tag/6).

| Paper claim / theorem | Model coverage | Qualifier |
|---|---|---|
| Theorem 3-adjacent KCI-EA (UEi-accepting) | `kci_ea_uei_kci_proper` (12 steps) | **Trace-level proxy only** — NOT a proof of Theorem 3. Prior-send evidence; NOT partnered-uniqueness. Party-level EP guards. |
| Theorem 3-adjacent KCI-EA (SB-accepting, symmetric) | `kci_ea_sb_kci_proper` (11 steps) | Supplementary; NOT claimed in Theorem 3. Same proxy caveats. DH binder closes old falsification. |
| KCI-EA non-KCI fallback (SB side) | `kci_ea_sb_lt_clean` (11 steps) | Actor's own LT clean; non-KCI case |
| KCI-EA non-KCI fallback (UEi side) | `kci_ea_uei_lt_clean` (12 steps) | Actor's own LT clean; non-KCI case |
| Theorem 4-adjacent AKE secrecy (UEi-accepting) | `kci_ake_secrecy_uei_t4` (12 steps) | **Trace-level proxy only** — NOT a proof of Theorem 4. No Reveal/Test oracle; party-level EP guards. |
| Supplementary trace-level secrecy proxy (SB-accepting) | `fresh_secrecy_sb_kci` (12 steps) | Both EPs globally clean; LT corruption unrestricted. Not theorem-exact; SB-accepting direction outside Theorem 4 scope; no Reveal/Test oracle. |
| Supplementary trace-level secrecy proxy (UEi-accepting) | `fresh_secrecy_uei_kci` (12 steps) | Both EPs globally clean; LT corruption unrestricted. Not theorem-exact; no CorruptLT(SB) timing restriction; no Reveal/Test oracle; party-level EP guards. |
| Replay resistance | `no_replay_sb_accept_core` (2 steps), `no_replay_uei_accept_core` (8 steps) | Unconditional |
| Key consistency | `no_inconsistent_acceptance_core` (4 steps) | Unconditional |

## Relationship to Other Artifacts

| Artifact | Scope |
|---|---|
| `ARTIFACT_MANIFEST_M2.md` | Milestone-2 baseline (no compromise) |
| `ARTIFACT_MANIFEST_ABSTRACT_KCI.md` | Abstract Cahake KCI extension |
| `ARTIFACT_MANIFEST_COMPROMISE.md` (this file) | Instantiated SSIN-Cahake compromise-aware model |
