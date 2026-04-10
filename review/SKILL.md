---
name: Code Review
description: Complete workflow for reviewing patches/commits, documenting findings, and formatting results
author: pvalena
version: 2.0.0
tags: [code-review, documentation, formatting, security, quality]
---

# Code Review Skill

**Purpose**: Complete workflow for reviewing code changes (patches, commits, merge requests), documenting
findings with technical precision, and ensuring proper formatting of all review documentation.

## When to Use This Skill

Use this skill when:
- Reviewing patches, commits, or merge requests for code quality and correctness
- Need to document code review findings in a structured format
- Creating both detailed review files and concise reasoning summaries
- Ensuring review documentation meets formatting standards

## Complete Workflow

### Phase 0: Perform Code Review

#### 1. Examine the Changes

**Checkout the code:**
```bash
# For git branches
git checkout BRANCH_NAME

# For specific commits
git show COMMIT_HASH

# For patches
git diff BASE_BRANCH...BRANCH_NAME
```

**Understand context:**
- Read commit messages for intent
- Identify files modified and scope of changes
- Note number of commits if multiple
- Check if part of a series (depends on other MRs/patches)

#### 2. Review Checklist

**Critical Issues to Find:**
- **Memory management**: Leaks, double-free, use-after-free, dangling pointers
- **NULL pointer dereferences**: Missing NULL checks, dereferencing before validation
- **Resource leaks**: Files, file descriptors, network connections, DMA allocations
- **Buffer overflows**: Array bounds, string operations, integer overflows
- **Uninitialized variables**: Using variables before assignment
- **Concurrency issues**: Race conditions, deadlocks (if applicable)
- **Logic errors**: Off-by-one, incorrect conditions, wrong operators
- **Type mismatches**: Wrong enum types, incorrect casts
- **Error handling**: Unchecked return values, missing error paths
- **Compilation errors**: Missing fields, undefined symbols, type errors

**Code Quality Issues:**
- Inconsistent style (only if severe)
- Missing validation of inputs
- Incomplete cleanup in error paths
- Platform-specific code without guards
- Misleading comments or variable names

**What NOT to Focus On:**
- Minor style preferences (unless project has strict guidelines)
- Optimization opportunities (unless performance-critical)
- Alternative implementations (unless current is clearly wrong)
- Theoretical issues without concrete impact

#### 3. Analyze Specific Code Sections

**Read the actual code:**
- Don't just read diffs, examine full context
- Check how functions are called and what they expect
- Trace data flow for suspicious operations
- Look at related code in same file
- Check if changes conflict with other patches

**For each issue found, document:**
- Exact file path and line number(s)
- Function/context where issue occurs
- What is wrong (technical description)
- Why it's wrong (consequences, impact)
- Type of issue (compilation error, crash, leak, logic bug)

#### 4. Create Review File

**File naming:** `reviews/BRANCH_OR_COMMIT_ID.md`

**Review file structure:**
```markdown
# AI Review: MR !XX - Brief Title

[One paragraph summary: what the change does, scope, testing mentioned]

[For each issue:]
- **Issue Type: Brief description** (file.c:line): Technical explanation.
  Additional details if needed. Impact/consequences.

[If no issues:]
The [approach/fix/implementation] is [correct/sound]:

- [Validation point 1]
- [Validation point 2]
- [Why it works]

No issues found.

[If needs specialized review:]
**Note**: This requires [domain] expertise to properly review. The implementation involves
[complex topic] beyond general code review scope. Recommend review by [specialized team].
```

**Example: Review with issues**
```markdown
# AI Review: MR !42 - Add xHCI support

Adds USB 3.0 (xHCI) controller driver. 2963 lines based on SeaBIOS implementation, tested on QEMU and
MSC C6B-CFLR boards with USB mass storage, DVD burner, and hubs.

- **Potential double-free** (grub-core/bus/usb/xhci.c:2099,2196): `grub_xhci_check_transfer()` frees
  `transfer->controller_data` (line 2099) without setting it to NULL. If `grub_xhci_cancel_transfer()`
  is subsequently called on the same transfer, it retrieves the dangling pointer (line 2142-2143) and
  frees it again (line 2196), causing double-free. Should set `transfer->controller_data = NULL;` after
  line 2099.

**Note**: At 2963 lines, exhaustive review is impractical. Focused on resource management and
integration points.
```

