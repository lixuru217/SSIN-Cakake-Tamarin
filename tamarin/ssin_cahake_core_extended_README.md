# SSIN-Cahake Core Extended Tamarin Model

## Scope

This artifact models the instantiated SSIN-Cahake core handshake under Sections VI-C and VI-D of `cakake-2nd.pdf`:

- `Pre-Authentication`
- `Mutual Authentication and Key Exchange`

`ssin_cahake_core_extended.spthy` is the Priority-1 extended instantiation of the core model and adds replay / mutual-auth coverage beyond the baseline core file.

## What this extended model adds

Compared with `ssin_cahake_core.spthy`, the extended model includes the same protocol core and additionally proves:

- `no_replay_uei_accept_core`
- `mutual_auth_consistent_core`
- `full_session_agree_uei_core`
- `no_key_splitting`

## Out-of-scope (this artifact)

- Section VI-E batch verification
- KCI / compromise-oracle claims from Section VII
- Theorem-5 style claims
- Full session-identifier or CK-theorem reconstruction proofs
- PFS under explicit Reveal/StateReveal oracle conditions

## Reproducibility

Run from the `tamarin/` directory:

```sh
./run_ssin_extended_proofs.sh
```

This executes parser, well-formedness, and dedicated lemma proofs for the extended core model, writing results to `ssin_extended_proof_logs/`.

## What is proven in this artifact (current package)

The extended run validates core protocol behavior plus the additional Priority-1 lemmas listed above in the same VI-C/VI-D instantiation assumptions as the baseline core model.

## Protocol/Model assumptions to keep in mind

- `TS5` and `TS6` replay resistance is provided through fresh-value modeling of timestamps.
- `CheckTS4`, `CheckTS5`, and `CheckTS6` are action/instrumentation annotations.
- UEi is assumed to know SB domain/public key context required to start pre-authentication.
- `CacheUEi` is a passive trace annotation and is not used as a cryptographic check.

## Suggested wording

> `ssin_cahake_core_extended.spthy` provides an extended priority-1 instantiation proof artifact for Sections VI-C and VI-D of the SSIN-Cahake model. In addition to the baseline core checks, it includes replay, mutual-auth consistency, full-session agree-side, and key-splitting safety coverage.
