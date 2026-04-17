# ssin_cahake_core_extended.spthy README

## Scope

This artifact describes `ssin_cahake_core_extended.spthy`, the extended instantiated
SSIN-Cahake core model for Sections VI-C (Pre-Authentication) and VI-D (Mutual
Authentication and Key Exchange) of `cakake-2nd.pdf`.

The model is a Priority-1 extended variant of `ssin_cahake_core.spthy` and includes
the same protocol core with additional end-to-end checks focused on replay and
key-confidentiality consistency.

## Model focus

`ssin_cahake_core_extended.spthy` targets:

- The public-channel VI-C/VI-D handshake flow of Section VI.
- Trace properties under no-compromise assumptions.
- Extended protocol properties beyond the baseline core artifact.

## Added proof objectives in the extended model

Compared with `ssin_cahake_core.spthy`, the extended file includes these additional
lemma objectives:

- `no_replay_uei_accept_core`
- `mutual_auth_consistent_core`
- `full_session_agree_uei_core`
- `no_key_splitting`

## What this artifact does not prove

- Section VI-E batch verification.
- KCI / compromise-oracle proofs (covered in `ssin_cahake_compromise.spthy`).
- Theorem-5 style claims.
- PFS under explicit Reveal/StateReveal queries.
- Full computational CK-derived theorem statements.

## Main assumptions carried into the model

- `TS1`–`TS6` are modeled as fresh symbolic values.
- `CheckTS4`, `CheckTS5`, `CheckTS6` are action/instrumentation facts only.
- Replay resistance for SB/UEi accept is represented via freshness structure
  (`~TS5`, `~TS6`) and protocol ordering.
- UEi is assumed to know SB domain/context and public key to initiate pre-auth.
- `CacheUEi` is a passive trace annotation in this model.

## Reproducibility

Run from `tamarin/`:

```sh
./run_ssin_extended_proofs.sh
```

The script writes logs to `ssin_extended_proof_logs/` and runs parse, precompute,
and lemma-by-lemma proof commands for:

- `ssin_cahake_core_extended.spthy`
- `executability_ssin_core`
- `session_key_secrecy_sb_core`
- `session_key_secrecy_uei_core`
- `agreement_sb_on_uei_core`
- `agreement_uei_on_sb_core`
- `no_replay_sb_accept_core`
- `no_inconsistent_acceptance_core`
- `no_replay_uei_accept_core`
- `mutual_auth_consistent_core`
- `full_session_agree_uei_core`
- `no_key_splitting`

## Artifact usage guidance

Use this README as the companion documentation for `ssin_cahake_core_extended.spthy`.
For the baseline model documentation, use `ssin_cahake_core_README.md`.
For compromise-aware coverage, use `ssin_cahake_compromise_README.md`.
