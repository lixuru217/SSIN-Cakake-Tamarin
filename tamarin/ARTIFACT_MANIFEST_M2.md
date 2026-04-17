# Milestone-2 Artifact Manifest — Instantiated SSIN-Cahake

## Source-of-truth
All artifacts are grounded in **cakake-2nd.pdf**.  Section VI-C and Section VI-D
are the protocol-flow source of truth.  Section VII is the source of truth for
compromise-game semantics.  The manifest was re-baselined against cakake-2nd.pdf;
no structural changes to VI-C / VI-D were detected.

## Scope

This manifest covers the symbolic verification of the instantiated SSIN-Cahake
core handshake across three model files.

Does **not** cover:
- the Milestone-1 abstract Cahake model (`cahake_abstract.spthy`)
- Section VI-E batch verification
- User anonymity / Unlinkability (see `ssin_cahake_privacy_equiv.spthy` skeleton)

---

## Toolchain

| Tool | Binary | Version |
|---|---|---|
| `tamarin-prover` | `/usr/local/bin/tamarin-prover` | `1.12.0` |
| `maude` | `/usr/local/Cellar/maude/2.7.1_1/bin/maude` | `2.7.1` |
| `dot` (graphviz) | `/usr/local/bin/dot` | `11.0.0` |

Fallback Tamarin binary (if primary not available): `/tmp/tamarin-bin/tamarin-prover`

---

## Model files

| File | Purpose | Run script | Log directory |
|---|---|---|---|
| `ssin_cahake_core.spthy` | Baseline no-compromise trace model | `run_ssin_proofs.sh` | `ssin_proof_logs/` |
| `ssin_cahake_core_extended.spthy` | Phase 1: strengthened trace lemmas | `run_ssin_extended_proofs.sh` | `ssin_extended_proof_logs/` |
| `ssin_cahake_compromise.spthy` | Phase 2: LT + EP compromise oracles | `run_ssin_compromise_proofs.sh` | `ssin_compromise_proof_logs/` |
| `ssin_cahake_privacy_equiv.spthy` | Phase 3 skeleton — out of scope | *(none)* | *(none)* |

---

## File 1 — `ssin_cahake_core.spthy` (baseline)

Canonical rerun: `cd tamarin && ./run_ssin_proofs.sh`

| Step | Log file | Expected result |
|---|---|---|
| 01 | `ssin_proof_logs/01_parse_only.log` | `Theory loaded` |
| 02 | `ssin_proof_logs/02_wellformedness.log` | `24 raw / 24 refined sources` |
| 03 | `ssin_proof_logs/03_executability_ssin_core.log` | `verified (10 steps)` |
| 04 | `ssin_proof_logs/04_session_key_secrecy_sb_core.log` | `verified (7 steps)` |
| 05 | `ssin_proof_logs/05_session_key_secrecy_uei_core.log` | `verified (7 steps)` |
| 06 | `ssin_proof_logs/06_agreement_sb_on_uei_core.log` | `verified (8 steps)` |
| 07 | `ssin_proof_logs/07_agreement_uei_on_sb_core.log` | `verified (8 steps)` |
| 08 | `ssin_proof_logs/08_no_replay_sb_accept_core.log` | `verified (2 steps)` |
| 09 | `ssin_proof_logs/09_no_inconsistent_acceptance_core.log` | `verified (4 steps)` |

---

## File 2 — `ssin_cahake_core_extended.spthy` (Phase 1)

Canonical rerun: `cd tamarin && ./run_ssin_extended_proofs.sh`

Contains all baseline lemmas plus four new Priority-1 lemmas.

| Step | Log file | Lemma | Expected result |
|---|---|---|---|
| 01 | `ssin_extended_proof_logs/01_parse_only.log` | parse | `Theory loaded` |
| 02 | `ssin_extended_proof_logs/02_wellformedness.log` | well-formed | sources complete |
| 03 | `ssin_extended_proof_logs/03_executability_ssin_core.log` | `executability_ssin_core` | `verified (10 steps)` |
| 04 | `ssin_extended_proof_logs/04_session_key_secrecy_sb_core.log` | `session_key_secrecy_sb_core` | `verified (7 steps)` |
| 05 | `ssin_extended_proof_logs/05_session_key_secrecy_uei_core.log` | `session_key_secrecy_uei_core` | `verified (7 steps)` |
| 06 | `ssin_extended_proof_logs/06_agreement_sb_on_uei_core.log` | `agreement_sb_on_uei_core` | `verified (8 steps)` |
| 07 | `ssin_extended_proof_logs/07_agreement_uei_on_sb_core.log` | `agreement_uei_on_sb_core` | `verified (8 steps)` |
| 08 | `ssin_extended_proof_logs/08_no_replay_sb_accept_core.log` | `no_replay_sb_accept_core` | `verified (2 steps)` |
| 09 | `ssin_extended_proof_logs/09_no_inconsistent_acceptance_core.log` | `no_inconsistent_acceptance_core` | `verified (4 steps)` |
| 10 | `ssin_extended_proof_logs/10_no_replay_uei_accept_core.log` | `no_replay_uei_accept_core` | `verified (8 steps)` |
| 11 | `ssin_extended_proof_logs/11_mutual_auth_consistent_core.log` | `mutual_auth_consistent_core` | `verified (5 steps)` |
| 12 | `ssin_extended_proof_logs/12_full_session_agree_uei_core.log` | `full_session_agree_uei_core` | `verified (13 steps)` |
| 13 | `ssin_extended_proof_logs/13_no_key_splitting.log` | `no_key_splitting` | `verified (9 steps)` |

