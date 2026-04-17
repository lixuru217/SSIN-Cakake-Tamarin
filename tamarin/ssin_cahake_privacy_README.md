# ssin_cahake_privacy.spthy — Public-Channel Anonymity Artifact

## Purpose

`ssin_cahake_privacy.spthy` is a user-facing supplementary privacy artifact for the instantiated SSIN-Cahake protocol.

It proves a **public-channel user-anonymity** property in Tamarin `--diff` mode, and is a separate artifact from the Phase-2 trace-logic files:

- `ssin_cahake_core.spthy`
- `ssin_cahake_compromise.spthy`

It does not modify those artifacts.

## Scope and boundary

The file models the public-channel transcript of the core handshake and compares two worlds that differ only in the user identity/key mapping:

- World L: user `$UEiL` with key `~ltkL`
- World R: user `$UEiR` with key `~ltkR`

## In-scope

- Public-channel messages only:
  - `Out(<Qi, V1, TS5>)`
  - `Out(<QB, V2, TS6>)`
- User anonymity against a public-channel adversary under the stated symbolic abstractions.

## Out-of-scope

- Tunnel-side anonymity (N1–N4 are abstracted as confidential setup)
- Session unlinkability
- SA-observed identities
- Theorem-level computational claims from the paper
- Full protocol-level deployment properties beyond this core anonymity abstraction

## What is modeled

- Two worlds are used in the diff proof:
  - user identity and long-term key are swapped across worlds
  - SB is unchanged
- `v1anon` / `v2anon` are model-level versions that do not expose user identity directly.
- Pre-authentication messages are abstracted by internal setup so tunnel contents are not exposed on the public channel.

## Proven statement (summary)

- Parsing and precomputation succeed under `--diff`.
- Executability succeeds in both worlds.
- `DiffLemma Observational_equivalence` is verified.

The resulting claim is that, in this model, a public-channel observer cannot distinguish the two worlds and therefore cannot tell whether `$UEiL` or `$UEiR` is participating, under the artifact’s assumptions.

## Command set (reproducible)

Run from `tamarin/`:

```sh
./run_ssin_privacy_proofs.sh
```

This is equivalent to:

```sh
tamarin-prover --diff --parse-only ssin_cahake_privacy.spthy
tamarin-prover --diff --precompute-only ssin_cahake_privacy.spthy
tamarin-prover --diff --prove=privacy_executability ssin_cahake_privacy.spthy
tamarin-prover --diff --prove=Observational_equivalence ssin_cahake_privacy.spthy
```

## Artifact notes

- This README is intended to be user-facing and does not include solver-debugging workflow details.
- For modeling or implementation issues, refer to repository history and script comments.

## Recommended wording

Use this phrasing in reports:

> "A supplementary Tamarin differential-equivalence artifact (`ssin_cahake_privacy.spthy`, `--diff` mode) verifies public-channel observational equivalence for two user identities.
> No unlinkability claim is made, and scope is explicitly limited to the modeled public-channel exchange (tunnels are abstracted as confidential setup)."
