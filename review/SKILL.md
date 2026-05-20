---
name: Code Review
description: Complete workflow for reviewing patches/commits, documenting findings, and formatting results
author: pvalena
version: 3.1.0
tags: [code-review, documentation, formatting, security, quality, verification, false-positives]
---

# Code Review Skill

**Purpose**: Complete workflow for reviewing code changes (patches, commits, merge requests),
documenting findings with technical precision, verifying correctness, drafting fixes, and producing
deep technical reasoning.

## When to Use This Skill

- Reviewing patches, commits, or merge requests for code quality and correctness
- Need to document code review findings in a structured format
- Creating review files, reasoning files, and draft fix patches
- Verifying existing reviews for false positives or missed issues

## Core Principles

**Zero false positives**: A single false positive destroys credibility. Every reported bug MUST be
verified by reading the actual source code, not just diffs.

**Completeness is mandatory**: Missing commits means missing bugs. Always verify commit count matches
what was reviewed.

**Evidence-based reviews**: Never report a bug you haven't seen in the actual code. Diffs can be
misleading -- always read the full function context using `git show BRANCH:path/to/file`.

**Draft fixes where straightforward**: When a fix is obvious and localized, include a diff patch in
the review. When it's not, explain why -- that's equally valuable.

**Deep reasoning**: Reasoning files should walk through the discovery and analysis step by step, so
a reader can independently verify the conclusion.

---

## Complete Workflow

### Phase 1: Perform Code Review

**Goal**: Examine all commits, read actual source code, identify real bugs.

#### 1. List and Count Commits

```bash
git log --oneline origin/master..BRANCH
git log --oneline origin/master..BRANCH | wc -l
```

Record the exact count -- you must review every commit and list each one in the review file.

#### 2. Read Commit Messages

```bash
git log origin/master..BRANCH --format=full
```

Check commit messages for:
- **Factual accuracy**: Do referenced commits (e.g., "Fixes commit abc123") actually exist?
  Verify with `git log --oneline --all --grep="abc123"`.
- **Correctness of claims**: Does the commit message accurately describe what the code does?
  Cross-reference each claim against the actual diff.
- **AI-assisted flag**: Look for `Assisted-by:`, `Co-authored-by:`, or similar tags indicating
  AI-generated code (e.g., `github-copilot`, `claude`, `chatgpt`). If present, apply
  heightened scrutiny (see Phase 2: AI-Generated Code Verification).

#### 3. Read the Full Diff

```bash
git diff origin/master..BRANCH
```

Identify files changed, scope of modifications, and areas requiring deeper inspection.

#### 4. Read Actual Source Code

**This is the critical step.** For every file changed, read the actual source at the branch:

```bash
git show BRANCH:path/to/file.c
git show BRANCH:path/to/file.c | sed -n '80,120p'   # specific lines
```

Do NOT rely on diffs alone. Diffs hide context: cleanup code after the hunk, NULL checks
earlier in the function, related code in the same file.

#### 5. What to Look For

**Critical issues:**
- Memory management: leaks, double-free, use-after-free, dangling pointers
- NULL pointer dereferences: missing NULL checks before use
- Resource leaks: FILE streams, file descriptors, allocations not freed on all paths
- Buffer overflows: array bounds, string operations, integer overflow in size calculations
- Logic errors: off-by-one, incorrect conditions, wrong operators, dead code
- Error handling: unchecked return values, conflated error/success returns
- Type mismatches: byte count vs element count, wrong enum, incorrect casts
- Documentation/code mismatches: docs say one thing, code does another

**What NOT to report:**
- Style preferences (naming, formatting, comment style)
- Optimization suggestions (unless correctness is affected)
- Alternative implementations (unless current is demonstrably wrong)
- Theoretical issues without concrete impact

#### 6. Create Review File

**File naming**: `reviews/IDENTIFIER.md` (e.g., `pr89.md`, `2025-05-0103.md`)

**Structure:**

```markdown
# AI Review: MR !XX - Brief Title

N commit(s) [brief description of what the change does].

**Commits:**
1. **hash** - Commit message
2. **hash** - Commit message

## Issues Found

### 1. Short issue title

**File:** `path/to/file.c`
**Location:** `function_name()`, lines ~N-M

[Technical description of the issue. What the code does, what's wrong with it,
what the consequence is. Include a code snippet if it clarifies.]

### 2. Next issue...

## Review Result

[1-2 sentence summary: how many issues, which are most significant.]

For more details: [URL to the reasoning file in the project's repository]
```

The "For more details" link should point to the reasoning file in the project's hosted
repository (e.g., GitHub, GitLab). Derive the URL from the project's remote:

