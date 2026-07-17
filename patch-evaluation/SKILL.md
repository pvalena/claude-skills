---
name: Patch Evaluation
description: Evaluate patch sets against upstream — classify, dedup, inspect, and assess for backport/forwardport
author: pvalena
version: 1.0.0
tags: [patches, evaluation, upstream, backport, deduplication, code-review, verification]
---

# Patch Evaluation Skill

**Purpose**: Systematically evaluate a set of patches against an upstream codebase to determine
which carry changes not yet merged, group them for review, and assess whether manual fixing is
worthwhile. Designed for backport, forwardport, and upstream submission workflows.

## When to Use This Skill

Use this skill when:
- Evaluating mailing list patches that failed to apply to current upstream
- Analyzing a set of patches for backport/forwardport to a downstream branch
- Triaging a large queue of patch submissions against moving upstream
- Determining which patches from a feature branch are already upstream
- Auditing patch sets after a rebase to identify what's left to merge
- Assessing the effort required to manually incorporate failed patches

## Core Principles

### 1. Facts over assumptions
Every decision (DROP or KEEP) must cite verifiable evidence: a master line number,
a matching symbol, or a confirmed MISSING file. Never drop based on subject similarity
alone — check the actual code.

### 2. The patch content is authoritative
When a patch failed to apply, the intended change lives in `FAILED.patch` (or equivalent).
The surrounding commit may have conflict markers from auto-resolution. Both together form
the full picture, but the clean diff is in the patch file.

### 3. Mutual exclusivity
A patch is in exactly one state: KEEP (standalone or series) or DROP. No overlaps.
Verify after every change.

### 4. Semantic equivalence beats symbol matching
The same fix can land upstream under a different constant name (`SSIZE_MAX` vs
`GRUB_SSIZE_MAX`), by a different author, or with a different approach. Always check
the code pattern and behavior, not just identifier names.

### 5. Confirm before trusting
Every DROP gets a second verification pass. Individual checks, not batch assumptions.
Log every check.

### 6. Generated output is never edited directly
All derived files (unified logs, overviews) are regenerated from source logs.
Edit the source, regenerate, verify.

## Workflow

### Phase 1: Classification

**Goal**: Categorize every patch by its apply result.

Parse apply logs to produce a classification for each patch:

| Category | Meaning |
|----------|---------|
| ALREADY_APPLIED | Patch applied with "No changes" — already in upstream |
| CLEAN_APPLY | Applied cleanly on retry — has real code changes |
| CONFLICT | Conflict during apply — `FAILED.patch` created with intended change |

**Output**: `classified.txt` with `branch|category` per line.

Cross-reference with any empty-branch list to confirm ALREADY_APPLIED branches.

### Phase 2: Deduplication

**Goal**: Remove older versions and resends, keeping only the latest of each patch.

#### Series grouping
Parse subject lines for `[PATCH vN M/T]` patterns. Group by:
- Same author + same version + same total + same month + sequential IDs

#### Cross-version dedup
Same topic across v2/v3/v4... → keep latest. **Critical**: verify using commit
dates, not just version numbers. A `v6` from March can be older than a `v2` from
September.

#### Resend detection
Same commit subject + same author at different dates → keep latest by date.

#### Re: entries
Re: prefixed patches are real submissions. Never auto-drop. Check each:
if the topic is covered by a non-Re: patch in the remaining set, drop the Re:.
If uncovered, recover it.

#### Date-conflict resolution
When version number and date disagree, trust the date. Document the correction.

**Output**: `series/*` (grouped patches), `standalone.txt` (ungrouped), `drop.txt`.

**Key files**: every drop must have a `superseded_by` reference pointing to the
kept branch. Resolve chains so no reference points to another drop.

### Phase 3: Code Inspection

**Goal**: For each remaining patch, determine if its changes exist on upstream.

This is the most critical phase. Subject matching is insufficient.

#### Per-patch method

