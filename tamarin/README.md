# Abstract Cahake Tamarin Model

## Modeling plan
1. Model only the abstract Cahake roles `I`, `R`, and the semi-honest relay `C`.
2. Collapse the AEAD-protected tunnels into ideal confidential/authentic relay rules and keep only the public authentication phase adversarial.
3. Represent `KEYSHAREGEN` and `SHAREDSECRET` with symbolic Diffie-Hellman, `AUTHTAG` with symbolic signatures, and `KDF` as an abstract constructor.
4. Make `Bind`, `Transcript`, `t5`, `t6`, and `sid` explicit so executability, secrecy, agreement, and replay/consistency lemmas can be stated directly.

## Files

### Milestone-1 baseline (abstract Cahake, no compromise)
- `cahake_abstract.spthy`: minimal milestone-1 symbolic model.
- `run_proofs.sh`: reproducible milestone-1 proof rerun script.
- `proof_report.md`: frozen proof environment, commands, and statuses (includes KCI-extension addendum).
- `ambiguities.md`: manuscript ambiguities and model choices.
- `response_r2_3_paragraph.md`: manuscript-ready response-letter paragraph.
- `paper_subsection_draft.md`: short paper-ready subsection draft.

### Restricted-compromise / KCI-aligned extension (abstract Cahake + compromise oracles)
- `cahake_abstract_kci.spthy`: KCI-aligned extension adding `Compromise_LT`, `Compromise_EP_I/R`, and lemma analogues of Theorems 1 and 2.
- `run_abstract_kci_proofs.sh`: 10-step proof rerun script.
- `abstract_kci_proof_logs/`: log directory.
- `ARTIFACT_MANIFEST_ABSTRACT_KCI.md`: manifest with per-lemma status.
- `ABSTRACT_KCI_CLAIMS_MAP.md`: claim-to-lemma mapping and wording rules.
- `abstract_kci_README.md`: standalone readme for the extension.

## Assumptions
- This symbolic model is a milestone-1 complement to the manuscript's CK-derived AKE model with a passive collaborator and AEAD-protected pre-authentication tunnels.
- Scope is the abstract Cahake protocol only, not the full SSIN-Cahake instantiation.
- `C` is semi-honest and non-colluding.
- Active deviation by `C` is out of scope in this baseline model.
- The tunnels `<I <-> C>` and `<C <-> R>` are modeled as ideal confidential/authentic relays.
- The public channel `<I <-> R>` is adversarial.
- `t5` and `t6` are modeled as fresh nonces, not wall-clock timestamps.
- `Bind` is modeled as `<I, R, XI, XR, ctxI, ctxR>`.
- `Transcript` is modeled as `<Bind, QI, sigmaI, t5, QR, sigmaR, t6>`.
- `sid` is a helper identifier defined as `<Bind, QI, QR>`.
- No long-term-key compromise, ephemeral compromise, or KCI oracle layer is included in the milestone-1 baseline.
- The KCI-aligned extension (`cahake_abstract_kci.spthy`) adds these; see `abstract_kci_README.md`.

## Commands
Environment observations recorded on 2026-04-05:

```sh
ls -l /usr/local/bin/tamarin-prover
tamarin-prover --version
command -v maude
ls -l /usr/local/bin/maude
brew list --versions tamarin-prover/tap/maude
brew info tamarin-prover/tap/maude
command -v ghc
command -v dot
uname -m
xcodebuild -version
```

Proof commands run in this environment:

```sh
tamarin-prover --parse-only cahake_abstract.spthy

tamarin-prover --quit-on-warning --precompute-only cahake_abstract.spthy

/tmp/tamarin-bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --quit-on-warning --prove=executability cahake_abstract.spthy

/tmp/tamarin-bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --quit-on-warning --prove=session_key_secrecy_r cahake_abstract.spthy

/tmp/tamarin-bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --quit-on-warning --prove=session_key_secrecy_i cahake_abstract.spthy

/tmp/tamarin-bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --quit-on-warning --prove=agreement_r_on_i cahake_abstract.spthy

/tmp/tamarin-bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --quit-on-warning --prove=agreement_i_on_r cahake_abstract.spthy

/tmp/tamarin-bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --quit-on-warning --prove=no_replay_responder_accept cahake_abstract.spthy

/tmp/tamarin-bin/tamarin-prover \
  --with-maude=/usr/local/Cellar/maude/2.7.1_1/bin/maude \
  --with-dot=/usr/local/bin/dot \
  --quit-on-warning --prove=no_inconsistent_acceptance cahake_abstract.spthy
```

