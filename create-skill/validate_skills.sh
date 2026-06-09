#!/bin/bash
# Validates all skills against quality standards from create-skill/SKILL.md
# Run from the skills root directory: ./create-skill/validate_skills.sh

set -euo pipefail

SKILLS_DIR="${1:-.}"
errors=0
warnings=0
checked=0

for skill_dir in "$SKILLS_DIR"/*/; do
  f="$skill_dir/SKILL.md"
  [ -f "$f" ] || continue
  checked=$((checked + 1))
  name=$(basename "$skill_dir")
  se=0
  lines=$(wc -l < "$f")

  # Frontmatter: must start with ---
  if [ "$(head -1 "$f")" != "---" ]; then
    echo "✗ $name: file must start with --- (frontmatter delimiter)"
    se=$((se + 1))
  fi

  # Required frontmatter fields
  fm=$(sed -n '2,/^---$/p' "$f" | head -n -1)
  for field in name description version tags; do
    if ! echo "$fm" | grep -qE "^${field}:"; then
      echo "✗ $name: missing frontmatter field '$field'"
      se=$((se + 1))
    fi
  done

  # Required sections
  for sec in "## When to Use" "## Version History"; do
    if ! grep -q "^${sec}" "$f"; then
      echo "✗ $name: missing section '$sec'"
      se=$((se + 1))
    fi
  done

  # Workflow section: accepts "## Complete Workflow", "## Workflow", "## X Workflow"
  if ! grep -qE '^## (Complete )?(.+ )?Workflow' "$f"; then
    echo "✗ $name: missing workflow section (## Workflow / ## Complete Workflow)"
    se=$((se + 1))
  fi

  if ! grep -q '^\*\*Purpose\*\*' "$f"; then
    echo "✗ $name: missing **Purpose** statement"
    se=$((se + 1))
  fi

  # Warnings: recommended sections
  if ! grep -q '^## See Also' "$f"; then
    echo "△ $name: missing '## See Also' section"
    warnings=$((warnings + 1))
  fi

  # Sizing check
  if [ "$lines" -gt 800 ]; then
    echo "✗ $name: ${lines} lines (max 800 for any skill)"
    se=$((se + 1))
  elif [ "$lines" -gt 600 ]; then
    echo "△ $name: ${lines} lines (consider trimming, target <600)"
    warnings=$((warnings + 1))
  fi

  # Line width check (120 chars)
  long=$(awk 'length > 120' "$f" | wc -l)
  if [ "$long" -gt 0 ]; then
    echo "△ $name: ${long} lines over 120 characters"
    warnings=$((warnings + 1))
  fi

  # Cross-reference check: See Also skill dirs exist
  if grep -q '^## See Also' "$f"; then
    while IFS= read -r ref; do
      if [ ! -d "$SKILLS_DIR/$ref" ] || [ ! -f "$SKILLS_DIR/$ref/SKILL.md" ]; then
        echo "✗ $name: See Also references '$ref' but no skill found"
        se=$((se + 1))
      fi
    done < <(sed -n '/^## See Also/,/^## /p' "$f" \
      | grep -oP '(?<=\*\*)[a-z][-a-z]*(?=\*\*)' || true)
  fi

  errors=$((errors + se))
  if [ "$se" -eq 0 ]; then
    echo "✓ $name (${lines}L)"
  fi
done

echo ""
echo "Checked $checked skills: $errors errors, $warnings warnings"
if [ "$errors" -eq 0 ]; then
  echo "All skills pass validation."
else
  echo "Fix $errors error(s) above."
  exit 1
fi
