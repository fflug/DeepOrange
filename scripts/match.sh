#!/usr/bin/env bash
# Plays the engine in this checkout against a baseline engine with
# cutechess-cli and reports the score and the Elo difference.
#
# Usage: scripts/match.sh BASELINE_DIR [GAMES]
#
#   BASELINE_DIR  directory holding the baseline's deep-orange.sh: an
#                 unpacked release, or a checkout such as one made with
#                 git worktree add ../baseline v0.1.0
#   GAMES         number of games, rounded up to an even number so that
#                 each opening is played once with each colour (default 100)
#
# Environment:
#   CUTECHESS      cutechess-cli executable (default: cutechess-cli)
#   CONCURRENCY    games played at once (default: number of CPUs)
#   TC             time control in cutechess-cli notation (default: 40/60,
#                  60 seconds for every 40 moves)
#   OUT            directory for the PGN and the log (default: matches/results)
#   BASELINE_NAME  name of the baseline in the results (default: the
#                  directory name)
#
# Draws are adjudicated once both engines see the game as level for 8
# moves after move 40, and resignations once one side is 8 pawns behind
# for 4 moves, which keeps long, decided games from using up the time.

set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    sed -n '2,/^$/s/^# \{0,1\}//p' "$0" >&2
    exit 2
fi

root="$(cd "$(dirname "$0")/.." && pwd)"
baseline="$(cd "$1" && pwd)"
games="${2:-100}"
rounds=$(( (games + 1) / 2 ))

cutechess="${CUTECHESS:-cutechess-cli}"
concurrency="${CONCURRENCY:-$(nproc)}"
tc="${TC:-40/60}"
out="${OUT:-$root/matches/results}"
baseline_name="${BASELINE_NAME:-$(basename "$baseline")}"

if [ ! -x "$baseline/deep-orange.sh" ]; then
    echo "match.sh: no executable deep-orange.sh in $baseline" >&2
    exit 2
fi

mkdir -p "$out"

"$cutechess" \
    -engine name="Deep Orange (current)" cmd="$root/deep-orange.sh" \
    -engine name="Deep Orange ($baseline_name)" cmd="$baseline/deep-orange.sh" \
    -each proto=uci tc="$tc" \
    -openings file="$root/matches/openings.pgn" format=pgn order=random \
    -games 2 -rounds "$rounds" -repeat \
    -concurrency "$concurrency" \
    -draw movenumber=40 movecount=8 score=10 \
    -resign movecount=4 score=800 \
    -maxmoves 200 \
    -recover \
    -ratinginterval 10 \
    -pgnout "$out/games.pgn" \
    | tee "$out/match.log"
