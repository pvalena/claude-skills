---
name: Documentation Refresh
description: Systematic workflow for updating, synchronizing, and verifying project documentation
author: pvalena
version: 1.0.0
tags: [documentation, maintenance, consistency, verification, repository-state]
---

# Documentation Refresh Skill

**Purpose**: Maintain accurate, consistent, and synchronized project documentation across multiple files
as the repository state evolves.

## When to Use This Skill

Use this skill when:
- Project state has changed (new features, completed phases, updated statistics)
- Documentation files are out of sync with current reality
- Need to verify documentation accuracy and consistency
- Major milestone reached requiring documentation update
- Multiple documentation files need coordinated updates

## Core Principles

**Single source of truth**: Each fact should be documented in one authoritative location and referenced
elsewhere.

**Consistency**: Same information must be identical across all files where it appears.

**Currency**: Documentation must reflect current state, not historical state (unless explicitly historical).

**Verification**: After updates, verify all cross-references and numbers match reality.

**Distillation**: Each document has a specific purpose. CLAUDE.md = essentials only. MEMORY.md = complete
reference. docs/*.md = detailed procedures.

---

## Complete Workflow

### Phase 1: Identify What Changed

**Goal**: Determine what needs updating before making changes.

#### 1. Review Recent Work

Check conversation history, commits, or recent changes:
- What phases completed?
- What statistics changed?
- What new workflows were established?
- What files were added/removed?
- What principles were learned?

#### 2. List Affected Documentation

Common documentation files:
- `CLAUDE.md`: Repository instructions and essentials
- `MEMORY.md`: Current state and complete workflows
- `README.md`: Public-facing overview
- `docs/*.md`: Detailed process documentation
- Tracking documents (e.g., `MRS_BY_AUTHOR.md`)

#### 3. Identify Inconsistencies

Compare numbers across files:
```bash
# Example: Check if MR counts match
grep -E "Open MRs|Total MRs|MR.*:" CLAUDE.md MEMORY.md docs/*.md

# Check dates
grep -E "Last updated|Updated:" CLAUDE.md MEMORY.md docs/*.md

# Check statistics
grep -E "authors|branches|reviews" CLAUDE.md MEMORY.md
```

### Phase 2: Update Documentation Files

**Order matters**: Update from specific → general (detailed docs first, overview docs last).

#### 1. Update Detailed Process Documentation (docs/*.md)

These contain procedures, examples, and detailed workflows.

**What to update**:
- Current statistics (counts, percentages)
- File structure diagrams
- Example commands with current data
- Quality checklists
- Last updated dates

**Example**: `docs/REVIEW_PROCESS.md`
```markdown
**Last updated**: YYYY-MM-DD
**Open MRs**: XX
**Review files**: XX (.md) + XX (_reasoning.txt)
**Master base**: <commit-hash>
```

**Preserve**:
- Procedures and workflows (unless changed)
- Examples (update numbers, not methodology)
- Commands and code blocks (unless improved)

#### 2. Update Repository Memory (MEMORY.md)

This is the complete reference for current state and workflows.

**What to update**:
- **Current Status section**: All numbers (open, closed, active authors)
- **Key Files section**: File counts and descriptions
- **Recent Work section**: Add new completed items
- **Statistics section**: Update all metrics
- **Workflow sections**: Add new workflows, update existing
- **Last updated date**

**Structure**:
```markdown
# Repository Memory - Current State

**Last updated**: YYYY-MM-DD

## Current Status
- **Total tracked**: XX
- **Open**: XX
- **Closed**: XX
- **Active authors**: XX

## Key Files
[Descriptions with current counts]

## [Workflow Sections]
[Complete procedures]

## Recent Work (YYYY-MM-DD)
[List of completed items]

## Statistics
### Current (YYYY-MM-DD)
[All current metrics]
```

**Important**:
- MEMORY.md should be self-contained
- Include complete workflows (not just references)
- Update ALL statistics, not just some
- Add date to section headers when updating

#### 3. Update Repository Instructions (CLAUDE.md)

This should contain **bare essentials only** - no detailed procedures.

**What to update**:
- **Completed Work Summary**: Add new phases, update counts
- **Core Principles**: Add new principles learned
- **File Organization**: Update counts, add new sections
- **Restrictions and Best Practices**: Add new learnings
- **Last updated date**

**What NOT to include**:
- Detailed workflows (→ MEMORY.md)
- Procedural steps (→ docs/*.md)
- Examples and commands (→ docs/*.md)
- Historical details (→ MEMORY.md)

**Keep it concise**:
```markdown
### Phase X: Name (STATUS)
- **Key metrics**: Brief summary
- **Quality**: Brief achievement summary
- **Key files**: List only
```

**Typical size**: 100-150 lines (distilled essentials)

#### 4. Update Tracking Documents

Documents that track current state (e.g., `MRS_BY_AUTHOR.md`, status files):

**What to update**:
- Header statistics (total counts)
- Remove closed/completed items
- Update counts per category/author
- Verify accuracy against source of truth files

**Always verify**:
```bash
# Example: Verify tracking doc matches data file
grep -c 'pattern' TRACKING_DOC.md
wc -l < data/source-of-truth.txt
# Should match
```

### Phase 3: Verify Consistency

**Critical**: After updates, verify all files are consistent.

#### 1. Extract and Compare Statistics

**Create verification script**:
```bash
#!/bin/bash
# verify_docs.sh

echo "=== Statistics Verification ==="
echo ""

# Extract from each file
echo "CLAUDE.md:"
grep -E "Open|Closed|Total|authors" CLAUDE.md | head -5

echo ""
echo "MEMORY.md:"
grep -E "Open MRs|Closed|authors" MEMORY.md | head -5

echo ""
echo "docs/REVIEW_PROCESS.md:"
grep -E "Open MRs|Review files" docs/REVIEW_PROCESS.md | grep -v "##"

echo ""
echo "=== Cross-Reference Check ==="
# Check specific values match
claude_open=$(grep "Open.*:" CLAUDE.md | head -1 | grep -oE "[0-9]+")
memory_open=$(grep "Open MRs" MEMORY.md | head -1 | grep -oE "[0-9]+")

if [ "$claude_open" = "$memory_open" ]; then
  echo "✓ Open count matches: $claude_open"
else
  echo "✗ MISMATCH: CLAUDE=$claude_open, MEMORY=$memory_open"
fi
```

Run and verify all numbers match.

#### 2. Check Last Updated Dates

All files should have current dates:
```bash
grep -n "Last updated" CLAUDE.md MEMORY.md docs/*.md
grep -n "Updated:" CLAUDE.md MEMORY.md docs/*.md
```

Update any stale dates.

#### 3. Verify File References

Check that file counts match reality:
```bash
# Example: Verify review file counts
echo "Documented: $(grep 'review files' MEMORY.md | grep -oE '[0-9]+' | head -1)"
echo "Actual: $(ls reviews/*.md | wc -l)"

echo "Documented reasoning: $(grep 'reasoning' MEMORY.md | grep -oE '[0-9]+' | head -1)"
echo "Actual: $(ls reviews/*_reasoning.txt 2>/dev/null | wc -l)"
```

#### 4. Check Cross-References

Verify references between files work:
```bash
# Check if referenced files exist
grep -oE 'docs/[A-Za-z_-]+\.md' CLAUDE.md MEMORY.md | while read ref; do
  if [ -f "$ref" ]; then
    echo "✓ $ref exists"
  else
    echo "✗ $ref MISSING"
  fi
done
```

### Phase 4: Quality Checks

#### 1. Formatting

Check line width if project has constraints:
```bash
# Example: 120 char limit
for file in CLAUDE.md MEMORY.md docs/*.md; do
  cnt=$(awk 'length > 120 {print NR": " substr($0,1,80)"..."}' "$file" | wc -l)
  if [ "$cnt" -gt 0 ]; then
    echo "$file: $cnt lines over 120 chars"
  fi
done
```

#### 2. Broken Links

Check markdown links:
```bash
# Extract markdown links
grep -oE '\[.*\]\(.*\)' CLAUDE.md MEMORY.md docs/*.md | \
  grep -oE '\(.*\)' | tr -d '()' | while read link; do
    # Check local file links
    if [[ ! "$link" =~ ^http ]]; then
      if [ ! -f "$link" ]; then
        echo "✗ Broken link: $link"
      fi
    fi
  done
```

#### 3. Consistency of Terminology

Ensure consistent naming:
- Same feature/phase names across docs
- Consistent file naming references
- Consistent metrics (e.g., "Open MRs" vs "Active MRs")

#### 4. Completeness

**CLAUDE.md checklist**:
- [ ] Repository purpose stated
- [ ] All phases summarized (with status)
- [ ] Core principles listed
- [ ] File organization overview
- [ ] Restrictions and best practices
- [ ] Key documentation pointers
- [ ] Last updated date
- [ ] Under 150 lines (distilled)

**MEMORY.md checklist**:
- [ ] Current status (all metrics current)
- [ ] Key files (with counts and descriptions)
- [ ] Complete workflows (self-contained)
- [ ] Recent work (dated)
- [ ] Statistics (current + historical)
- [ ] Last updated date

**docs/*.md checklist**:
- [ ] Detailed procedures (step-by-step)
- [ ] Examples with current data
- [ ] Commands and code blocks
- [ ] Quality checklists
- [ ] Last updated date

---

## Common Patterns

### Pattern 1: Project Milestone Reached

**Trigger**: Completed a major phase (e.g., code review phase done)

**Updates needed**:
1. Add phase to "Completed Work Summary" in CLAUDE.md
2. Update statistics in all files
3. Add workflow to MEMORY.md if new
4. Update "Recent Work" in MEMORY.md
5. Update dates everywhere

**Example**:
```markdown
# CLAUDE.md - Add to Completed Work Summary
### Phase 4: Code Review & Quality Assurance (COMPLETED)
- **Reviews**: 50 complete (.md) + 22 reasoning files (_reasoning.txt)
- **Quality**: Zero false positives, all commits reviewed, 120 char width
- **Key files**: `reviews/*.md`, `reviews/*_reasoning.txt`, `docs/REVIEW_PROCESS.md`
```

### Pattern 2: Statistics Changed

**Trigger**: MRs closed, branches merged, counts changed

**Updates needed**:
1. Update "Current Status" in MEMORY.md
2. Update phase summaries in CLAUDE.md
3. Update statistics in docs/*.md
4. Update tracking documents
5. Verify consistency across all files

**Workflow**:
```bash
# 1. Get current numbers
open_count=$(wc -l < data/open.txt)
closed_count=$(wc -l < data/closed.txt)
total=$((open_count + closed_count))

# 2. Update MEMORY.md Current Status
# 3. Update CLAUDE.md Phase summaries
# 4. Update docs/REVIEW_PROCESS.md header
# 5. Verify all match
```

### Pattern 3: New Workflow Established

**Trigger**: Discovered new process, established new standard

**Updates needed**:
1. Add complete workflow to MEMORY.md
2. Add principle to CLAUDE.md (if foundational)
3. Add detailed procedure to docs/*.md (if complex)
4. Add to "Recent Work" in MEMORY.md

**Example**: Learned "always verify bugs in actual code"
- Add to CLAUDE.md Core Principles: "Review Quality Standards"
- Add complete verification workflow to MEMORY.md
- Add detailed examples to docs/REVIEW_PROCESS.md

### Pattern 4: File Organization Changed

**Trigger**: New directory, new file types, restructuring

**Updates needed**:
1. Update "File Organization" in CLAUDE.md
2. Update "Key Files" in MEMORY.md
3. Update "Repository Structure" in docs/*.md
4. Update file counts everywhere

---

## Anti-Patterns to Avoid

**Don't duplicate detailed procedures**:
```
❌ CLAUDE.md contains step-by-step workflow (200 lines)
✓ CLAUDE.md references MEMORY.md, which has complete workflow
```

**Don't have stale statistics**:
```
❌ CLAUDE.md: "50 open MRs", MEMORY.md: "48 open MRs"
✓ All files: "48 open MRs" (consistent)
```

**Don't forget dates**:
```
❌ Last updated: 2026-03-27 (but today is 2026-04-10)
✓ Last updated: 2026-04-10
```

**Don't update only some files**:
```
❌ Updated MEMORY.md, forgot CLAUDE.md
✓ Updated all affected files, verified consistency
```

**Don't make CLAUDE.md too detailed**:
```
❌ CLAUDE.md: 300+ lines with examples and commands
✓ CLAUDE.md: ~120 lines with essentials only
```

**Don't leave broken references**:
```
❌ References `docs/WORKFLOW.md` which doesn't exist
✓ All referenced files exist and are current
```

---

## Verification Checklist

Before finalizing documentation updates:

**Consistency**:
- [ ] All statistics match across files
- [ ] Dates are current on all updated files
- [ ] File counts match reality
- [ ] Terminology is consistent

**Completeness**:
- [ ] All phases documented in CLAUDE.md
- [ ] Current state accurate in MEMORY.md
- [ ] Workflows complete in MEMORY.md
- [ ] Procedures detailed in docs/*.md

**Quality**:
- [ ] CLAUDE.md under 150 lines (distilled)
- [ ] No duplicated procedures across files
- [ ] All file references valid
- [ ] Formatting compliant (if applicable)

**Cross-references**:
- [ ] CLAUDE.md points to MEMORY.md for workflows
- [ ] MEMORY.md points to docs/*.md for details
- [ ] All referenced files exist

**Accuracy**:
- [ ] Numbers verified against source files
- [ ] Tracking docs match data files
- [ ] No outdated information

---

## Example Refresh Session

```bash
# 1. Identify changes
echo "What changed: MRs closed (50 → 48), reasoning files created (22)"

# 2. Update docs/*.md
# Updated docs/REVIEW_PROCESS.md:
# - Repository Structure (added reasoning files)
# - Added reasoning files section
# - Updated statistics (48 open MRs, 50+22 files)
# - Updated last updated date

# 3. Update MEMORY.md
# - Current Status (48 open, 15 closed)
# - Key Files (reasoning files documented)
# - Added complete Review Workflow section
# - Recent Work (added reasoning file creation)
# - Statistics (updated all numbers)
# - Last updated date

# 4. Update CLAUDE.md
# - Phase 4 summary (added reasoning files)
# - Phase 5 summary (updated counts)
# - File Organization (added reasoning files)
# - Restrictions (added reasoning file rules)
# - Last updated date
# - Trimmed from 228 → 123 lines

# 5. Verify consistency
./verify_docs.sh
# ✓ All statistics match
# ✓ All files have current dates
# ✓ File counts verified

# 6. Quality check
for file in CLAUDE.md MEMORY.md docs/*.md; do
  awk 'length > 120' "$file" | wc -l
done
# ✓ All compliant
```

---

## Quick Reference

**Documentation hierarchy**:
1. **CLAUDE.md**: Essentials only (~120 lines)
2. **MEMORY.md**: Complete reference (workflows + state)
3. **docs/*.md**: Detailed procedures (examples + commands)

**Update order**:
1. docs/*.md (detailed procedures)
2. MEMORY.md (complete reference)
3. CLAUDE.md (distilled essentials)
4. Tracking docs (if applicable)

**Essential commands**:
```bash
# Compare statistics
grep -E "Open|Closed|Total" CLAUDE.md MEMORY.md docs/*.md

# Check dates
grep "Last updated" CLAUDE.md MEMORY.md docs/*.md

# Verify file counts
ls reviews/*.md | wc -l  # Compare with documented counts

# Check consistency
./verify_docs.sh  # Custom verification script
```

**Key principles**:
1. Update specific → general (detailed docs first)
2. Verify consistency after updates
3. Keep CLAUDE.md concise (essentials only)
4. MEMORY.md is self-contained (complete workflows)
5. Update ALL affected files, not just some

---

## Integration with Other Skills

This skill complements:
- **Code review skills**: After review milestones, update docs
- **Project management**: After phase completion, refresh docs
- **Repository maintenance**: Regular doc refresh cycles

**When to combine**:
- After completing review phase → use review skill, then refresh-docs
- After major refactoring → update code, then refresh-docs
- Monthly maintenance → audit repository state, then refresh-docs

---

**Last updated**: 2026-04-10