**Phase 1 new lemma descriptions:**

- `no_replay_uei_accept_core`: UEi cannot accept twice on the same complete
  session tuple.  Mirrors the SB-side `no_replay_sb_accept_core`.  Proof relies
  on fresh-value uniqueness of `~TS6` and linearity of `StUEi_Public`.

- `mutual_auth_consistent_core`: When both parties have accepted on the same
  session tuple, each acceptance is preceded by a matching honest public-phase
  send from the respective peer.  Combines both agreement directions into a
  single bilateral claim.

- `no_key_splitting` **(new, step 13)**: Key-substitution / key-splitting prevention.
  If both UEi and SB accept on sessions sharing the same `(TS5, TS6)` pair,
  they derive the same session key SKiB — even if their local session parameters
  `(Mi, MB, Qi, QB)` are left unconstrained in the premise.  This rules out
  key-splitting attacks in which the adversary causes divergent key states at
  the two endpoints.  **Scope note:** this is a key-consistency check, not a
  general MitM-prevention claim.  Active-MitM resistance at the UEi side is
  established by `full_session_agree_uei_core`; SB-side baseline authentication
  is carried by `agreement_sb_on_uei_core` (step 06).  Proof: `~TS5` and `~TS6` are
  globally unique fresh values; matching timestamps uniquely identify a paired
  `(UEi_Public_Send, SB_Public_Recv_Send)` firing, fixing Kshared and SKiB.
  Verified (9 steps).

- `full_session_agree_uei_core`: Non-injective session agreement at the UEi side.
  UEi acceptance implies a **prior AcceptSB** on the same complete session tuple
  (Mi, MB, Qi, QB, TS5, TS6, SKiB).  Stronger than `agreement_uei_on_sb_core`
  which only asserts a matching SentPublic2.  Proof: QB = aenc(MB,pkUEi) is only
  produced by `SB_Public_Recv_Send`, which fires AcceptSB at the same time-point.

**Note on full_session_agree_sb_core (removed):** Step 14 (`full_session_agree_sb_core`)
was removed.  Its formula was identical to `agreement_sb_on_uei_core` (step 06): both
assert `AcceptSB → ∃ prior SentPublic1 from UEi`.  The stronger upgrade (requiring
`AcceptUEi`) is not provable due to protocol message ordering (SB accepts and sends its
response before UEi has accepted).  The SB-side baseline authentication claim is
`agreement_sb_on_uei_core` (step 06).

**Note on parse logs (step 01):** `01_parse_only.log` was regenerated on
2026-04-14 from the current model and correctly shows `v1tag/6` and `v2tag/6`.
All proof logs (steps 01–13) are now current-model artifacts.  Step 13
(`13_no_key_splitting.log`) was also regenerated on 2026-04-14 after the removal
of `full_session_agree_sb_core`; it shows only
`no_key_splitting (all-traces): verified (9 steps)` with no stale lemma entries.

---

## File 3 — `ssin_cahake_compromise.spthy` (Phase 2)

Canonical rerun: `cd tamarin && ./run_ssin_compromise_proofs.sh`

