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

  # Sizing check (soft guidance, not hard caps)
  if [ "$lines" -gt 800 ]; then
    echo "△ $name: ${lines} lines (target <800, check for duplication)"
    warnings=$((warnings + 1))
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
    see_also_refs=()
    while IFS= read -r ref; do
      if [ ! -d "$SKILLS_DIR/$ref" ] || [ ! -f "$SKILLS_DIR/$ref/SKILL.md" ]; then
        echo "✗ $name: See Also references '$ref' but no skill found"
        se=$((se + 1))
      fi
      # Check for duplicates within this skill's See Also
      for prev in "${see_also_refs[@]}"; do
        if [ "$prev" = "$ref" ]; then
          echo "✗ $name: duplicate See Also reference '$ref'"
          se=$((se + 1))
          break
        fi
      done
      see_also_refs+=("$ref")
    done < <(sed -n '/^## See Also/,/^## /p' "$f" \
      | grep -oP '(?<=\*\*)[a-z][-a-z]*(?=\*\*)' || true)
  fi

  # Version history: entries should be one-liners (max 3 lines each)
  if grep -q '^## Version History' "$f"; then
    long_entries=$(sed -n '/^## Version History/,/^## /p' "$f" \
      | awk '/^- \*\*[0-9]/{if(count>3){n++} count=1; next} /^  /{count++} /^$/{if(count>3){n++} count=0} END{if(count>3){n++} print n+0}')
    if [ "$long_entries" -gt 0 ]; then
      echo "△ $name: ${long_entries} version history entries over 3 lines (keep brief, detail in git log)"
      warnings=$((warnings + 1))
    fi
  fi

  # Frontmatter description length check (wc -c includes trailing newline)
  desc_len=$(echo "$fm" | grep '^description:' | sed 's/^description: *//' | wc -c)
  desc_len=$((desc_len - 1))
  if [ "$desc_len" -gt 120 ]; then
    echo "△ $name: description is ${desc_len} chars (target <120 for display)"
    warnings=$((warnings + 1))
  fi

  errors=$((errors + se))
  if [ "$se" -eq 0 ]; then
    echo "✓ $name (${lines}L)"
  fi
done

# Second pass: asymmetric See Also references
for skill_dir in "$SKILLS_DIR"/*/; do
  f="$skill_dir/SKILL.md"
  [ -f "$f" ] || continue
  name=$(basename "$skill_dir")

  while IFS= read -r ref; do
    ref_file="$SKILLS_DIR/$ref/SKILL.md"
    [ -f "$ref_file" ] || continue
    if ! sed -n '/^## See Also/,/^## /p' "$ref_file" \
        | grep -qP "(?<=\*\*)${name}(?=\*\*)"; then
      echo "△ $name: references '$ref' in See Also, but '$ref' does not reference '$name' back"
      warnings=$((warnings + 1))
    fi
  done < <(sed -n '/^## See Also/,/^## /p' "$f" \
    | grep -oP '(?<=\*\*)[a-z][-a-z]*(?=\*\*)' || true)
done

echo ""
echo "Checked $checked skills: $errors errors, $warnings warnings"
if [ "$errors" -eq 0 ]; then
  echo "All skills pass validation."
else
  echo "Fix $errors error(s) above."
  exit 1
fi
