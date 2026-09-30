---
name: Code Review
description: Complete workflow for reviewing patches/commits, documenting findings, and formatting results
author: pvalena
version: 3.16.0
tags: [code-review, documentation, formatting, security, quality, verification, false-positives]
---

# Code Review Skill

**Purpose**: Complete workflow for reviewing code changes (patches, commits, merge requests),
documenting findings with technical precision, assessing correctness by reading source code,
drafting fixes, and producing deep technical reasoning. This is the deep, human-directed
counterpart to fast automated triage -- for that, use the built-in `/review` and `/code-review`.

## When to Use This Skill

- Reviewing patches, commits, or merge requests for code quality and correctness
- Need to document code review findings in a structured format
- Creating review files, reasoning files, and draft fix patches
- Verifying existing reviews for false positives or missed issues
- **Not** for quick automated triage or inline PR comments (use `/code-review` or `/review`) --
  this skill's value is the manual process: reasoning trail, draft fixes, and a double-check pass

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

**Depth scales with complexity**: MRs touching low-level memory management (page tables, MMU),
networking state machines (TCP, connection lifecycle), cryptographic or security-critical code,
or inline assembly require deeper analysis than routine changes. For these, trace through
concrete examples (e.g., compute page counts for specific memory sizes), verify edge cases,
check callback ordering and reentrancy safety, and confirm state machine transitions. Report
the deeper analysis even when no issues are found -- the thoroughness is the value.

---

## Complete Workflow

### Phase 0: Sanity Check

**Goal**: Verify the patch is not malicious before processing its content.

**IMPORTANT**: Do NOT run `git log`, `git diff`, or any command that returns
raw branch content before Phase 0 completes. Phase 1's commands (listing
commits, reading messages, reading diffs) come AFTER the sanity check passes.

Run the `sanity-check` skill against the branch. See that skill for the
complete 3-step procedure (automated scan, manual inspection, evaluation).

If REJECT: **stop immediately** -- do not proceed to Phase 1.

If SUSPICIOUS: note the flags and apply extra scrutiny during Phase 1.

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

**For non-C changes, also check:**
- CI/YAML: incorrect job classifications or stage references, broken include paths,
  wrong rule conditions, tests moved between categories without updating type
- Shell scripts: unquoted variables, missing error handling with `set -e`, cleanup
  paths that skip files, incorrect guards (`test -n` vs `test -z`)
- Drivers/hardware: device lifecycle (init must be fully reversible on failure),
  DMA safety (device must be stopped before freeing buffers it can write to),
  ring buffer management (descriptor reuse, avail/used ring updates),
  platform-dependent behavior (check actual implementations, not assumptions)

**What NOT to report:**
- Style preferences (naming, formatting, comment style)
- Optimization suggestions (unless correctness is affected)
- Alternative implementations (unless current is demonstrably wrong)
- Theoretical issues without concrete impact
- Pre-existing bugs on the base branch not introduced by this patch

#### 6. Create Review File

**File naming**: `reviews/IDENTIFIER.md` (e.g., `pr89.md`, `2025-05-0103.md`)