| Step | Log file | Lemma | Expected result |
|---|---|---|---|
| 01 | `ssin_compromise_proof_logs/01_parse_only.log` | parse | `Theory loaded` |
| 02 | `ssin_compromise_proof_logs/02_wellformedness.log` | well-formed | sources complete |
| 03 | `ssin_compromise_proof_logs/03_executability_kci.log` | `executability_kci` | `verified (10 steps)` |
| 04 | `ssin_compromise_proof_logs/04_executability_with_lt_corrupt.log` | `executability_with_lt_corrupt` | `verified (11 steps)` |
| 04b | `ssin_compromise_proof_logs/04b_executability_with_uei_lt_corrupt.log` | `executability_with_uei_lt_corrupt` | `verified (11 steps)` |
| 05 | `ssin_compromise_proof_logs/05_no_replay_sb_accept_core.log` | `no_replay_sb_accept_core` | `verified (2 steps)` |
| 06 | `ssin_compromise_proof_logs/06_no_replay_uei_accept_core.log` | `no_replay_uei_accept_core` | `verified (8 steps)` |
| 07 | `ssin_compromise_proof_logs/07_no_inconsistent_acceptance_core.log` | `no_inconsistent_acceptance_core` | `verified (4 steps)` |
| 08 | `ssin_compromise_proof_logs/08_kci_ea_sb_lt_clean.log` | `kci_ea_sb_lt_clean` | `verified (11 steps)` |
| 09 | `ssin_compromise_proof_logs/09_kci_ea_uei_lt_clean.log` | `kci_ea_uei_lt_clean` | `verified (12 steps)` |
| 09b | `ssin_compromise_proof_logs/09b_kci_ea_uei_kci_proper.log` | `kci_ea_uei_kci_proper` | `verified (12 steps)` |
| 09c | `ssin_compromise_proof_logs/09c_kci_ea_sb_kci_proper.log` | `kci_ea_sb_kci_proper` | `verified (11 steps)` |
| 10 | `ssin_compromise_proof_logs/10_fresh_secrecy_sb_kci.log` | `fresh_secrecy_sb_kci` | `verified (12 steps)` |
| 11 | `ssin_compromise_proof_logs/11_fresh_secrecy_uei_kci.log` | `fresh_secrecy_uei_kci` | `verified (12 steps)` |
| 12 | `ssin_compromise_proof_logs/12_kci_ake_secrecy_uei_t4.log` | `kci_ake_secrecy_uei_t4` | `verified (12 steps)` |

**Documented falsifications (kept as audit record):**

Old-model falsification logs have been renamed to `old_model_*.log` to distinguish
them from the active current-model log set.  They are retained in
`ssin_compromise_proof_logs/` for audit traceability only.

| Log (archived name) | Lemma | Result | Root cause |
|---|---|---|---|
| `old_model_08_kci_ea_sb_core.log` | `kci_ea_sb_core` (old model, v1tag/4) | `falsified (7 steps)` — **model-to-paper mismatch; CLOSED by DH binder** | Old model used `v1tag(UEi,SB,Mi,TS5)` (no binder); `Corrupt(SB)` + `adec(Qi,ltkSB)=Mi` → forged V1. Corrected model: `v1tag/6`; see `kci_ea_sb_kci_proper` (verified, step 09c). |
| `old_model_09_kci_ea_uei_core.log` | `kci_ea_uei_core` (old model, v2tag/5) | `falsified (12 steps)` — **model-to-paper mismatch; CLOSED by DH binder** | Old model used `v2tag/5` (no binder); `Corrupt(SB)+Corrupt(UEi)` → forge V2. Also violates Theorem 3 freshness (Corrupt(SB)). Corrected: `v2tag/6`. |
| (commented out in model) | `kci_ea_sb_FALSIFIED` (old model, v1tag/4) | same as above | Audit record in `.spthy`; see `MISMATCH NOTE` comment |
| (commented out in model) | `kci_ea_uei_FALSIFIED` (old model, v2tag/5) | same as above | Audit record in `.spthy`; see `MISMATCH NOTE` comment |
| (overwritten) | first version of `kci_ea_uei_kci_proper` | `falsified (12 steps)` | `CorruptEP(UEi,mIsec)` → Mi leaked → forged `V2`; guard corrected to add `not CorruptEP(UEi)` |

**Phase 2 new lemma descriptions:**