1. Read `FAILED.patch` diff — identify target files and key symbols/functions
2. Check upstream: `git show master:<file>` + grep for distinctive additions
3. If all changes found on master → DROP with evidence (file:line references)
4. If any change NOT on master → KEEP

#### Inspection tools

Create helper scripts for consistency:
- `inspect.sh <series>` — show all data for a series
- `inspect-standalone.sh <branch> ...` — show data for standalone patches

Both should output: metadata, FAILED.patch content, master file state, key symbols.

#### Common traps

| Trap | Example | Solution |
|------|---------|----------|
| Different constant name | `SSIZE_MAX` vs `GRUB_SSIZE_MAX` | Check the code pattern, not the name |
| Different author, same fix | Two people fix same bug | Check if master has ANY fix for the issue |
| HTML-encoded patches | Re: emails with `&gt;` entities | Use `strings` for field extraction |
| Binary content in patch | Reproducer files embedded in email | `grep` fails silently — use `strings` |
| Partially upstream | 3 of 5 series members merged | Keep only the unmerged members |
| Content merged via other patch | Docs added by a later series | Check actual content on master, not just titles |
| Symbol match ≠ semantic match | grep hits but logic differs | Read surrounding context, not just the hit |

#### Logging

For every branch, create an entry in the inspection log with:
- Branch ID, heading with DROP/KEEP decision
- Subject, author, target files
- Evidence: what was checked, what was found (with line numbers)

Maintain two source logs: one for series decisions, one for standalone.
Generate a unified view from both — never edit the unified file directly.

### Phase 4: Confirmation

**Goal**: Second pass verifying every DROP decision.

For each drop, re-check the specific evidence claim against master:

| Drop type | Check method |
|-----------|-------------|
| Already upstream (specific symbol) | grep symbol on master, confirm match |
| ALREADY_APPLIED (empty branch) | Verify commit subject = master tip, no patch file |
| Superseded by later version | Confirm same target files in the superseding version |

Log all checks via `tee -a confirmation.log`. Track confirmed branches in
`confirmed.txt` (standalone) and `confirmed_series.txt` (series heads).

**Never batch-confirm.** Each branch gets its own check with visible output.

### Phase 5: Cross-Topic Grouping

**Goal**: Find patches that should be reviewed together.

After inspection, check for:
- Standalones touching the same specific files as another standalone or series
- Same topic by different authors (multi-author series are valid)
- Older versions superseded by newer ones within the KEEP set

**Exclude infrastructure files** from overlap analysis: `Makefile.core.def`,
`configure.ac`, `docs/grub.texi` — many unrelated patches touch these.

When grouping: merge into the existing series file, ordered by part number.
When a series member is found upstream, remove it. If a series becomes a
singleton, dissolve it to standalone.

### Phase 6: In-Depth Evaluation

**Goal**: Assess each KEEP patch for complexity, risk, and manual fix effort.

Generate per-patch evaluation files containing:
- Full commit message
- Complete FAILED.patch content
- Conflict resolution artifacts (if any)
- Master context for affected files
- Assessment: type, complexity, patch size, risk, manual fix effort

Categorize patches: Bug fix, New feature, Enhancement, Compatibility, RFC, Documentation.

Perform category-by-category code review in dedicated log files (`EVALUATION_LOG_*.md`).

#### Re-verification during evaluation

In-depth evaluation WILL find patches that earlier phases incorrectly kept.
This is expected — earlier phases use symbol/pattern matching, evaluation reads
the actual code. After each category is evaluated:

1. **Re-verify every KEEP** in that category against current master. Don't trust
   earlier evidence — check again with targeted queries.
2. **Check for semantic equivalence**: the same fix can land on master under a
   different name, by a different author, or via a different approach. Examples:
   - `SSIZE_MAX` vs `GRUB_SSIZE_MAX` — same constant, different namespace
   - `curr = min_size` vs `curr += (run_size + 1)` — different fix for same bug
   - Documentation section added via a different patch in a later series version
