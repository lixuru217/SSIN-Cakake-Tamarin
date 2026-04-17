#!/bin/zsh

# Proof script for the Priority-2 compromise-aware SSIN-Cahake model.
# Target: tamarin/ssin_cahake_compromise.spthy (Section VI-C and VI-D,
#         with Corrupt / EP-compromise oracles aligned with Section VII)
#
# Usage:
#   ./run_ssin_compromise_proofs.sh
#   LOG_DIR=/path/to/logs ./run_ssin_compromise_proofs.sh
#
# Logs are written to tamarin/ssin_compromise_proof_logs/ by default.
# Each lemma is proved in a dedicated --prove=<lemma> invocation.
#
# Note on --derivcheck-timeout=0:
#   The compromise model adds three new rules (Compromise_LT, Compromise_EP_UEi,
#   Compromise_EP_SB) that expand the derivation-check search space.  The flag
#   --derivcheck-timeout=0 disables the default timeout so that longer-running
#   proof searches are not aborted prematurely.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
MODEL="$SCRIPT_DIR/ssin_cahake_compromise.spthy"
TAMARIN_BIN="${TAMARIN_BIN:-/usr/local/bin/tamarin-prover}"
FALLBACK_TAMARIN_BIN="/tmp/tamarin-bin/tamarin-prover"
MAUDE_BIN="${MAUDE_BIN:-/usr/local/Cellar/maude/2.7.1_1/bin/maude}"
DOT_BIN="${DOT_BIN:-/usr/local/bin/dot}"
LOG_DIR="${LOG_DIR:-$SCRIPT_DIR/ssin_compromise_proof_logs}"

if [[ ! -x "$TAMARIN_BIN" && -x "$FALLBACK_TAMARIN_BIN" ]]; then
  TAMARIN_BIN="$FALLBACK_TAMARIN_BIN"
fi

if [[ ! -x "$TAMARIN_BIN" ]]; then
  echo "tamarin-prover not found: $TAMARIN_BIN" >&2
  exit 1
fi

if [[ ! -x "$MAUDE_BIN" ]]; then
  echo "maude not found: $MAUDE_BIN" >&2
  exit 1
fi

if [[ ! -x "$DOT_BIN" ]]; then
  echo "dot not found: $DOT_BIN" >&2
  exit 1
fi

if [[ ! -f "$MODEL" ]]; then
  echo "model not found: $MODEL" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

run_step() {
  local step_id="$1"
  local step_name="$2"
  shift 2

  local log_file="$LOG_DIR/${step_id}_${step_name}.log"

  echo "[$step_id] $step_name"
  echo "  log: $log_file"

  if "$TAMARIN_BIN" \
    --with-maude="$MAUDE_BIN" \
    --with-dot="$DOT_BIN" \
    "$@" \
    "$MODEL" >"$log_file" 2>&1; then
    echo "  exit: 0"
  else
    local status=$?
    echo "  exit: $status" >&2
    echo "  last log lines:" >&2
    tail -n 40 "$log_file" >&2 || true
    exit "$status"
  fi
}

# Step 01 — parse-only
run_step 01 parse_only --parse-only

# Step 02 — wellformedness
run_step 02 wellformedness --quit-on-warning --precompute-only

# Steps 03-04 — sanity / executability checks
run_step 03 executability_kci \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=executability_kci

run_step 04 executability_with_lt_corrupt \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=executability_with_lt_corrupt

# Step 04b — KCI-direction sanity: CorruptLT(UEi) coexists with both accepting.
# This is the Theorem 3/4 KCI scenario and confirms the model is not trivially
# unsatisfiable in the theorem-relevant direction.
run_step 04b executability_with_uei_lt_corrupt \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=executability_with_uei_lt_corrupt

# Steps 05-06 — replay resistance
run_step 05 no_replay_sb_accept_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=no_replay_sb_accept_core

run_step 06 no_replay_uei_accept_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=no_replay_uei_accept_core

# Step 07 — key consistency
run_step 07 no_inconsistent_acceptance_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=no_inconsistent_acceptance_core

# Steps 08-09 — KCI-EA non-KCI fallback lemmas (actor's own LT clean; not theorem-exact)
# Note: kci_ea_sb_FALSIFIED and kci_ea_uei_FALSIFIED are commented out in the
# model — they are falsified under full KCI (actor LT corrupted).  These steps
# prove the provable replacement lemmas that hold when the actor's own LT key
# was NOT corrupted before acceptance.  See MISMATCH NOTE in the model file.
run_step 08 kci_ea_sb_lt_clean \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=kci_ea_sb_lt_clean

run_step 09 kci_ea_uei_lt_clean \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=kci_ea_uei_lt_clean

# Step 09b — KCI-EA trace-level proxy, UEi-accepting direction.
# Corrupt(UEi) allowed (KCI scenario); NOT Corrupt(SB) before i (peer freshness);
# EPs excluded before i (cleanliness approximation — party-level, not session-scoped).
# NOT a proof of Theorem 3 (no unique-partner condition; party-level EP guards).
run_step 09b kci_ea_uei_kci_proper \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=kci_ea_uei_kci_proper