- `kci_ea_sb_lt_clean`: Non-KCI fallback for SB-accepting direction.  Both
  `CorruptLT(SB)` and `CorruptEP(UEi)` excluded.  This is NOT the KCI case
  (SB's own LT is clean); it establishes message-origin evidence in the
  no-compromise setting within the compromise model.

- `kci_ea_uei_lt_clean`: Non-KCI fallback for UEi-accepting direction.
  `CorruptLT(UEi)` excluded.  UEi's own LT is clean — also not the KCI case.

- `kci_ea_uei_kci_proper` **(new)**: Trace-level KCI-direction authentication,
  UEi-accepting.  CorruptLT(UEi) freely allowed (KCI scenario).  Guards approximate
  §VII Theorem 3 cleanliness/freshness: NOT CorruptLT(SB) before i; NOT CorruptEP
  on either party before i (party-level, not session-scoped).  Conclusion: prior
  honest send from SB (NOT partnered-instance uniqueness).  NOT a proof of Theorem 3.
  Verified (12 steps).

- `kci_ea_sb_kci_proper` **(new, step 09c)**: Trace-level KCI-direction authentication,
  SB-accepting.  Symmetric to `kci_ea_uei_kci_proper`.  CorruptLT(SB) freely allowed.
  Guards: NOT CorruptEP on either party before i; NOT CorruptLT(UEi) before i.
  The DH binder in revised v1tag/6 closes the old forgery attack (CDH; mBsec excluded).
  Verified (11 steps).  Was FALSIFIED (7 steps) in the old model (v1tag/4).

- `executability_with_uei_lt_corrupt` **(new, step 04b)**: KCI-direction sanity check.
  Both AcceptSB and AcceptUEi fire AND CorruptLT(UEi) fires before UEi accepts (c < j).
  Witnesses the KCI timing required by §VII G0.  Verified (11 steps).

- `fresh_secrecy_sb_kci`: Supplementary trace-level PFS-style secrecy, SB-accepting.
  Not anchored to Theorem 4 (which covers only the UEi-accepting direction).
  LT corruption freely allowed (both parties).  Requires both EPs globally
  uncompromised.  Stronger than Theorem 4's freshness conditions; not directly
  claimed in §VII.  Party-level EP guards — see claims map §Encoding gaps.

- `fresh_secrecy_uei_kci`: Supplementary trace-level PFS-style secrecy, UEi-accepting.
  Stronger than Theorem 4's freshness scope (LT corruption fully unrestricted;
  Theorem 4 requires SB's LT clean before acceptance).  Both EPs globally clean.
  NOT a proof of Theorem 4: no Reveal/Test oracle; party-level EP guards.

- `kci_ake_secrecy_uei_t4` **(new, step 12)**: Trace-level KCI-direction secrecy,
  UEi-accepting, Theorem 4-adjacent guards.  NOT a proof of Theorem 4.
  Guards: NOT CorruptEP(UEi) global; NOT CorruptEP(SB) global; NOT CorruptLT(SB)
  before acceptance.  CorruptLT(UEi) freely allowed.  No Reveal/Test oracle;
  party-level EP guards.  Logically implied by `fresh_secrecy_uei_kci`; retained
  for a directly citable restricted result.  Verified (12 steps).

---

## Relationship to Milestone-1 artifacts

| Artifact | Milestone 1 | Milestone 2 |
|---|---|---|
| Model | `cahake_abstract.spthy` | `ssin_cahake_core.spthy` + `_extended.spthy` + `_compromise.spthy` |
| Proof scripts | `run_proofs.sh` | `run_ssin_proofs.sh`, `run_ssin_extended_proofs.sh`, `run_ssin_compromise_proofs.sh` |
| Manifest | `ARTIFACT_MANIFEST.md` | `ARTIFACT_MANIFEST_M2.md` (this file) |
| Claims map | `CLAIMS_MAP.md` | `ssin_claims_map.md` |
| Flow map | `FLOW_MAP.md` | `ssin_flow_map.md` |

The Milestone-1 abstract model and Milestone-2 instantiated models are
independent.  Do not conflate claims across the two.

---

## Phase delta notes

| File | Content |
|---|---|
| `KCI_SCOPE_DELTA.md` | Re-baseline of KCI theorem scope against cakake-2nd.pdf; PDF-to-model condition map; falsification analysis; steps 04b and 12 added |
| `PFS_DELTA.md` | PFS phase closure; CDH argument; freshness encoding gap; why no new lemmas are needed; safe wording |
| *(this manifest, 2026-04-11 pass)* | DH-binder re-validation: v1tag/4→v1tag/6, v2tag/5→v2tag/6; all three model files updated; step 09c (`kci_ea_sb_kci_proper`, verified 11 steps) added; all step counts refreshed |
| *(artifact-hygiene pass)* | Theorem overclaim removal: `run_ssin_compromise_proofs.sh` step comments and expected-results table relabeled; `fresh_secrecy_*` lemma descriptions in model and manifest updated from "Theorem 4 proof anchor" to "supplementary trace-level"; old-model falsification logs renamed `old_model_08_kci_ea_sb_core.log`, `old_model_09_kci_ea_uei_core.log`; this manifest updated |

---

## Out of scope (explicit)

- Section VI-E batch verification and Theorem 5
- The full Section VII compromise game (quantitative bounds, Test-query AKE
  secrecy, partnered-instance session identifiers)
- KCI-resilient EA for the SB-accepting direction under CorruptLT(SB) with the
  OLD v1tag/4 model (falsified; audit record in commented-out lemma; attack closed
  by DH binder — see `kci_ea_sb_kci_proper` and `ssin_claims_map.md` mismatch note)
- User anonymity and Unlinkability (see `ssin_cahake_privacy_equiv.spthy`)
- Type-I / Type-II CLC adversary split (CLC key structure collapsed in
  `InitEntity`; exposing KGC master secret not modeled)
