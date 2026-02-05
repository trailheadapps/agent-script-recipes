#!/bin/bash
# Validates all agent scripts (authoring bundles) in the project.
# For each .agent file, runs: sf agent validate authoring-bundle -n <script-api-name>
# where script-api-name is the file name without the .agent extension.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT="$SCRIPT_DIR/.."
cd "$REPO_ROOT"

FAILED=0
VALIDATED=0

echo "Validating agent scripts (authoring bundles)..."
echo ""

while IFS= read -r -d '' agent_file; do
  script_name=$(basename "$agent_file" .agent)
  echo "Validating: $script_name"
  if sf agent validate authoring-bundle -n "$script_name"; then
    ((VALIDATED++))
  else
    ((FAILED++))
  fi
  echo ""
done < <(find force-app/main -name "*.agent" -type f -print0 | sort -z)

echo "----------------------------------------"
echo "Done: $VALIDATED passed, $FAILED failed"

if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
exit 0
