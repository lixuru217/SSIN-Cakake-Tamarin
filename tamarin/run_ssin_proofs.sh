#!/bin/zsh

# Milestone-2 proof script for the instantiated SSIN-Cahake core model.
# Target: tamarin/ssin_cahake_core.spthy (Section VI-C and VI-D only)
# Scope: NOT the abstract Cahake protocol in cahake_abstract.spthy.
#
# Usage:
#   ./run_ssin_proofs.sh
#   LOG_DIR=/path/to/logs ./run_ssin_proofs.sh
#
# Logs are written to tamarin/ssin_proof_logs/ by default (repo-local).
# Each lemma is proved in a dedicated --prove=<lemma> invocation.
# In any individual log file, non-target lemmas appear as
# "analysis incomplete (1 steps)" by design; the combined verified status
# is the union of the nine runs in this script.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
MODEL="$SCRIPT_DIR/ssin_cahake_core.spthy"
TAMARIN_BIN="${TAMARIN_BIN:-/usr/local/bin/tamarin-prover}"
FALLBACK_TAMARIN_BIN="/tmp/tamarin-bin/tamarin-prover"
MAUDE_BIN="${MAUDE_BIN:-/usr/local/Cellar/maude/2.7.1_1/bin/maude}"
DOT_BIN="${DOT_BIN:-/usr/local/bin/dot}"
LOG_DIR="${LOG_DIR:-$SCRIPT_DIR/ssin_proof_logs}"

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

# Step 01 — parse-only: verify the theory loads without error.
run_step 01 parse_only --parse-only

# Step 02 — wellformedness: precompute sources and check for warnings.
run_step 02 wellformedness --quit-on-warning --precompute-only

# Steps 03-09 — one dedicated proof run per lemma.
# --derivcheck-timeout=0 prevents the default derivation-check timeout from
# aborting successful proof runs under --quit-on-warning.
run_step 03 executability_ssin_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=executability_ssin_core

run_step 04 session_key_secrecy_sb_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=session_key_secrecy_sb_core

run_step 05 session_key_secrecy_uei_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=session_key_secrecy_uei_core

run_step 06 agreement_sb_on_uei_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=agreement_sb_on_uei_core

run_step 07 agreement_uei_on_sb_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=agreement_uei_on_sb_core

run_step 08 no_replay_sb_accept_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=no_replay_sb_accept_core

run_step 09 no_inconsistent_acceptance_core \
  --derivcheck-timeout=0 --quit-on-warning \
  --prove=no_inconsistent_acceptance_core

cat <<EOF

Completed all Milestone-2 SSIN-Cahake core proof runs.
Logs are in:
  $LOG_DIR

Expected verified results:
  03_executability_ssin_core:          verified (10 steps)
  04_session_key_secrecy_sb_core:      verified (7 steps)
  05_session_key_secrecy_uei_core:     verified (7 steps)
  06_agreement_sb_on_uei_core:         verified (8 steps)
  07_agreement_uei_on_sb_core:         verified (8 steps)
  08_no_replay_sb_accept_core:         verified (2 steps)
  09_no_inconsistent_acceptance_core:  verified (4 steps)
EOF
