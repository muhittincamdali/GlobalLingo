#!/bin/sh
# Counts GlobalLingo's errors per locale from the JSON report, most first, then lists the rules
# behind them. Needs jq.
#
#   sh examples/shell/errors-by-locale.sh path/to/app
#
# Inside this repository it runs the built CLI (npm run build first); in an app repository,
# replace the command with `npx --yes @mcamdali/globallingo@2`.
set -eu

app="${1:-.}"
root="$(cd "$(dirname "$0")/../.." && pwd)"
report="$(mktemp)"
trap 'rm -f "$report"' EXIT

# Exit code 1 only means "findings"; 2 means the app could not be read.
status=0
node "$root/dist/cli/main.js" "$app" --format json --fail-on none > "$report" || status=$?
if [ "$status" -ne 0 ]; then
  exit "$status"
fi

echo "Errors per locale:"
jq -r '
  [.findings[] | select(.severity == "error" and .baselined != true) | .locale // "(all)"]
  | group_by(.) | map({ locale: .[0], count: length }) | sort_by(-.count)
  | .[] | "  \(.locale): \(.count)"
' "$report"

echo "Rules:"
jq -r '
  [.findings[] | select(.severity == "error" and .baselined != true) | .rule]
  | group_by(.) | map("  \(.[0]) × \(length)") | .[]
' "$report"