3. **For series members marked "Already upstream"**: verify the ENTIRE patch
   content is on master, not just a key symbol. If fully redundant, remove from
   the series (dissolve to standalone if singleton remains).
4. **Drop and re-run verification** after each finding. Update all logs, regenerate
   unified view, run consistency checks.

This step converts approximately 5-15% of remaining KEEPs to DROPs. It is not
optional — skipping it means shipping redundant patches.

### Phase 7: Continuous Verification

**Goal**: Maintain consistency across all data files.

Run after every change — no exceptions:

```bash
# Regenerate derived files
python3 generate_unified.py
python3 generate_evaluation_overview.py

# Verify consistency
python3 verify_unified.py
./verify.sh
```

#### Consistency invariants

- No branch in both DROP and KEEP lists
- Every DROP has an entry in an inspection log
- Every KEEP has an entry in an inspection log
- Every standalone DROP is in `confirmed.txt`
- Every series DROP head is in `confirmed_series.txt`
- No duplicate headings in the unified log
- No branch heading in wrong section (KEEP branch in DROP section or vice versa)

## File Organization

```
├── standalone.txt           # KEEP branches not in series
├── series/                  # KEEP series (one file per series, ordered)
├── drop.txt                 # All DROP branches
├── confirmed.txt            # Verified standalone drops
├── confirmed_series.txt     # Verified series drop heads
├── evaluated.txt            # In-depth evaluated branches
├── evaluation/              # Per-branch evaluation data files
│
├── INSPECTION_LOG.md            # Source: series decisions
├── INSPECTION_LOG_STANDALONE.md # Source: standalone decisions
├── INSPECTION_LOG_UNIFIED.md    # Generated: unified view
├── EVALUATION_LOG_*.md          # In-depth code reviews by category
├── EVALUATION_OVERVIEW.md       # Generated: summary table
├── confirmation.log             # Raw verification output
│
├── inspect.sh                   # Inspect a series
├── inspect-standalone.sh        # Inspect standalone branches
├── add-drop.sh                  # Add to drops (dedup)
├── add-confirmed.sh             # Add to confirmed (dedup)
├── add-evaluated.sh             # Add to evaluated (dedup)
├── generate_unified.py          # Regenerate unified log
├── generate_evaluation.sh       # Generate evaluation files
├── generate_evaluation_overview.py  # Generate overview table
├── verify.sh                    # Full consistency check
└── verify_unified.py            # Unified log consistency check
```

## Red Flags

**Stop and re-examine if**:
- A batch of patches all get the same decision — homogeneity suggests missed nuance
- A "KEEP" patch's FAILED.patch content looks very similar to master code — check more carefully
- grep returns 0 hits for a function that "should" be there — binary content or regex issue
- A series member is upstream but you're keeping the whole series — remove the upstream member
- The verification script passes but you haven't run it after the last change

## Checklist

### Per-batch
- [ ] Inspected each patch's FAILED.patch content
- [ ] Checked master for semantic equivalence (not just symbol matching)
- [ ] Logged every decision with evidence in the appropriate log
- [ ] Added drops to drop list and confirmed list
- [ ] Removed drops from keep lists (standalone/series)
- [ ] Dissolved singleton series to standalone
- [ ] Regenerated unified log
- [ ] Ran both verification scripts
- [ ] Updated evaluation overview if keeps changed

### Per-evaluation
- [ ] Read the full commit message for context
- [ ] Reviewed the FAILED.patch code changes
- [ ] Noted conflict markers in commit code (if any)
- [ ] Checked master context for affected files
- [ ] Assigned category (bug fix / new feature / enhancement / etc.)
- [ ] Assessed complexity, risk, and manual fix effort
- [ ] Added to evaluated.txt

## Version History

- **1.0.0** (2026-07-17): Initial version based on GRUB2 patch analysis of 1302
  mailing list patches. Developed through 7 iterative phases with continuous
  refinement of classification, inspection, and verification methods.

## See Also

- **review** - Full code review workflow for individual patches
- **sanity-check** - Quick malicious-intent scan before processing patches