## Tool version and status
- `tamarin-prover`: installed persistently at `/usr/local/bin/tamarin-prover`.
- `tamarin-prover --version` succeeds from the default shell `PATH` and reports:
  - Tamarin version `1.12.0`
  - Maude version `2.7.1`
  - compiled at `2026-04-05 15:24:50.862807 UTC`
- `maude`: available from the default shell `PATH` as `/usr/local/bin/maude`, linked to `/usr/local/Cellar/maude/2.7.1_1/bin/maude`.
- Homebrew reports `tamarin-prover/tap/maude` formula `stable 3.5.1`, with installed cellar version `2.7.1_1`.
- `dot`: available at `/usr/local/bin/dot`.
- `ghc`: not on the default `PATH`.
- Host observations: `uname -m` reports `arm64`, while Homebrew builds under `/usr/local` use an `x86_64` Rosetta environment.

## Environment Status
- The proof environment is now directly usable from the default shell `PATH`.
- The previous blocker was a broken `/usr/local/bin/maude` symlink and a temporary `/tmp` Tamarin binary.
- Those were repaired by:
  - installing `tamarin-prover` to `/usr/local/bin/tamarin-prover`
  - relinking `/usr/local/bin/maude` to `/usr/local/Cellar/maude/2.7.1_1/bin/maude`
- `tamarin-prover --quit-on-warning --precompute-only cahake_abstract.spthy` now succeeds without any explicit `--with-maude` or `--with-dot` flags.
- Manual intervention on the model side was limited to:
  - renaming the internal ephemeral-secret variables to `xIsec` and `xRsec` to avoid a Tamarin capitalization/sort clash with `XI` and `XR`
  - fixing node-variable equality syntax in `UniqueRegistration` and `no_replay_responder_accept`

## Check and Lemma Status
All checks below were run against the current [cahake_abstract.spthy](/Users/lixuru/Documents/Stu_codes/Cakake-Tamarin/tamarin/cahake_abstract.spthy) with Tamarin `1.12.0` and Maude `2.7.1`.

| Check or lemma | Status | Note |
|---|---|---|
| `parse-only` | passed | `--parse-only` exited successfully and loaded `Theory cahake_abstract`. |
| `wellformedness` | passed | `--quit-on-warning --precompute-only` exited successfully; raw/refined sources both reported `18 cases, deconstructions complete`. |
| `executability` | verified | Verified in `10 steps`; summary processing time `9.43s`. |
| `session_key_secrecy_r` | verified | Verified in `4 steps`; summary processing time `17.04s`. |
| `session_key_secrecy_i` | verified | Verified in `4 steps`; summary processing time `16.80s`. |
| `agreement_r_on_i` | verified | Verified in `5 steps`; summary processing time `17.99s`. |
| `agreement_i_on_r` | verified | Verified in `5 steps`; summary processing time `18.04s`. |
| `no_replay_responder_accept` | verified | Verified in `2 steps`; summary processing time `17.76s`. |
| `no_inconsistent_acceptance` | verified | Verified in `4 steps`; summary processing time `18.88s`. |

## Known limits
- The current machine uses `arm64` macOS, but the available Homebrew toolchain under `/usr/local` still reflects an `x86_64` Rosetta layout.
- The original build artifact was produced under `/tmp`, but the runnable binary has now been copied into `/usr/local/bin` for persistent use.
- The model idealizes the collaborator-side tunnels and does not expose ciphertext metadata.
- The baseline model does not include key-compromise or KCI oracle extensions from the collaborator-augmented CK-derived AKE model.
- Delay/drop behavior by `C` is not modeled.
- If the manuscript later fixes a different `Transcript` encoding or a stronger session-identifier definition, the lemmas should be re-run after a small alignment update.
