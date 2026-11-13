#!/bin/bash
#
# Runs the unit tests of the App and of every module in DaysMarkKit.
#
#   scripts/test.sh                 everything
#   scripts/test.sh <Module>        one module, e.g. DaysMarkCore (or DaysMark for the App)
#
# DESTINATION overrides the simulator (default: the first iPhone on iOS 26 or later), e.g.
# DESTINATION='platform=iOS Simulator,name=iPhone 17'. XCODE_BUILD_ROOT overrides where builds go.
# The last line is always RESULT: ... so tools can read it.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIRST_IPHONE="$(xcrun simctl list devices available | awk '
  /^-- iOS / { split($3, version, "."); usable = version[1] >= 26; next }
  /^--/ { usable = 0; next }
  usable && /iPhone/ && match($0, /[0-9A-F-]{36}/) { print substr($0, RSTART, RLENGTH); exit }
')"
DESTINATION="${DESTINATION:-platform=iOS Simulator,id=$FIRST_IPHONE}"
BUILD_ROOT="${XCODE_BUILD_ROOT:-$HOME/Library/Developer/Xcode/DerivedData}"
ONLY="${1:-}"

failed=()
total=0

run() {
  local name="$1"
  shift
  [[ -n "$ONLY" && "$ONLY" != "$name" ]] && return
  local log
  log="$(mktemp)"
  echo "testing $name"
  if xcodebuild test "$@" -destination "$DESTINATION" \
    -derivedDataPath "$BUILD_ROOT/$name-cli" >"$log" 2>&1; then
    local count
    count="$(grep -Eo 'Test run with [0-9]+ tests' "$log" | grep -Eo '[0-9]+' | tail -1)"
    total=$((total + ${count:-0}))
    echo "  passed ${count:-0}"
  else
    failed+=("$name")
    grep -E "error:|✘" "$log" | head -20
  fi
  rm -f "$log"
}

run DaysMark -project "$ROOT/DaysMark.xcodeproj" -scheme DaysMark -only-testing:DaysMarkTests

cd "$ROOT/DaysMarkKit" || exit 1
for tests in Tests/*Tests/; do
  name="$(basename "$tests" Tests)"
  run "$name" -scheme DaysMarkKit-Package -only-testing:"${name}Tests"
done
cd "$ROOT" || exit 1

if [[ ${#failed[@]} -gt 0 ]]; then
  echo "RESULT: TESTS FAILED in ${failed[*]}"
  exit 1
fi
echo "RESULT: TESTS SUCCEEDED count=$total"
