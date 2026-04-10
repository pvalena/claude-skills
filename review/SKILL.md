---
name: Code Review Reasoning
description: Generate concise reasoning files for code reviews and ensure proper formatting
author: pvalena
version: 1.0.0
tags: [code-review, documentation, formatting]
---

# Code Review Reasoning Skill

**Purpose**: Generate concise reasoning files for code reviews that have identified issues, and ensure all
review documentation is properly formatted.

## When to Use This Skill

Use this skill when:
- You have completed code reviews and need to document the reasoning behind findings
- Review files exist but need accompanying reasoning/justification files
- Review documentation needs to be formatted to a specific width constraint

## Workflow

### Phase 1: Identify Reviews with Issues

1. **Locate review files**
   - Find all review markdown files (e.g., `reviews/*.md`)
   - Determine which reviews found issues vs. no issues
   - Common pattern: Reviews with "No issues found" text are clean

2. **Create list of reviews needing reasoning**
   ```bash
   # Example: Find reviews without "No issues found"
   for file in reviews/*.md; do
     if ! grep -q "No issues found" "$file"; then
       basename "$file" .md
     fi
   done
   ```

### Phase 2: Generate Reasoning Files

For each review with issues, create a `*_reasoning.txt` file with:

**Content Requirements:**
- **Brief and focused** - No unnecessary prose
- **Include specific locations** - File paths, line numbers, function names
- **State the technical issue** - What's wrong and why it matters
- **Use precise terminology** - Memory leak, double-free, NULL dereference, etc.
- **No recommendations** - Just state what the problem is

**Format Template:**
```
Issue type: Description at location. Technical explanation of why this is a problem.
Consequences of the issue.

[Next issue if multiple]
```

**Example:**
```
Critical: FITHAW (unfreeze) return value not checked at line 36 of grub-core/osdep/linux/journaled_fs.c.
If unfreeze fails after successful freeze, filesystem remains frozen, potentially making system
unbootable. Must check return value and handle failure.

Minor: ext2 listed in journaled filesystems (util/grub-install.c:2037) but ext2 has no journal. Name
is misleading though it functionally works since ext3/4 report as "ext2" in GRUB.
```

**Guidelines:**
- Start with severity: Critical, Minor, Note, Concern
- Include file path and line number in first sentence
- Explain the technical flaw, not the fix
- State impact/consequences
- Keep each paragraph focused on one issue
- Separate multiple issues with blank lines

### Phase 3: Format Documentation

**Width Constraint: 120 characters**

1. **Format review files** (`*.md`)
   - Check for lines exceeding width: `awk 'length > 120' file.md`
   - Wrap long lines while preserving:
     - Code blocks and indentation
     - Bullet point structure
     - Markdown formatting
   - Break lines at natural points (after commas, before conjunctions)

2. **Format reasoning files** (`*_reasoning.txt`)
   - Apply same 120 character limit
   - Maintain paragraph structure
   - Preserve technical terminology (don't break function names)
   - Keep file paths readable

**Line Breaking Strategy:**
```
Before (>120 chars):
Critical: FITHAW (unfreeze) return value not checked at line 36 of grub-core/osdep/linux/journaled_fs.c. If unfreeze fails after successful freeze, filesystem remains frozen, potentially making system unbootable.

After (<120 chars):
Critical: FITHAW (unfreeze) return value not checked at line 36 of grub-core/osdep/linux/journaled_fs.c.
If unfreeze fails after successful freeze, filesystem remains frozen, potentially making system
unbootable.
```

### Phase 4: Verification

1. **Count files**
   - Verify reasoning files created for all reviews with issues
   - Check counts match expectations

2. **Verify formatting**
   ```bash
   # Check for lines over 120 chars
   for file in reviews/*.md reviews/*_reasoning.txt; do
     cnt=$(awk 'length > 120' "$file" | wc -l)
     if [ "$cnt" -gt 0 ]; then
       echo "$file: $cnt lines over 120 chars"
     fi
   done
   ```

3. **Validate content**
   - Each reasoning file should have specific locations (file:line)
   - Technical issues should be clearly stated
   - No generic statements or recommendations

## File Organization

**Expected Structure:**
```
reviews/
├── BRANCH_NAME.md              # Full review
├── BRANCH_NAME_reasoning.txt   # Brief reasoning (if issues found)
├── ANOTHER_BRANCH.md
├── ANOTHER_BRANCH_reasoning.txt
└── ...
```

## Quality Checklist

For each reasoning file, verify:
- [ ] Starts with issue severity (Critical/Minor/Note)
- [ ] Includes specific file path and line number
- [ ] Explains what is wrong (not how to fix it)
- [ ] States technical consequences
- [ ] No line exceeds 120 characters
- [ ] No generic statements ("could be improved", "might be better")
- [ ] Uses precise technical terms
- [ ] Separates distinct issues with blank lines

## Common Patterns

### Multiple Issues
```
Critical: [Issue 1 at location]. Technical explanation.

Minor: [Issue 2 at location]. Technical explanation.

Note: [Issue 3 at location]. Technical explanation.
```

### Compilation Errors
```
Critical: Compilation error at file:line. Code references nonexistent field/function. Will fail with
"error message".
```

### Resource Management
```
Critical: Double-free at file:line1,line2. Function frees pointer without nulling. If other_function()
called, retrieves dangling pointer and frees again.
```

### Platform-Specific
```
Cannot thoroughly review due to complexity and platform-specific nature (Platform/Architecture/Protocol).
Requires specialized hardware. [Brief summary of changes]. No obvious issues but extensive testing
recommended.
```

## Anti-Patterns to Avoid

**Too verbose:**
```
❌ The code has an issue where it doesn't properly check the return value, which could potentially
   lead to problems in certain scenarios where the operation might fail.
```

**Too brief:**
```
❌ Unchecked return value at line 36.
```

**Just right:**
```
✓ Critical: FITHAW return value not checked at journaled_fs.c:36. If unfreeze fails, filesystem
  remains frozen, making system unbootable.
```

## Integration Points

- Can be used after code review completion
- Works with any review format that distinguishes "issues found" vs "no issues"
- Reasoning files serve as quick reference for developers
- Formatted files work well with terminal displays, diff tools, and version control

## Customization

Adjust these parameters based on project needs:
- **Width limit**: Default 120, adjust for terminal/tool requirements
- **Severity levels**: Critical/Minor/Note, or use project-specific taxonomy
- **File naming**: `*_reasoning.txt` or other convention
- **Issue format**: Adapt template to project style guide

## Example Session

```bash
# 1. Find reviews with issues
reviews_with_issues=$(find reviews -name "*.md" -exec sh -c 'grep -L "No issues found" "$1"' _ {} \;)

# 2. Create reasoning files
for review in $reviews_with_issues; do
  branch=$(basename "$review" .md)
  # [Generate reasoning content based on review]
  echo "$reasoning" > "reviews/${branch}_reasoning.txt"
done

# 3. Format all files
for file in reviews/*.md reviews/*_reasoning.txt; do
  # [Apply 120 char wrapping]
done

# 4. Verify
./verify_format.sh
```

## Output Summary

After running this skill, you should have:
- ✓ Reasoning file for each review with issues
- ✓ All files formatted to width constraint
- ✓ Clear, technical documentation of findings
- ✓ Verification report confirming completion
