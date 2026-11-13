#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-format}"
CONFIG="$ROOT/.swift-format"

if ! xcrun --find swift-format >/dev/null 2>&1; then
  echo "error: swift-format is not in the current Xcode toolchain" >&2
  echo "RESULT: FORMAT BLOCKED"
  exit 2
fi

FILES=()
while IFS= read -r -d '' file; do
  FILES+=("$file")
done < <(
  find "$ROOT" \
    \( -name .git -o -name .build -o -name build -o -name .swiftpm -o -name '*.xcodeproj' \
      -o -name DerivedData \) -prune \
    -o -name '*.swift' -type f -print0
)

case "$MODE" in
  --lint)
    if xcrun swift-format lint --strict --parallel --configuration "$CONFIG" "${FILES[@]}"; then
      echo "RESULT: LINT SUCCEEDED files=${#FILES[@]}"
    else
      echo "RESULT: LINT FAILED files=${#FILES[@]}"
      exit 1
    fi
    ;;
  format)
    xcrun swift-format format --in-place --parallel --configuration "$CONFIG" "${FILES[@]}"
    echo "RESULT: FORMAT SUCCEEDED files=${#FILES[@]}"
    ;;
  *)
    echo "error: unknown argument $MODE (only --lint is accepted)" >&2
    exit 2
    ;;
esac