**Example: Review without issues**
```markdown
# AI Review: MR !21 - Handle root inode read failure

The fix is correct:

- Adds early return when `addr` parameter is 0 (null/invalid MMIO address)
- Prevents generation of invalid 'mmio,0' port names that would halt the system
- Returns NULL appropriately to signal error to caller

The logic prevents the crash described in the commit message. No issues found.
```

#### 5. Common Bug Patterns

**Double-free:**
```
Function A frees memory and doesn't NULL the pointer.
Function B later frees the same pointer.
Look for: free without NULL assignment, multiple code paths calling free.
```

**Use-after-free:**
```
Memory freed but pointer still used afterwards.
Look for: operations after free, pointer not checked for validity.
```

**NULL dereference:**
```
Pointer dereferenced without NULL check.
Look for: function returning NULL, immediate dereference of return value.
```

**Resource leak:**
```
Resource allocated but not freed on all paths (especially error paths).
Look for: malloc/open/alloc without matching free/close, early returns skipping cleanup.
```

**Uninitialized variable:**
```
Variable declared but used before assignment.
Look for: variable declared, conditional assignment, unconditional use.
```

**Type confusion:**
```
Using wrong enum type, incorrect struct member access.
Look for: type casts, enum comparisons, struct field access.
```

**Missing error check:**
```
Function call that can fail, return value not checked.
Look for: allocation functions, system calls, operations that can fail.
```

### Phase 1: Generate Reasoning Files

For each review **with issues found**, create a `*_reasoning.txt` file.

**File naming:** `reviews/BRANCH_OR_COMMIT_ID_reasoning.txt`

**Content Requirements:**
- **Brief and focused** - No unnecessary prose
- **Include specific locations** - File paths, line numbers, function names
- **State the technical issue** - What's wrong and why it matters
- **Use precise terminology** - Memory leak, double-free, NULL dereference, etc.
- **No recommendations** - Just state what the problem is
- **No "No issues found" files** - Only create for reviews with issues

**Format Template:**
```
[Severity]: [Issue description at location]. [Technical explanation].
[Consequences].

[Next issue if multiple]
```

**Severity Levels:**
- **Critical**: Compilation errors, crashes, memory corruption, security vulnerabilities
- **Minor**: Style issues, misleading names, inefficiencies
- **Note**: Observations, limitations, context for future reviewers
- **Concern**: Potential issues requiring deeper analysis or testing

**Example:**
```
Critical: Double-free at grub-core/bus/usb/xhci.c:2099,2196. grub_xhci_check_transfer() frees
transfer->controller_data (line 2099) without setting to NULL. If grub_xhci_cancel_transfer()
subsequently called on same transfer, retrieves dangling pointer (lines 2142-2143) and frees again
(line 2196). Should set transfer->controller_data = NULL after line 2099.

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

### Phase 2: Format Documentation

**Width Constraint: 120 characters**

All review files must comply with 120 character line width for readability in terminals and diffs.

#### 1. Format Review Files (`*.md`)

**Check for long lines:**
```bash
awk 'length > 120 {print NR ": " substr($0, 1, 80) "..."}' reviews/FILE.md
```

**Wrap long lines while preserving:**
- Code blocks and indentation
- Bullet point structure
- Markdown formatting
- Technical terms (don't break function names mid-word)

**Break lines at natural points:**
- After commas, periods
- Before conjunctions (and, but, or)
- Before opening parentheses
- After closing parentheses

**Line Breaking Example:**
```markdown
Before (>120 chars):
- **NULL pointer dereference** (grub-core/lib/cmdline.c:53): `grub_loader_cmdline_size()` calls `check_arg(argv[i], 0)` passing NULL as second parameter.