```bash
# Get the repository URL
remote_url=$(git remote get-url origin | sed 's/\.git$//' | sed 's|git@github.com:|https://github.com/|')
# For GitHub: ${remote_url}/blob/main/reviews/IDENTIFIER_reasoning.txt
# For GitLab: ${remote_url}/-/blob/main/reviews/IDENTIFIER_reasoning.txt
```

Only include this link when issues were found (i.e., when a reasoning file exists).

**If no issues found**, replace the Issues Found section with:

```markdown
## Issues Found

No issues found.

## Review Result

[Brief explanation of why the code is correct, what was validated.]
```

#### 7. Create Reasoning File (Only If Issues Found)

**File naming**: `reviews/IDENTIFIER_reasoning.txt`

**Do NOT create** reasoning files for clean reviews.

**Structure** -- for each issue, include four sections:

```
[Severity]: [Issue title] at [file:location].

Discovery: [How the issue was found -- what drew attention to it.]

Analysis: [Technical breakdown. Trace through the code. Show what
values variables hold, what conditions are true/false, what code paths
execute. Reference specific line numbers.]

Step-by-step [for a concrete scenario]:
  1. [First thing that happens]
  2. [Next thing]
  ...
  N. [Final consequence]

Consequence: [What goes wrong in practice. Severity justification.]

---

[Next issue]
```

**Severity levels:**
- **Critical**: Crashes, memory corruption, security vulnerabilities, data loss
- **Minor**: Dead code, misleading names, resource leaks in short-lived processes
- **Note**: Observations, limitations, areas needing specialized review
- **Concern**: Potential issues requiring deeper analysis or domain expertise

---

### Phase 2: Verify Findings

**Goal**: Re-read actual source code to confirm every reported issue is real, and check
for issues that were missed.

This is a separate pass from Phase 1. After writing the initial review, go back and
independently verify each finding.

#### For Each Reported Issue

1. Read the actual source file at the relevant lines:
   ```bash
   git show BRANCH:path/to/file.c | sed -n 'START,ENDp'
   ```
2. Confirm the bug exists exactly as described
3. Check for context that might invalidate the finding:
   - Is there a NULL check earlier in the function?
   - Is the pointer set to NULL after the free?
   - Does the API guarantee something that makes this safe?
   - Is there cleanup code outside the visible diff?

#### AI-Generated Code Verification

When commit messages contain `Assisted-by:`, `Co-authored-by:` with an AI tool name,
or any other indicator of AI-generated code, apply additional scrutiny:

1. **Verify every claim in the commit message**: AI-generated commit messages may
   reference commits, functions, or behaviors that don't exist or are described
   inaccurately. Check each referenced commit hash with `git log --all --grep`.

2. **Question whether the code makes sense holistically**: AI can produce code that
   is locally correct but doesn't fit the surrounding architecture. Check:
   - Does the change interact correctly with the build system (linker scripts,
     Makefiles, module definitions)?
   - Are there downstream consumers that expect the old behavior?
   - Does the change match the project's existing patterns for similar problems?

