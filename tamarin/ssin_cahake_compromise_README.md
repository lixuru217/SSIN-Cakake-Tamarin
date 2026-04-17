# SSIN-Cahake Compromise-Aware Model (Section VI-C / VI-D)

## Scope
This artifact contains the Priority-2 compromise-aware instantiation of the SSIN-Cahake core handshake:

- `ssin_cahake_compromise.spthy`
- `run_ssin_compromise_proofs.sh`
- `ssin_compromise_proof_logs/`

Scope is explicitly limited to Sections VI-C (Pre-Authentication) and VI-D (Mutual Authentication and Key Exchange) of `cakake-2nd.pdf`, with compromise interfaces aligned to Section VII. It does **not** cover Section IV-V abstract protocol artifacts, Section VI-E batch verification, or Theorem 5.

## Model Notes
`ssin_cahake_compromise.spthy` extends `ssin_cahake_core.spthy` with:

- `Compromise_LT(P)` oracle that outputs long-term key material (`CorruptLT(P)`).
- `Compromise_EP_UEi` and `Compromise_EP_SB` oracles that output ephemeral DH secrets (`CorruptEP(UEi, mIsec)` / `CorruptEP(SB, mBsec)`).
- Two protocol facts persistently recording ephemeral secrets to support the EP-compromise rules.

The protocol core (Sections VI-C and VI-D message flow), replay checks, and proof targets remain tied to this SSIN-Cahake instantiation.

### Disclosure constraints used in this artifact
- `CheckTS*` are annotation/action facts only; they are not backed by protocol-time restrictions.
- Replay protection for SB acceptance is provided via fresh timestamp symbols (`~TS5`, `~TS6`) through `FreshTS*` and the trace rules.
- UEi is assumed to have `DB` and `pkSB` before starting.
- `CacheUEi` is a passive trace annotation only.
- The model uses party-level, not per-instance, cleanliness approximations for some EP-reveal assumptions.

## Reproducibility

### Environment snapshot
- Tamarin: `/usr/local/bin/tamarin-prover`
- Tamarin version: `1.12.0`
- Maude: `/usr/local/Cellar/maude/2.7.1_1/bin/maude` (`2.7.1`)
- Graphviz: `/usr/local/bin/dot`

### Commands

```sh
cd tamarin
./run_ssin_compromise_proofs.sh
```

The script writes logs to `ssin_compromise_proof_logs/` and runs parse-only, precompute, and lemma-by-lemma proof invocations.

## Proof status

Canonical logs are in `ssin_compromise_proof_logs/` and currently record 12 active steps. In the active current model (v1tag/6, v2tag/6 with DH binders), the key outcomes are:

- `01_parse_only.log`: parse.
- `02_wellformedness.log`: precompute.
- `03_executability_kci.log`: verified.
- `04_executability_with_lt_corrupt.log`: verified.
- `04b_executability_with_uei_lt_corrupt.log`: verified.
- `05_no_replay_sb_accept_core.log`: verified.
- `06_no_replay_uei_accept_core.log`: verified.
- `07_no_inconsistent_acceptance_core.log`: verified.
- `08_kci_ea_sb_lt_clean.log`: verified.
- `09_kci_ea_uei_lt_clean.log`: verified.
- `09b_kci_ea_uei_kci_proper.log`: verified (trace-level KCI-Resilient Explicit Authentication proxy, UEi-accepting).
- `09c_kci_ea_sb_kci_proper.log`: verified (supplementary trace-level KCI-Resilient Explicit Authentication proxy, SB-accepting).
- `10_fresh_secrecy_sb_kci.log`: verified (supplementary).
- `11_fresh_secrecy_uei_kci.log`: verified (supplementary).
- `12_kci_ake_secrecy_uei_t4.log`: verified (trace-level secrecy proxy, UEi-accepting).

## Relation to previous artifacts

This folder keeps other artifact READMEs for core and privacy models separately:

- `ssin_cahake_core_README.md`
- `ssin_cahake_privacy_README.md`

`ARTIFACT_MANIFEST_COMPROMISE.md` was removed from this public package; this file serves as its replacement for the uploaded repository.