# Step 09c — KCI-EA for the SB-accepting direction (NEW in revised protocol).
# Under the revised v1tag/6 formula (with DH binder Kshared = Mi^mBsec),
# the SB-accepting KCI-EA direction that was FALSIFIED in the old model
# now verifies.  Corrupt(SB) is freely allowed; cleanliness excludes both EPs;
# peer freshness excludes CorruptLT(UEi) before acceptance.
run_step 09c kci_ea_sb_kci_proper \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=kci_ea_sb_kci_proper

# Steps 10-11 — supplementary trace-level secrecy proxies (both EPs clean; LT unrestricted)
run_step 10 fresh_secrecy_sb_kci \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=fresh_secrecy_sb_kci

run_step 11 fresh_secrecy_uei_kci \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=fresh_secrecy_uei_kci

# Step 12 — Theorem 4-adjacent KCI-AKE secrecy trace-level proxy, UEi-accepting.
# Guard conditions approximate §VII Theorem 4: Corrupt(UEi) allowed (KCI);
# NOT Corrupt(SB) before acceptance (freshness); both EPs globally clean.
# NOT a proof of Theorem 4: no Reveal/Test oracle; party-level EP guards (not
# session-scoped StateReveal); quantitative bounds not encoded.
# Logically implied by fresh_secrecy_uei_kci; retained as a citable restricted result.
run_step 12 kci_ake_secrecy_uei_t4 \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=kci_ake_secrecy_uei_t4

cat <<EOF

Completed all Priority-2 compromise-model proof runs.
Logs are in:
  $LOG_DIR

Expected verified results (revised protocol — v1tag/6, v2tag/6 with DH binder):
  03_executability_kci:                   verified
  04_executability_with_lt_corrupt:       verified
  04b_executability_with_uei_lt_corrupt:  verified
  05_no_replay_sb_accept_core:            verified
  06_no_replay_uei_accept_core:           verified
  07_no_inconsistent_acceptance_core:     verified
  08_kci_ea_sb_lt_clean:                  verified
  09_kci_ea_uei_lt_clean:                 verified
  09b_kci_ea_uei_kci_proper:              verified  [trace-level proxy — NOT Theorem 3; UEi-accepting KCI-direction]
  09c_kci_ea_sb_kci_proper:               verified  [supplementary trace-level — SB-accepting KCI-direction; DH binder closes old attack]
  10_fresh_secrecy_sb_kci:                verified  [supplementary trace-level secrecy proxy — SB-accepting; not theorem-exact]
  11_fresh_secrecy_uei_kci:               verified  [supplementary trace-level secrecy proxy — UEi-accepting; not theorem-exact]
  12_kci_ake_secrecy_uei_t4:              verified  [trace-level proxy — NOT Theorem 4; Theorem 4-adjacent guards, UEi-accepting]

Protocol change note (v1tag/4 → v1tag/6, v2tag/5 → v2tag/6):
  The revised cakake-2nd.pdf protocol adds a DH binder Zi = mi*MB to V1 and V2.
  In symbolic DH: Kshared = MB^mIsec = Mi^mBsec = 'g'^(mIsec*mBsec).
  V1 = v1tag(UEi, SB, Mi, MB, Kshared, TS5) — closes SB-accepting KCI-EA attack.
  V2 = v2tag(UEi, SB, Mi, MB, Kshared, TS6) — closes UEi-accepting two-LT attack.

KCI-EA finding summary:
  kci_ea_sb_FALSIFIED   [commented out, old model]: was falsified (7 steps)
    Attack used old v1tag/4: Corrupt(SB) → adec(Qi,ltkSB) = Mi → forge v1tag(UEi,SB,Mi,TS5').
    CLOSED by DH binder in revised v1tag/6: forging also needs Kshared = Mi^mBsec (CDH).
  kci_ea_uei_FALSIFIED  [commented out, old model]: was falsified (12 steps)
    Attack used old v2tag/5: Corrupt(SB)+Corrupt(UEi) → Mi, MB → forge v2tag(UEi,SB,Mi,MB,TS6').
    CLOSED by DH binder in revised v2tag/6: forging also needs Kshared (CDH).
  kci_ea_uei_kci_proper: verified (12 steps)
    True KCI for UEi-accepting: Corrupt(UEi) allowed; NOT Corrupt(SB) before i; EPs clean.
  kci_ea_sb_kci_proper: verified (11 steps)  [NEW]
    True KCI for SB-accepting: Corrupt(SB) allowed; NOT Corrupt(UEi) before i; EPs clean.
    DH binder prevents Mi recovery from sufficing for V1 forgery.

Disclosure:
  These lemmas are trace-level symbolic analogues; they do not verify the
  quantitative probability bounds in Theorems 3 and 4 of Section VII.
  See ssin_cahake_compromise.spthy module comment for full disclosures.
EOF