3. **Check comments and documentation for accuracy**: AI-generated comments may
   contain subtle inaccuracies (wrong terminology, slightly-off grammar that
   obscures meaning, claims about guarantees that don't hold). Read every comment
   added by the patch critically.

4. **Trace the full execution path**: AI-generated code often handles the common
   case correctly but may miss edge cases or make assumptions about platform
   guarantees (e.g., identity mapping, memory ordering, API contracts) that need
   verification.

5. **Don't assume correctness from plausibility**: AI code can look convincing
   while being subtly wrong. The standard is the same as any other code: verify
   in the actual source, not by reading the diff and nodding along.

If the code passes all these checks, note in the Review Result that AI-assistance
was declared and the code was verified. Do not penalize correct code for being
AI-assisted.

#### For Clean Reviews

Re-read the diff and source code looking for anything missed:
- Trace all error paths for resource leaks
- Check all pointer dereferences for NULL safety
- Verify return value semantics match caller expectations
- Look for documentation/code mismatches

#### Common False Positive Patterns

**Double-free false positive:**
```c
grub_free(ptr);         // Review claims double-free
// ...
ptr = NULL;             // Review MISSED this -- not a bug
// ...
grub_free(ptr);         // Safe: ptr is NULL
```

**NULL dereference false positive:**
```c
if (param == NULL)      // Review missed this guard at function entry
  return;
// ...
*param = value;         // Review claims NULL deref -- already checked above
```

**Resource leak false positive:**
```c
fd = open(...);
if (!fd) {
  return;               // Review claims fd leak
}                       // But fd is 0 (invalid), not a real fd
```

#### If You Find a False Positive

1. Remove it from the review file
2. Update the reasoning file
3. Re-verify all other findings in the same review (pattern of errors)

#### If You Find a Missed Issue

1. Add it to the review file
2. Add it to the reasoning file
3. Update the Review Result summary

---

### Phase 3: Draft Fixes

**Goal**: For each confirmed issue, either provide a fix patch or explain why a fix
isn't straightforward.

#### When to Provide a Draft Fix

Provide a diff patch when the fix is:
- Localized (changes 1-10 lines)
- Obvious (the correct behavior is clear)
- Self-contained (doesn't require API redesign or broader changes)

Examples of straightforward fixes:
- Swapping case branch order to fix dead code
- Adding a missing `fclose(fp)` before return
- Removing a dead `free(NULL)` call
- Changing space-separated to comma-separated output

#### When NOT to Provide a Draft Fix

Explain why instead, when:
- The author's intent is ambiguous (docs say X, code does Y -- which is right?)
- The fix requires API redesign (e.g., changing return value semantics)
- Multiple valid approaches exist with different trade-offs
- The fix affects callers that need coordinated changes

#### Format in Review File

Add the fix directly after the issue description:

**For straightforward fixes:**
````markdown
**Draft fix** -- [brief description of what the fix does]:

```diff
--- a/path/to/file.c
+++ b/path/to/file.c
@@ -LINE,COUNT +LINE,COUNT @@
  context line
-old line
+new line
  context line
```
````

**For non-straightforward fixes:**
```markdown
Not a straightforward fix. [Explanation of why: what's ambiguous, what trade-offs
exist, what the author needs to decide. Be specific about the competing options
and their implications.]
```

---

### Phase 4: Deep Reasoning

**Goal**: Ensure reasoning files contain enough depth for independent verification.

A good reasoning file lets someone who has never seen the code follow your analysis
and arrive at the same conclusion. It should read like a proof, not an assertion.

#### Required Depth

For each issue, the reasoning file must include:

1. **Discovery**: What specific code or pattern drew your attention. Which file, which
   line, what looked wrong at first glance.

2. **Analysis**: Technical breakdown with specific line numbers. Trace through the code
   showing what values variables hold at each step. Reference the actual code, not
   hypotheticals.

3. **Step-by-step scenario**: A concrete execution trace showing how the bug manifests.
   Number each step. Include the state of relevant variables at each point.

4. **Consequence**: What actually goes wrong. Be specific -- "crashes" is insufficient;
   "efibootmgr pipe failure returns errno=24 to caller, caller treats non-zero as
   'already registered', returns 0 (success), boot entry is never created" is
   sufficient.

#### Example: Thorough Reasoning Entry

```
Minor: Missing fclose(fp) in grub_install_efi_is_registered() at
grub-core/osdep/unix/platform.c, before `return rc` on line 129.

Discovery: Reading the function's resource management, the FILE stream is
opened at line 97:
  FILE *fp = fdopen(fd, "r");
Then used in the while loop (lines 103-127) to read efibootmgr output via
getline(). After the loop, line 128-129:
  free(line);
  return rc;
The function frees the line buffer but never calls fclose(fp).

Analysis: Tracing resource lifecycle:
  1. grub_util_exec_pipe() creates a pipe and returns fd (line 85)
  2. fdopen(fd, "r") wraps fd into FILE* fp (line 97)
  3. getline() reads from fp in the loop (line 108)
  4. free(line) releases the line buffer (line 128)
  5. return rc -- fp is NOT closed (line 129)

After fdopen() succeeds, the fd is owned by the FILE stream. Calling
fclose(fp) would close both the stream and the underlying fd. Without it:
  - The FILE stream's internal buffer is leaked
  - The file descriptor is leaked
  - The child process may not receive EOF on its stdout pipe

Comparison with get_ofpathname() in the same file (lines 36-78): that
function follows the identical pattern but correctly calls fclose(fp) at
line 73 before returning.

Consequence: Each call leaks one FILE stream and one file descriptor. In
current code the function is called at most once per grub-install
invocation, so the leak is not practically harmful. However, it is a
correctness defect.
```

---

### Phase 5: Format and Verify

**Goal**: Ensure all files meet formatting standards.

#### Line Width: 120 Characters

All review and reasoning files must have lines under 120 characters.

```bash
# Check all review files
for file in reviews/*.md reviews/*_reasoning.txt; do
  cnt=$(awk 'length > 120' "$file" 2>/dev/null | wc -l)
  if [ "$cnt" -gt 0 ]; then
    echo "$file: $cnt lines over 120 chars"
  fi
done
```

**Break lines at natural points:**
- After commas, periods, colons
- Before conjunctions (and, but, or)
- Before/after parentheses
- Never break function names, file paths, or code within backticks

#### Completeness Check

```bash
# Every review with issues should have a reasoning file
for f in reviews/*.md; do
  base=$(basename "$f" .md)
  if ! grep -q "No issues found" "$f" 2>/dev/null; then
    if [ ! -f "reviews/${base}_reasoning.txt" ]; then
      echo "MISSING: reviews/${base}_reasoning.txt"
    fi
  fi
done
```

#### Content Quality Checklist

**Review file:**
- [ ] Title includes MR/PR identifier and brief description
- [ ] All commits listed with hashes and descriptions
- [ ] Commit count matches actual (`git log --oneline | wc -l`)
- [ ] Each issue has file path and line numbers
- [ ] Every bug verified by reading actual source code
- [ ] Draft fix or "not straightforward" explanation for each issue
- [ ] Review Result section summarizes findings
- [ ] Lines under 120 characters

**Reasoning file:**
- [ ] Only exists for reviews WITH issues
- [ ] Each issue has Discovery, Analysis, Step-by-step, Consequence
- [ ] Specific line numbers referenced throughout
- [ ] Concrete execution trace (not hypothetical)
- [ ] A reader could independently verify the conclusion
- [ ] Lines under 120 characters

---

## Reviewing Multiple MRs

When reviewing several MRs at once, run reviews in parallel where possible:

1. **List all MRs** with commit counts first
2. **Review in parallel** -- each MR is independent, spawn concurrent reviews
3. **Verify sequentially** -- re-read each review's findings against actual code
4. **Draft fixes** -- add patches or explanations to each review
5. **Deep reasoning** -- ensure reasoning files have full step-by-step depth

---

## Common Bug Patterns

**Resource leak (FILE stream):**
```
fdopen(fd, "r") opens a FILE stream. If fclose(fp) is never called, both the
FILE stream buffer and the underlying fd leak. Check every fdopen has a matching
fclose on all return paths.
```

**Error/success conflation:**
```
Function returns errno (non-zero) on error and 1 on success. Caller tests
`if (ret)` treating both as the same condition. Error silently treated as
success. Check return value semantics match caller expectations.
```

**Dead code from branch ordering:**
```
Shell case statement: x*) matches before x), making x) unreachable. In C:
default case before specific cases. Check that more specific patterns precede
wildcards/defaults.
```

**Documentation/code mismatch:**
```
Docs describe one delimiter/format/behavior, code implements another. Users
following docs get broken results. Cross-reference documentation against actual
parsing code.
```

**Dead code from guard conditions:**
```
Guard condition guarantees a value (e.g., !ptr means ptr is NULL). Code inside
the guard operates on that value redundantly (e.g., free(ptr) where ptr is
always NULL). Check what the guard condition guarantees about variables inside
the block.
```

---

## Anti-Patterns to Avoid

**Asserting without proving:**
```
BAD:  "This could cause a double-free."
GOOD: "free() at line 2099 does not NULL the pointer. Line 2143 retrieves the
       same pointer via transfer->controller_data. Line 2196 frees it again."
```

**Vague consequences:**
```
BAD:  "This might cause problems."
GOOD: "grub-install reports success but no EFI boot entry is created. System
       will not boot GRUB after firmware boot order reset."
```

**Suggesting fixes in reasoning files:**
```
BAD:  "Should add fclose(fp) before return."
GOOD: "fp is never closed before return rc on line 129."
(Fixes go in the review .md file, not in reasoning.)
```

**Reporting style issues as bugs:**
```
BAD:  "Minor: Variable name 'x' is not descriptive."
GOOD: Don't report this at all. Only report issues that affect correctness.
```

---

## Version History

- **3.1.0** (2026-05-14): Added commit message verification step (Phase 1, step 2).
  Added AI-generated code verification section (Phase 2) with checklist for
  heightened scrutiny when AI-assistance tags are present. Based on review of
  MR !122 (Assisted-by: github-copilot:claude-opus-4.7).
- **3.0.0** (2026-05-03): Restructured to match actual review workflow. Added Phase 3
  (Draft Fixes) and Phase 4 (Deep Reasoning). Updated review file format with structured
  headings. Updated reasoning file format to require Discovery/Analysis/Step-by-step/
  Consequence sections. Added parallel review guidance. Removed unused sections
  (CI/CD integration, customization options). Updated examples from actual reviews.
- **2.1.0** (2026-04-10): Added Phase 0 (Perform Code Review) with checklist and bug
  patterns. Added verification examples. Added common false positive patterns.
- **2.0.0**: Added verification phase, completeness checks, false positive prevention.
- **1.0.0**: Initial version with basic review and formatting workflow.

---

## See Also

- **refresh-docs** - For updating documentation after reviews change project state
- **auto-memory** - For capturing review workflow knowledge in project MEMORY.md