After (<120 chars):
- **NULL pointer dereference** (grub-core/lib/cmdline.c:53): `grub_loader_cmdline_size()` calls
  `check_arg(argv[i], 0)` passing NULL as second parameter.
```

#### 2. Format Reasoning Files (`*_reasoning.txt`)

Same 120 character limit applies.

**Maintain:**
- Paragraph structure
- Technical terminology intact
- File paths readable
- Sentence flow

**Example:**
```
Before (>120 chars):
Critical: Enum grub_luks2_kdf_type in include/grub/luks2.h:26-30 missing LUKS2_KDF_TYPE_ARGON2ID value. Code still references this value at luks2.c:107,506,510, causing compilation failure.

After (<120 chars):
Critical: Enum grub_luks2_kdf_type in include/grub/luks2.h:26-30 missing LUKS2_KDF_TYPE_ARGON2ID value.
Code still references this value at luks2.c:107,506,510, causing compilation failure.
```

### Phase 3: Verification

#### 1. File Completeness Check

**Verify file pairs:**
- Every review file exists: `reviews/IDENTIFIER.md`
- Reasoning file exists only for reviews with issues
- No orphaned reasoning files

```bash
# Count reviews
total_reviews=$(ls reviews/*.md | wc -l)

# Count reviews with issues
reviews_with_issues=$(grep -L "No issues found" reviews/*.md | wc -l)

# Count reasoning files
reasoning_files=$(ls reviews/*_reasoning.txt | wc -l)

# Verify: reasoning_files should equal reviews_with_issues
```

#### 2. Format Verification

**Check line lengths:**
```bash
for file in reviews/*.md reviews/*_reasoning.txt; do
  cnt=$(awk 'length > 120' "$file" | wc -l)
  if [ "$cnt" -gt 0 ]; then
    echo "$file: $cnt lines over 120 chars"
  fi
done
```

**Expected output:** No files with lines over 120 chars

#### 3. Content Quality Check

For each review file, verify:
- [ ] Title includes MR/PR/commit identifier
- [ ] Summary paragraph describes the change
- [ ] Issues include file paths and line numbers
- [ ] Technical terminology is precise
- [ ] Impact/consequences are stated
- [ ] "No issues found" present if clean

For each reasoning file, verify:
- [ ] Starts with severity level
- [ ] Includes specific location (file:line)
- [ ] Explains what is wrong, not how to fix
- [ ] States consequences
- [ ] No recommendations or subjective opinions

## File Organization

**Expected Structure:**
```
reviews/
├── 2025-05-0103.md              # Full review (MR !42)
├── 2025-05-0103_reasoning.txt   # Brief reasoning (has issues)
├── 2025-01-0091.md              # Full review (MR !20)
├── 2025-01-0091_reasoning.txt   # Brief reasoning (has issues)
├── 2025-03-0223.md              # Full review (MR !26)
│                                # No reasoning file (no issues found)
└── ...
```

## Common Patterns

### Critical Issues

**Compilation Error:**
```markdown
- **Critical: Compilation error** (file.c:line): Code references nonexistent struct member `field`.
  Struct definition (lines X-Y) only has fields A, B, C. Will fail with "no member named 'field'" error.
```

**Double-Free:**
```markdown
- **Potential double-free** (file.c:line1,line2): `func_a()` frees pointer without setting to NULL.
  If `func_b()` is called, retrieves dangling pointer and frees again, causing double-free.
```

**NULL Dereference:**
```markdown
- **NULL pointer dereference** (file.c:line): `func()` calls `foo(ptr, 0)` passing NULL as second
  parameter. When condition true, line X dereferences NULL (`if (*param == 0)`), causing crash.
```

### Minor Issues

**Misleading Code:**
```markdown
- **Minor: Misleading variable name** (file.c:line): Variable `count` actually holds size in bytes,
  not element count. May confuse future maintainers but functionally correct.
```

**Incomplete Cleanup:**
```markdown
- **Minor: File descriptor leak** (file.awk:line): Opens file with getline but never closes. Should
  add `close(file)` to avoid fd exhaustion with many files.
```

### Review Notes

**Platform-Specific:**
```markdown
**Note**: Cannot thoroughly review due to platform-specific nature (PowerPC/IEEE1275). Requires
specialized hardware. No obvious issues in code structure but extensive testing recommended.
```

**Requires Expertise:**
```markdown
**Note**: Requires security/cryptography expertise. Implementation involves TPM measurements and DRTM
beyond general code review scope. Recommend review by security team familiar with TCG D-RTM.
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

**Don't suggest fixes:**
```
❌ Should add NULL check before dereferencing pointer.
✓ NULL pointer dereference at file.c:123. Pointer not validated before use.
```

**Don't be subjective:**
```
❌ This approach seems questionable and might be improved.
✓ Logic error at file.c:45. Uses > instead of >=, causing off-by-one error.
```

## Integration & Automation

### Batch Review Script

```bash
#!/bin/bash
# Review multiple branches/commits

for branch in $(cat branches_to_review.txt); do
  echo "=== Reviewing $branch ==="

  # Checkout and examine
  git checkout "$branch"

  # [Perform review - manual or assisted]
  # Create reviews/${branch}.md

  # If issues found, create reviews/${branch}_reasoning.txt

  # Format files
  # [Apply formatting]
done

# Verify all files
./verify_reviews.sh
```

### Integration with CI/CD

- Generate review files as part of PR/MR workflow
- Automate formatting checks
- Link review files to issue tracking
- Include in documentation builds

## Customization

Adjust these based on project needs:

**Width Limit:**
- Default: 120 characters
- Terminal-friendly: 80 characters
- Wide display: 132 characters

**Severity Levels:**
- Default: Critical/Minor/Note/Concern
- Custom: Blocker/Major/Minor/Trivial
- CVSS-based: Critical/High/Medium/Low

**File Naming:**
- Default: `IDENTIFIER.md` + `IDENTIFIER_reasoning.txt`
- Alternative: `IDENTIFIER/review.md` + `IDENTIFIER/reasoning.txt`
- With dates: `YYYY-MM-DD_IDENTIFIER.md`

**Review Format:**
- Default: Markdown
- Alternative: reStructuredText, AsciiDoc
- Structured: YAML/JSON with Markdown content

## Output Summary

After applying this skill, you should have:

- ✓ Complete review file for each patch/commit (`*.md`)
- ✓ Reasoning file for each review with issues (`*_reasoning.txt`)
- ✓ All files formatted to width constraint (120 chars)
- ✓ Clear, technical documentation of findings
- ✓ Verification confirming completeness and quality
- ✓ Ready for sharing with developers/team

## Example End-to-End Session

```bash
# 1. Review a specific MR/branch
git checkout 2025-05-0103

# 2. Examine the code
git log 2025-05-0103 --oneline
git diff master...2025-05-0103

# 3. Read actual code files
vim grub-core/bus/usb/xhci.c

# 4. Create review file
cat > reviews/2025-05-0103.md <<EOF
# AI Review: MR !42 - Add xHCI support

[Review content with findings]
EOF

# 5. Create reasoning file (if issues found)
cat > reviews/2025-05-0103_reasoning.txt <<EOF
Critical: Double-free at grub-core/bus/usb/xhci.c:2099,2196...
EOF

# 6. Format files
./format_reviews.sh

# 7. Verify
./verify_reviews.sh
```

## Reference

**Common File Locations:**
- Linux kernel: drivers/, fs/, arch/, include/
- GRUB: grub-core/, include/grub/, util/
- User space: src/, lib/, tests/

**Helpful Commands:**
- `git log -p BRANCH` - Show patches
- `git diff BASE...BRANCH` - Show changes
- `git show COMMIT:file` - Show file at commit
- `grep -r "function_name" .` - Find usage
- `awk 'length > 120' file` - Check line length

**Common Bug Keywords:**
- Search for: malloc, free, NULL, return, error, fail, leak, ptr, size, len, count, buffer
- Flag: TODO, FIXME, XXX, HACK, BUG
- Review: goto, break, continue, recursion
