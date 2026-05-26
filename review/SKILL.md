---
name: Code Review
description: Complete workflow for reviewing patches/commits, documenting findings, and formatting results
author: pvalena
version: 3.2.0
tags: [code-review, documentation, formatting, security, quality, verification, false-positives]
---

# Code Review Skill

**Purpose**: Complete workflow for reviewing code changes (patches, commits, merge requests),
documenting findings with technical precision, assessing correctness by reading source code,
drafting fixes, and producing deep technical reasoning.

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

**Honest claims**: Say only what you actually did. Reading code is not "verifying." Comparing
against training knowledge is not "checking the spec." Use precise language: "read the source
and found no issues", "traced the logic", "looks consistent with existing in-tree code" -- not
"verified correct" or "confirmed safe." Reserve "verified" for concrete actions like checking
a commit exists with `git log --grep`, or confirming a file is present with `git show`. If you
assessed something by reading and reasoning (which is what code review is), say that.

**Deep reasoning**: Reasoning files should walk through the discovery and analysis step by step, so
a reader can independently reproduce the analysis.

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

**Format principles:**
- Be brief; do not repeat the same information. No "intro - content - conclusion" structure.
- Short intro is fine (commit count, brief scope, commit hashes for reference).
- The main content is the issues themselves. Each issue should explain the bug, show
  relevant code, and include a draft fix (or explain why one isn't included).
- Do NOT include severity labels on issues.
- Do NOT include a "Review Result" summary section -- it just repeats the issues.
- End with a link to the reasoning file (when issues were found).

**Structure:**

```markdown
# AI Review: MR !XX - Brief Title

N commit(s) [brief description of what the change does].

**Commits:**
1. **hash** - Commit message
2. **hash** - Commit message

## Issues Found

### Issue 1: Short issue title

**Location:** `path/to/file.c`, `function_name()`, lines ~N-M

[Technical description: what the code does, what's wrong, what the
consequence is. Include a code snippet if it clarifies. Include a
draft fix diff if the fix is straightforward.]

---

### Issue 2: Next issue...

For more details: [URL to reasoning file]
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

**If no issues found:**

```markdown
## Issues Found

No issues found.
```

After "No issues found", briefly describe what was read and what you looked for.
Use honest language about what you did:
- GOOD: "Read all changed source files. Traced error paths -- no leaks spotted."
- GOOD: "Referenced commits checked via git log -- both exist. Read all 9 usage
  sites of the constant -- no issues spotted."
- GOOD: "Code looks consistent with existing in-tree patterns."
- BAD: "Verified correct." "Confirmed safe." "All paths validated."
- BAD: "Verified against the TPM 2.0 spec." (unless you actually fetched the spec)
- BAD: "Verified all scenarios." (unless you ran tests)

You read code and applied judgment. That is valuable but it is not the same as
compiling, running tests, or looking up spec documents. Do not claim otherwise.

#### 7. Create Reasoning File (Only If Issues Found)

**File naming**: `reviews/IDENTIFIER_reasoning.txt`

**Do NOT create** reasoning files for clean reviews.

**Purpose**: The reasoning file is the full verification trail. Another AI (or human)
reading it should be able to reproduce the entire analysis independently, without
access to the original conversation. It must contain enough detail that every
conclusion is independently verifiable.

**Header**: Start with a one-line summary (PR number, title, commit count), then list
all source files read during review and verification.

**Structure** -- for each issue, use a `== Issue N: title ==` header and include:

```
== Issue N: Short title (file.c) ==

Discovery:
What specific code or pattern drew attention. Which file, which line,
what looked suspicious at first glance and why.

Source trace:
Which functions/files were traced and what was found. For example, if
a function returns a malloc'd pointer, trace the function to confirm
the allocation. If an API has specific semantics (e.g., grub_strtol
never sets endp to NULL), trace into the implementation and cite the
specific lines that prove it. Reference concrete line numbers.

Consequence:
What actually goes wrong in practice. Be specific -- not "could leak"
but "leaks one FILE stream and one fd per call, exhausting fd table
after N invocations." Include what the user would see if applicable
(error messages, silent failures, data corruption).

Fix verification:
Why the suggested fix is correct. Confirm it doesn't introduce new
issues (e.g., doesn't mask errors from subsequent operations, doesn't
use-after-free, scoping is correct for the language standard). Note
any caveats (e.g., "fix requires restructuring surrounding code, so
no draft diff included").
```

When the issue involves platform-dependent behavior, verify which platforms
are affected (e.g., check Makefile.core.def for module enable flags). When
the issue involves API semantics, trace into the implementation and cite
specific lines. When the issue involves header conflicts, verify both files
exist and use the same guard.

For AI-assisted code, add an "AI-assistance scrutiny" paragraph noting what
the AI likely got right/wrong and why (e.g., "handled local control flow
correctly but missed the global grub_errno contract").

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

If the code passes all these checks, note in the review intro that AI-assistance
was declared and heightened scrutiny was applied. Do not penalize code that looks
correct for being AI-assisted.

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

### Phase 4: Verify and Deepen Reasoning

**Goal**: After the initial review, re-read actual source code to verify every finding
and ensure reasoning files contain the full verification trail.

This is a separate pass from Phase 1. The reasoning file written during Phase 1 is a
first draft. Phase 4 strengthens it by:

1. Re-reading each source file cited in the reasoning to confirm findings
2. Tracing API semantics into their implementations (not just trusting docs/comments)
3. Checking platform-dependent behavior (module enable flags, type sizes, etc.)
4. Verifying that suggested fixes are correct and don't introduce new issues
5. Adding the verification results to the reasoning file

#### Checklist for each issue

- [ ] Re-read the source file at the branch; confirm the bug exists as described
- [ ] Check for context that might invalidate the finding (guards, cleanup code, etc.)
- [ ] If the issue involves API semantics, trace into the implementation and cite lines
- [ ] If the issue is platform-dependent, check build config (Makefiles, module defs)
- [ ] If the issue involves header/guard conflicts, check both files exist in-tree
- [ ] Read the suggested fix for correctness (doesn't mask errors, no use-after-free)
- [ ] Check fix scoping/types are appropriate for the codebase's language standard

#### Required Depth in Reasoning Files

A good reasoning file lets another AI (or human) who has never seen the code follow
the analysis and arrive at the same conclusion. It should read like a proof, not an
assertion. Every claim must cite a specific file, line, or function.

**Header**: List all source files read during review and verification. This allows a
reader to reconstruct the exact same analysis.

**Per issue**: Discovery (what drew attention) -> Source trace (what was followed and
what was found at each step) -> Consequence (what breaks in practice) -> Fix
verification (why the fix is correct and doesn't introduce new problems).

See the reasoning file format in Phase 1, Step 7 for the exact structure.

#### Example: Thorough Reasoning Entry

```
== Issue 1: Missing fclose(fp) (platform.c) ==

Discovery:
Reading grub_install_efi_is_registered() resource management. FILE
stream opened at line 97 via fdopen(fd, "r"), used in while loop
(lines 103-127) via getline(). After the loop, lines 128-129:
  free(line);
  return rc;
The line buffer is freed but fclose(fp) is never called.

Source trace:
Traced resource lifecycle through the function:
  1. grub_util_exec_pipe() creates a pipe, returns fd (line 85)
  2. fdopen(fd, "r") wraps fd into FILE* fp (line 97)
  3. getline() reads from fp in the loop (line 108)
  4. free(line) releases the line buffer (line 128)
  5. return rc -- fp is NOT closed (line 129)

After fdopen() succeeds, the fd is owned by the FILE stream. Calling
fclose(fp) would close both the stream and the underlying fd.

Cross-reference: get_ofpathname() in the same file (lines 36-78)
follows the identical pattern but correctly calls fclose(fp) at
line 73 before returning. This confirms the omission is unintentional.

Consequence:
Each call leaks one FILE stream and one file descriptor. In current
code the function is called at most once per grub-install invocation,
so the leak is not practically harmful. However, it is a correctness
defect and would become a real problem if the function were called in
a loop.

Fix verification:
Adding fclose(fp) before "return rc" on line 129 is correct. The fp
is not used after the while loop. free(line) must come before
fclose(fp) because getline's buffer is independent of the stream.
The fix does not affect the return value (rc is already computed).
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
- [ ] No severity labels on issues
- [ ] No "Review Result" summary section
- [ ] Each issue has location (file, function, lines)
- [ ] Every bug verified by reading actual source code
- [ ] Draft fix or "not straightforward" explanation for each issue
- [ ] Ends with reasoning file link (when issues found)
- [ ] No repeated information between intro, issues, and link
- [ ] Lines under 120 characters

**Reasoning file:**
- [ ] Only exists for reviews WITH issues
- [ ] Header lists all source files read during review
- [ ] Each issue has Discovery, Source trace, Consequence, Fix verification
- [ ] API semantics traced into implementations (not assumed from docs)
- [ ] Platform-dependent issues verified via build config
- [ ] Specific line numbers referenced throughout
- [ ] Another AI could reproduce the entire analysis from this file alone
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

**Mutation of const environment storage:**
```
grub_env_get() returns a pointer to internal storage (const char *). Code that
casts away const and modifies through the pointer corrupts the environment table.
Even "temporary" mutations (*ext = '\0'; ...; *ext = '.';) are UB and fragile.
Fix: grub_strdup() before mutation, grub_free() after use.
```

**Wrong error check for grub_strtol/grub_strtoull:**
```
grub_strtol() never sets *endp to NULL. On parse failure, *endp points into the
string and grub_errno is set. Checking "if (endp != NULL)" is always true. The
correct check is "if (grub_errno == GRUB_ERR_NONE)".
```

**Platform-dependent type sizes:**
```
sizeof(long) is 4 on 32-bit, 8 on 64-bit. If a spec defines a field as 64-bit,
using long is correct only on 64-bit. Check module enable flags in
Makefile.core.def -- "enable = efi" includes 32-bit platforms. Use fixed-width
types (grub_uint64_t) for spec-defined sizes.
```

**Leaked grub_errno from best-effort operations:**
```
grub_errno is a global that persists until cleared. If a "non-fatal" operation
fails and sets grub_errno but the function returns GRUB_ERR_NONE, the script
executor's grub_print_error() will print a spurious error message. Clear
grub_errno after intentionally-ignored failures.
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

**Overstating what was done:**
```
BAD:  "Verified all scenarios." "Confirmed correct against the spec."
      "All error paths validated." "Memory management verified."
GOOD: "Traced the logic for several scenarios -- no issues spotted."
      "Looks consistent with existing in-tree TPM code (not independently
      checked against the spec)." "Read all error paths -- no leaks spotted."
You read code. You did not compile it, run tests, or consult external specs.
```

---

## Version History

- **3.3.0** (2026-05-26): Added "Honest claims" core principle: say only what you
  actually did; reading code is not "verifying", comparing with training knowledge
  is not "checking the spec." Added clean review language guidance with good/bad
  examples. Added "Overstating what was done" anti-pattern. Softened verification
  checklist language. Removed stale "Review Result" references. Based on feedback
  that clean reviews were claiming verification that was not actually performed.
- **3.2.0** (2026-05-20): Leaner review format: removed severity labels, removed
  "Review Result" section (no intro-content-conclusion repetition), reasoning link
  stands alone at the end. Expanded reasoning file requirements: full verification
  trail (Discovery, Source trace, Consequence, Fix verification), header listing all
  source files read, API semantics must be traced into implementations, platform
  behavior checked via build config. Merged Phase 4 into a verification-focused
  pass. Added 4 new bug patterns: const env mutation, grub_strtol error checking,
  platform-dependent type sizes, leaked grub_errno. Based on PR124/PR126 reviews.
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