**Format principles:**
- Be brief; do not repeat the same information. No "intro - content - conclusion" structure.
- Short intro is fine (commit count, brief scope, commit hashes for reference).
- The main content is the issues themselves. Each issue should explain the bug, show
  relevant code, and include a draft fix (or explain why one isn't included).
- Keep issue descriptions concise: state the bug, its consequence, and the fix. The full
  analysis trail (macro expansions, implementation internals, caller tracing) belongs in
  the reasoning file -- do not duplicate it in the review.
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

## Additional findings

[Brief, crucial observations only.]

For more details, see
[IDENTIFIER_investigation.txt](URL).
```

After "No issues found", add an "## Additional findings" section with
the most important observations only -- things a reviewer must know at
a glance (e.g., which CVEs are fixed, what the key GRUB-specific
patch does, why a seemingly-suspicious pattern is actually correct).

Two recurring kinds of observation are worth calling out explicitly,
because they read like bugs but are not, and a reviewer who skips them
wastes time re-deriving the same conclusion:

- **Runtime no-op for current callers**: a change that is correct in
  isolation but has no observable effect given every in-tree caller.
  State it as such and name the caller that makes it a no-op. Example:
  "The TPM2_VerifySignature marshalling reorder (692310f14) has no
  runtime effect for the sole caller (module.c:726 passes
  authCommand==NULL); it is a correct spec-conformance fix for future
  callers." This tells a reviewer the fix is right AND that it cannot
  be the cause of any behavior change they are chasing.
- **Unreachable-but-real spec deviation**: code that genuinely deviates
  from a spec/structure definition but cannot be triggered by any
  in-tree path. Record it as an observation, not an issue, and state
  both the deviation and why it is unreachable. Example: "The generic
  TPMU_ASYM_SCHEME marshaller now emits a hashAlg for TPM_ALG_RSAES,
  whose union member is empty in the TPM 2.0 tables; no in-tree caller
  marshals an RSAES scheme, so there is no concrete impact." Do not
  promote these to "Issues Found" (they have no failing input today),
  but do not silently drop them either -- they are the seam where a
  future caller introduces a real bug.

Both belong under "Additional findings", never under "Issues Found",
since neither has a concrete failure case in the current tree.

**For large/complex clean reviews** (library imports, multi-file
refactors, crypto code, or any MR where significant analysis was
needed to conclude "no issues"), create an investigation file
(`reviews/IDENTIFIER_investigation.txt`) and link it from the review
with "For more details, see [IDENTIFIER_investigation.txt](URL)."
The investigation file documents what was checked and why nothing
was found -- it serves as proof of thoroughness, analogous to a
reasoning file for reviews with issues. Move all detailed analysis
(per-file traces, edge case verification, regex behavior analysis,
API contract verification) to the investigation file. The review's
"Additional findings" section should then be 3-6 lines covering
only the crucial points.

**For small/simple clean reviews** (1-3 commits, single file, routine
changes), an investigation file is not needed. Keep the "Additional
findings" section brief (a few sentences of non-obvious observations).

Do NOT restate process facts ("read the full source", "commit messages
match") -- those are taken for granted. Do NOT add per-commit
paragraphs repeating what commit messages already say.

Use honest language about what you did:
- GOOD: "The pre-existing write_cr0 bug is still present -- MR !140
  addresses it separately. This MR's changes don't interact with it."
- GOOD: "The guard prevents a concrete corruption scenario: without it,
  a second enable call would overwrite the saved register values."
- BAD: "Verified correct." "Confirmed safe." "All paths validated."
- BAD: "Verified against the TPM 2.0 spec." (unless you actually fetched the spec)

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
all source files read during review.

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

Fix assessment:
Why the suggested fix looks correct based on reading the code. Check
that it doesn't introduce new issues (e.g., doesn't mask errors from
subsequent operations, doesn't use-after-free, scoping is appropriate
for the language standard). Note any caveats (e.g., "fix requires
restructuring surrounding code, so no draft diff included").
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

When commit messages contain `Assisted-by:`, `Co-authored-by:` with
an AI tool name, apply additional scrutiny:

1. **Verify commit message claims**: AI messages may reference
   commits/functions that don't exist. Check with `git log --grep`.
2. **Holistic fit**: AI code can be locally correct but miss build
   system interactions, downstream consumers, or project patterns.
3. **Comments/docs accuracy**: AI comments may contain subtle
   inaccuracies. Read every added comment critically.
4. **Trace execution paths**: AI code often handles the common case
   but misses edge cases or platform-specific assumptions.
5. **Don't assume from plausibility**: Verify in actual source, not
   by reading the diff and nodding along.

Note AI-assistance in the review intro when detected. Do not penalize
code that looks correct for being AI-assisted.

#### Agent-Delegated Reviews

When reviews are produced by spawned agents, treat every finding as
a draft and every clean result as unverified. Agents have two
failure modes: false claims (asserting behavior from training data)
and format gaps (verbose findings, missing investigation files).

**Claim verification** — three claim types need scrutiny:

- **Spec compliance**: "Per the virtio 1.0 spec..." — agent recalled
  training data, did not fetch the spec. Confirm via in-tree code or
  soften language.
- **Platform behavior**: "On i386_ieee1275, this function does X" —
  read the actual implementation. (PR133: claimed cleanup was a
  no-op.)
- **API contracts**: "This function never returns NULL" — check if
  the reasoning cites actual source lines or just asserts.

**Format and completeness audit** — agents typically produce
correctly structured reviews but miss two things:

- **Verbose Additional findings**: agents tend to put verification
  detail directly in the review instead of creating an investigation
  file. If the Additional findings section exceeds ~6 lines, move
  the detail to an investigation file and trim the review.
- **Missing investigation files**: agents don't create investigation
  files for complex clean reviews. The main reviewer must identify
  which agent-reviewed MRs are complex enough (new modules, page
  table math, crypto, multi-file refactors) and create
  investigation files for them.

**Process**: For each agent-produced review:
1. Read the actual diff and verify the conclusion (especially for
   the more complex MRs in the batch)
2. Check claims about behavior outside the changed files — if the
   agent cites source lines, spot-check; if it asserts, confirm
   or drop the finding
3. Check Additional findings for verbosity — trim and move to
   investigation file if needed
4. Create investigation files for complex clean reviews the agent
   missed
5. Never pass through an agent's claim or report agent results to
   the user without this audit

#### Two-Agent Delegation Pipeline

An alternative to the single-agent-plus-orchestrator-audit above:
delegate the verification to a second agent instead of doing it in
the main context. Preferred when review volume is high.

1. **Review agent** (one may handle several MRs) runs Phases 0-6 and
   writes all artifacts — including the companion file when warranted
   (reasoning for reviews with issues; investigation for large/complex
   clean reviews). Producing companions is the review agent's job.
2. **Adversarial agent** in a *separate, fresh context* independently
   re-verifies every finding against source, hunts for false positives
   and missed issues (false negatives), and checks the linter. This
   pass replaces the orchestrator's own re-verification from the
   single-agent model.
3. **Orchestrator (main model)** reads the review and approves. It does
   NOT re-verify against source routinely — the adversarial agent did
   that. Spot-check source only on a red flag: a claim likely beyond
   agent competence (subtle low-level/UB, crypto, spec or platform
   assertions). Run the linter before approving. If a needed companion
   file is missing, send the review agent back to produce it rather
   than writing it in the main context.

Trade-off: the fresh-context adversarial pass catches more than an
orchestrator audit (no shared blind spots) at the cost of a second
agent run. Keep the single-agent audit above for one-off reviews.

#### For Clean Reviews

Re-read the diff and source code looking for anything missed:
- Trace all error paths for resource leaks
- Check all pointer dereferences for NULL safety
- Check return value semantics match caller expectations
- Look for documentation/code mismatches

For complex domains (page table math, TCP state machines, crypto/security,
inline assembly), go beyond a clean pass: trace concrete examples through the
logic (e.g., specific memory sizes through page calculations, specific packet
sequences through connection state), verify callback ordering, and check
reentrancy safety. A quick clean pass is not sufficient for these areas.

#### Common False Positive Patterns

- **Double-free**: Review missed `ptr = NULL` between two frees
- **NULL deref**: Review missed a guard check earlier in the function
- **Resource leak**: `fd = open(); if (!fd) return;` — fd is 0
  (invalid), not a real fd

#### If You Find a False Positive

Remove from review, update reasoning, re-verify all other findings
in the same review (pattern of errors).

#### If You Find a Missed Issue

Add to both the review file and reasoning file.

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

### Phase 4: Deepen Reasoning

**Goal**: Ensure reasoning files contain the full analysis trail with enough depth
for independent reproduction.

This is not a separate re-read pass (that happens in Phase 2). Phase 4 is about
strengthening the reasoning file's depth and clarity:

1. Filling in gaps: if a source trace skips steps, add the intermediate reasoning
2. Adding cross-references: cite similar patterns elsewhere in the codebase
3. Checking that platform/API claims cite actual source lines (not just assertions)
4. Assessing suggested fixes for correctness by reading the surrounding code
5. Ensuring the reasoning file is self-contained (another reader needs no context)

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
assessment (why the fix looks correct and doesn't introduce new problems).

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

Fix assessment:
Adding fclose(fp) before "return rc" on line 129 looks correct. The fp
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

#### Commit Message Verification

For each commit, check that the commit message accurately describes
what the code change actually does. This is a basic semantic check,
not strict formatting or grammar review. Flag messages that:
- Claim to fix X but the code fixes Y
- Describe a mechanism that doesn't match the implementation
- Reference functions, files, or behaviors that don't exist in the diff

Note the result in the review: "Commit messages accurately describe
the changes" or flag specific mismatches.

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
- [ ] Every bug confirmed present by reading actual source code
- [ ] Draft fix or "not straightforward" explanation for each issue
- [ ] Ends with reasoning file link (when issues found)
- [ ] No repeated information between intro, issues, and link
- [ ] Commit messages verified to match code changes
- [ ] Lines under 120 characters

**Reasoning file:**
- [ ] Only exists for reviews WITH issues
- [ ] Header lists all source files read during review
- [ ] Each issue has Discovery, Source trace, Consequence, Fix assessment
- [ ] API semantics traced into implementations (not assumed from docs)
- [ ] Platform-dependent issues verified via build config
- [ ] Specific line numbers referenced throughout
- [ ] Another AI could reproduce the entire analysis from this file alone
- [ ] Lines under 120 characters

---

### Phase 6: Double-Check

**Goal**: Independent re-verification pass after all review artifacts are
written. Catch issues missed in earlier phases and confirm reported findings
are real, with fresh eyes.

This phase runs AFTER the review file, reasoning file, draft fixes, and
formatting are all complete. It is a final quality gate, not a repeat of
Phase 2 — by this point the review is "done" and the double-check is an
adversarial re-read looking for mistakes in your own work.

#### For Each Reported Issue

1. Re-read the actual source at the branch one more time:
   ```bash
   git show BRANCH:path/to/file.c | sed -n 'START,ENDp'
   ```
2. Independently confirm the bug exists as described — do not rely on
   your earlier reading; re-derive the conclusion from the code
3. Verify the draft fix is correct:
   - Buffer sizes and offsets are calculated correctly
   - The fix doesn't introduce new issues (leaks, overflows, etc.)
   - The fix matches the surrounding code style and patterns

#### For Missed Issues

Re-read the full diff and key source sections looking for anything the
initial review missed:
- Trace all error paths for resource leaks one more time
- Check all pointer dereferences for NULL safety
- Check buffer size calculations and memcpy/memset bounds
- Look for off-by-one errors in loop bounds or array indices
- Verify return value semantics match caller expectations

#### If the Double-Check Finds Something

- **False positive found**: Remove from review file, update reasoning
  file, re-check all other findings in the same review
- **Missed issue found**: Add to review file and reasoning file,
  including the full Discovery/Source trace/Consequence/Fix assessment
- **Draft fix error found**: Correct the fix in the review file,
  update the fix assessment in the reasoning file

---

## Reviewing Multiple MRs

When reviewing several MRs at once, run reviews in parallel where
possible. Split into batches by complexity — large/complex MRs
standalone, small ones in agent batches.

1. **List all MRs** with commit counts and diff sizes
2. **Split by complexity**: large MRs (hundreds of lines, new modules,
   crypto, page tables) reviewed standalone; small/mechanical MRs
   batched to agents
3. **Review in parallel** -- each MR is independent
4. **Post-agent audit** (mandatory before reporting results):
   - Read the actual diff for each agent-reviewed MR and verify
     the "no issues" conclusion is correct — especially for the
     more complex ones in the batch
   - Check Additional findings sections for verbosity: detail
     belongs in investigation files, not in the review
   - Check whether any agent-reviewed MR is complex enough to
     need an investigation file (agents typically don't create
     them — the main reviewer must identify gaps and create them)
   - Verify 120-char line width compliance
   - Only after the audit passes, report results to the user
5. **Draft fixes** -- add patches or explanations to each review
6. **Deep reasoning** -- ensure reasoning files have full depth
7. **Double-check** -- independent re-verification of findings

---

## Re-reviewing Updated MRs

When an MR is re-submitted (rebased, amended, or extended), the goal
is to review only what changed — not repeat the full review.

### 1. Identify What Changed

Compare old commit hashes (from the existing review file) against the
new branch. Old hashes survive as dangling objects after a rebase.

```bash
# Verify old hashes still exist
git cat-file -t OLD_HASH

# Compare patch content (ignoring rebase-induced blob hash changes)
diff <(git diff OLD^..OLD) <(git diff NEW^..NEW)
```

Zero diff = identical commit (just rebased). Non-zero = actual change.

Also check whether origin/master moved between rebases:
```bash
git log --oneline OLD_HASH^..NEW_HASH^ | head -10
```

Master movement changes blob hashes but not the MR's own patch
content. The `diff <(git diff ...)` comparison handles this correctly.

### 2. Classify Each Commit

For each commit in the new branch, determine:
- **Unchanged**: zero patch-level diff vs old version. State this
  briefly in the review ("Commits 1-2 unchanged, verified").
- **Reworked**: same purpose, different content. Focus review on the
  delta — what was added, removed, or restructured.
- **New**: not present in the old branch. Full review needed.

### 3. Update Review File

- Update the commit list (new hashes, new count).
- Add a "Re-review" header line stating what changed.
- For unchanged commits: one line ("unchanged, verified").
- For reworked/new commits: review as normal, but keep the review
  brief — move detailed analysis to the investigation file.
- Do NOT repeat findings or analysis from the previous review that
  still applies. The previous review file is still available.

### 4. Update Investigation File

Append a dated re-review section documenting:
- Verification method (how old vs new commits were compared)
- Analysis of each new or reworked commit
- Confirmation that unchanged commits are truly unchanged

### 5. When the Re-review Becomes Clean

A re-review often flips a review from "issues found" to clean: the prior
issue was fixed, and the fix (or a broader rework of the same area) is
correct. Re-review the reworked area *fully* — a fix frequently comes with
restructuring that can introduce or, as often, silently fix other bugs.
Once it is clean, handle the companion files so history is preserved and the
files stay self-consistent:

- **Keep the prior round's `IDENTIFIER_reasoning.txt` unchanged.** It is the
  record of the issue that was found and fixed. Deleting it loses the
  history; editing it rewrites what a past review actually said. Leave it.
- **Create a new `IDENTIFIER_investigation.txt`** for the current clean
  re-verification — the customary companion for an issue-free review (Phase
  1, step 6). Put the reworked-code analysis there (bounds, memory,
  enforcement, plus any latent bugs the rework also fixed).
- **Write the review in the clean format**: a "Re-review" section stating the
  prior issue is fixed (show the applied fix), then "No issues found", an
  "Additional findings" section, and the "For more details" link pointing to
  the *investigation* file — not the retained reasoning file.

This is the one sanctioned case where a "No issues found" review keeps a
`_reasoning.txt`: it is a prior round's artifact, and an `_investigation.txt`
must be present alongside it. A clean review with a *lone* `_reasoning.txt`
(no investigation file) is still an inconsistency to fix — the reasoning file
is a genuine leftover.

---

## Common Bug Patterns

These are language-neutral patterns worth checking on any review. For pitfalls
tied to a specific API contract, see Project-Specific Patterns below -- those are
examples to replace with your own project's idioms.

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

**Mutation of storage owned by an accessor:**
```
An accessor returns a pointer into internal/shared storage (often const char *).
Code that casts away const and mutates through the pointer corrupts that storage.
Even "temporary" mutations (*ext = '\0'; ...; *ext = '.';) are UB and fragile.
Fix: copy before mutation (e.g. strdup), free the copy after use.
(GRUB example: grub_env_get() returns internal environment-table storage.)
```

**Platform-dependent type sizes:**
```
sizeof(long) is 4 on 32-bit, 8 on 64-bit. If a spec defines a field as 64-bit,
using long is correct only on 64-bit. Confirm which platforms a module actually
builds for before assuming a width -- a build config may include 32-bit targets.
Use fixed-width types (e.g. uint64_t) for spec-defined sizes.
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

### Project-Specific Patterns (GRUB/C examples -- replace with your project's)

These illustrate the *shape* of API-contract bugs, not a fixed checklist. Swap in
the error-handling and parsing idioms of the code you actually review.

**Wrong error check for a parse API (grub_strtol/grub_strtoull):**
```
grub_strtol() never sets *endp to NULL. On parse failure, *endp points into the
string and grub_errno is set, so "if (endp != NULL)" is always true. The correct
check is "if (grub_errno == GRUB_ERR_NONE)". Generalize: verify a parser's actual
failure signal, not an assumed one.
```

**Leaked global error state (grub_errno):**
```
grub_errno is a global that persists until cleared. If a "non-fatal" operation
fails and sets grub_errno but the function returns GRUB_ERR_NONE, a later
grub_print_error() prints a spurious message. Clear the global after
intentionally-ignored failures. Generalize: any global/thread-local error state
(errno, GetLastError) leaks across best-effort calls if not reset.
```

---

## Anti-Patterns to Avoid

**Asserting without proving**: BAD: "This could cause a double-free."
GOOD: "free() at line 2099 does not NULL the pointer. Line 2143
retrieves the same pointer. Line 2196 frees it again."

**Vague consequences**: BAD: "This might cause problems." GOOD:
"grub-install reports success but no EFI boot entry is created."

**Suggesting fixes in reasoning files**: Fixes go in the review .md,
not in reasoning. Reasoning states facts: "fp is never closed before
return rc on line 129."

**Reporting style as bugs**: Don't. Only report correctness issues.

**Overstating what was done**: BAD: "Verified all scenarios." GOOD:
"Traced the logic for several scenarios -- no issues spotted." You
read code — you did not compile, run tests, or consult external specs.

---

## Version History

- **3.16.0** (2026-09-30): Clarified scope in Purpose/When to Use -- this skill is the deep,
  human-directed counterpart to the built-in `/review` and `/code-review` automated triage.
- **3.15.0** (2026-09-30): Genericized Common Bug Patterns -- generic patterns
  are now language-neutral; GRUB/C-API-specific ones moved to a clearly-marked
  "Project-Specific Patterns" subsection to replace per project.
- **3.14.0** (2026-08-26): Two-agent delegation pipeline: a review agent
  writes artifacts (and its own companion files), a separate fresh-context
  adversarial agent re-verifies, and the orchestrator approves without
  routine re-verification (spot-checks only on red flags; bounces missing
  companions back to the review agent).
- **3.13.0** (2026-08-22): Re-review "became clean" handling: re-review the
  reworked area fully, keep the prior round's `_reasoning.txt` unchanged for
  traceability, add a new `_investigation.txt` for the clean re-verification,
  and write the review in clean format linking the investigation file. The
  one sanctioned case where a "No issues found" review keeps a reasoning file
  (an investigation file must be present too).
- **3.12.0** (2026-08-21): Named two recurring clean-review "Additional
  findings" categories -- runtime no-ops for current callers, and
  unreachable-but-real spec deviations -- with guidance to record both
  as observations (never under "Issues Found", since neither has a
  concrete failure case today). Drawn from the MR !227 TPM2 review.
- **3.11.0** (2026-07-23): Post-agent audit, format/completeness checks for agent-delegated reviews
- **3.10.0** (2026-07-21): Re-review workflow for updated MRs
- **3.9.0** (2026-07-16): Investigation files for large clean reviews
- **3.8.0** (2026-06-29): Phase 0 references sanity-check skill
- **3.7.0** (2026-06-25): Phase 6 (Double-Check) added
- **3.6.0** (2026-06-16): Brief clean reviews, commit message verification
- **3.5.0** (2026-06-09): "Depth scales with complexity" principle
- **3.4.0** (2026-05-27): Phase 0 (Sanity Check) added
- **3.3.0** (2026-05-26): "Honest claims" principle, agent-delegated
  reviews, non-C review targets (CI/YAML, shell, drivers)
- **3.2.0** (2026-05-20): Leaner format, expanded reasoning file
  requirements, 4 new bug patterns
- **3.1.0** (2026-05-14): AI-generated code verification
- **3.0.0** (2026-05-03): Major restructure with 6 phases
- **2.x**: Verification phase, false positive prevention
- **1.0.0**: Initial version

## See Also

- **refresh-docs** - For updating documentation after reviews change project state
- **auto-memory** - For capturing review workflow knowledge in project MEMORY.md
