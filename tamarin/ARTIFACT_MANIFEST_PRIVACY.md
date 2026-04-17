# Privacy Artifact Manifest — Phase 3a

## Scope

This manifest covers only the Phase 3a privacy artifact.
Phase 1 and Phase 2 artifacts (trace-property models) are covered by their
own manifests (`ARTIFACT_MANIFEST.md`, `ARTIFACT_MANIFEST_M2.md`,
`ARTIFACT_MANIFEST_COMPROMISE.md`) and are **not** modified by Phase 3a.

---

## Toolchain

- `tamarin-prover`: `/usr/local/bin/tamarin-prover`
- `tamarin-prover --version`: `1.12.0`
- compiled at: `2026-04-05 15:24:50.862807 UTC`
- `maude`: `/usr/local/Cellar/maude/2.7.1_1/bin/maude`
- `maude version`: `2.7.1`
- Mode: `--diff` (observational-equivalence mode)

---

## New files created in Phase 3a

| File | Purpose | Status |
|---|---|---|
| `ssin_cahake_privacy.spthy` | Phase 3a observational-equivalence skeleton: public-channel user anonymity | **New — runnable** |
| `ssin_cahake_privacy_README.md` | Documentation for privacy artifact | **New** |
| `ARTIFACT_MANIFEST_PRIVACY.md` | This manifest | **New** |
| `run_ssin_privacy_proofs.sh` | Automated proof script for Phase 3a | **New** |
| `PHASE3_STATUS.md` | Phase 3 implementation status | **New** |

## New files created in Phase 3b analysis (2026-04-13)

| File | Purpose | Status |
|---|---|---|
| `ssin_cahake_privacy_unlinkability.spthy` | Phase 3b diagnostic standard-mode artifact: structural key properties and `pku_not_adversary_derivable` | **New — runnable (standard mode, not --diff)** |
| `ssin_cahake_privacy_unlinkability_diff.spthy` | Phase 3b real --diff mode unlinkability experiment: same user × 2 sessions vs 2 different users × 1 session | **New — runnable (--diff mode)** |
| `PHASE3_CONTINUATION_NOTE.md` | Phase 3b QB re-analysis findings and observation-boundary correction record | **New** |
| `PHASE3B_EQUIV_NOTE.md` | Phase 3b diff experiment: what was compared, result, claim discipline | **New** |

## Existing files NOT modified

| File | Status |
|---|---|
| `ssin_cahake_core.spthy` | Frozen — Phase 2 |
| `ssin_cahake_core_extended.spthy` | Frozen — Phase 2 |
| `ssin_cahake_compromise.spthy` | Frozen — Phase 2 |
| `ssin_cahake_privacy_equiv.spthy` | Retained — empty Phase 3 skeleton (documentation only) |
| `ssin_claims_map.md` | Frozen — Phase 2 claims map |
| All other tamarin/ files | Unchanged |

---

## Proof status for Phase 3a

### ssin_cahake_privacy.spthy (run with --diff flag)

| Step | Check | Result | Timing |
|---|---|---|---|
| 01 | `--diff --parse-only` | **passed** | < 1 s |
| 02 | `--diff --precompute-only` | **passed** | ~10 s |
| 03 | `privacy_executability [left]` | **verified (11 steps)** | ~10 s (total run) |
| 04 | `privacy_executability [right]` | **verified (11 steps)** | ~10 s (total run) |
| 05 | `DiffLemma Observational_equivalence` | **verified (3274 steps)** | Automated proof succeeded |

Notes on precomputation:
- LHS raw sources: 16 cases, deconstructions complete
- RHS raw sources: 16 cases, deconstructions complete
- Both worlds saturate in Step 1 (Max 5 → Done immediately)

---

## Proof status for Phase 3b

### ssin_cahake_privacy_unlinkability.spthy (standard mode — diagnostic)

| Step | Check | Result |
|---|---|---|
| 01 | `--prove` | all lemmas verified |
| — | `executability` | **verified** |
| — | `same_user_same_pku` | **verified** |
| — | `pku_identifies_user` | **verified** |
| — | `pku_not_adversary_derivable` | **verified** — PKi_derived is NOT adversary-derivable |

### ssin_cahake_privacy_unlinkability_diff.spthy (--diff mode — unlinkability game)

| Step | Check | Result | Timing |
|---|---|---|---|
| 01 | `--diff --parse-only` | **passed** | < 1 s |
| 02 | `--diff --precompute-only` | **passed** — 12 source cases, complete | < 5 s |
| 03 | `unlink_executability [left]` | **verified (6 steps)** | 213 s (total run) |
| 04 | `unlink_executability [right]` | **verified (6 steps)** | 213 s (total run) |
| 05 | `DiffLemma Observational_equivalence` | **verified (21140 steps)** | 213 s (total run) |

Left world: same user runs two sessions.  Right world: two different users, one session each.
Registration is background state in both worlds (no `Out('g'^~xu)`).

---

## Theorem-boundary note

These artifacts:
- Do **NOT** prove Theorem 3 (KCI-Resilient Explicit Authentication)
- Do **NOT** prove Theorem 4 (KCI-Resilient AKE Secrecy)
- Do **NOT** prove Theorem 5 (Batch Verification Soundness)
- Do **NOT** constitute theorem-exact Tamarin verification of user anonymity
- Do **NOT** constitute theorem-exact Tamarin verification of unlinkability

These artifacts provide:
- Verified public-channel single-session anonymity (Phase 3a, DiffLemma 3274 steps)
- Verified public-channel cross-session unlinkability (Phase 3b, DiffLemma 21140 steps)
- Honest documentation of modeling abstractions and scope boundary
- All results hold under stated abstractions: CLC key collapsed, tunnels abstracted, identity in opaque hashes

---

## Rerun commands

```sh
# From tamarin/ directory:
./run_ssin_privacy_proofs.sh

# Phase 3a (single-session anonymity):
tamarin-prover --diff --parse-only                ssin_cahake_privacy.spthy
tamarin-prover --diff --precompute-only           ssin_cahake_privacy.spthy
tamarin-prover --diff --prove=privacy_executability ssin_cahake_privacy.spthy

# Phase 3b diagnostic (standard mode):
tamarin-prover --prove ssin_cahake_privacy_unlinkability.spthy

# Phase 3b unlinkability game (--diff mode):
tamarin-prover --diff --parse-only        ssin_cahake_privacy_unlinkability_diff.spthy
tamarin-prover --diff --precompute-only   ssin_cahake_privacy_unlinkability_diff.spthy
tamarin-prover --diff --prove             ssin_cahake_privacy_unlinkability_diff.spthy
```

---

## Relation to Phase 2 freeze

Phase 2 is frozen.  Phase 3a creates new files only.  No Phase 2 artifact
was modified.  The `ssin_cahake_privacy_equiv.spthy` empty skeleton is
retained as-is.

---

## Privacy boundary summary

Per cakake-2nd.pdf Section IV-A:
> "Our anonymity claims are defined with respect to the public channel since
> the collaborator observes identities inside the tunnels."

This artifact models only the public channel (Qi, V1, TS5 and QB, V2, TS6).
Tunnel anonymity (involving SA and PIDi = IDi ⊕ H1(Mi)) is outside scope.
