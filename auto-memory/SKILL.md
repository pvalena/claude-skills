---
name: Auto Memory
description: Create and maintain a project-level MEMORY.md working knowledge document for any repository
author: pvalena
version: 1.0.0
tags: [documentation, memory, project-knowledge, maintenance, garbage-collection, onboarding]
---

# Auto Memory Skill

**Purpose**: Guide the creation and ongoing maintenance of a project-level MEMORY.md file that captures working
knowledge -- current state, workflows, commands, and lessons learned -- for any repository, complementing the
project's CLAUDE.md instructions file.

## When to Use This Skill

- Starting work in a new repository that has no MEMORY.md
- Joining a project where accumulated knowledge is scattered across conversations
- MEMORY.md exists but is stale (dates older than 1 week, numbers don't match reality)
- MEMORY.md has grown past 500 lines and needs garbage collection
- Completing a major project phase and need to capture what was learned
- Want to establish the CLAUDE.md / MEMORY.md / docs/ documentation hierarchy
- Onboarding: need a quick-reference document for contributors

## Core Principles

### 1. Working Knowledge, Not Archive

MEMORY.md captures what you need to work in the repo right now. It is not a changelog, not a historical record,
not meeting notes. The test: "Will this information help someone work in this repository in the future?" If
the answer is no, it does not belong.

### 2. Complementary to CLAUDE.md

CLAUDE.md holds bare essentials (project purpose, principles, file organization, restrictions). MEMORY.md holds
working knowledge (current state, workflows, commands, lessons). They do not duplicate each other. If information
is in CLAUDE.md, reference it from MEMORY.md rather than repeating it.

### 3. Self-Contained Workflows

Each workflow section in MEMORY.md should be complete enough to follow without reading other files. Include actual
commands with real arguments, not placeholders. A reader should be able to execute the workflow by reading that
one section.

### 4. Concrete Over Abstract

Prefer real examples with lessons learned over general advice. Prefer actual commands over descriptions of what
commands to run. Prefer specific file paths over "the relevant file."

### 5. Size Discipline

Target 250-350 lines. Trigger garbage collection at 500 lines. MEMORY.md that grows without bound becomes noise,
not knowledge.

---

## Documentation Hierarchy

The three-tier documentation pattern separates concerns by scope and detail level.

### The Three Tiers

**CLAUDE.md** (~100-150 lines): Repository instructions.
- Project purpose, completed work summary, core principles, file organization, restrictions
- Read automatically by Claude Code on every conversation
- Contains NO procedures, NO commands, NO current metrics that change frequently

**MEMORY.md** (~250-350 lines): Working knowledge.
- Current status, quick file reference, workflows with commands, important cases with lessons, quick reference
- Not read automatically -- invoked when needed or referenced by CLAUDE.md
- Contains NO project overview (that belongs in CLAUDE.md)

**docs/*.md** (~300-500 lines each): Detailed procedures.
- Step-by-step processes, extensive examples, reference material
- For complex workflows that would bloat MEMORY.md

### Information Flow Rules

- Facts live in one place (single source of truth)
- CLAUDE.md points to MEMORY.md for workflows: `See MEMORY.md for complete workflow reference`
- MEMORY.md points to docs/*.md for details: `See docs/DEPLOY.md for detailed deployment procedures`
- Update order: docs/*.md first, then MEMORY.md, then CLAUDE.md (specific to general)

### When to Create docs/*.md

- A workflow section in MEMORY.md exceeds ~80 lines
- Procedure has extensive examples or reference tables
- Multiple distinct sub-procedures that would fragment MEMORY.md

---

## Complete Workflow

### Phase 1: Assess the Project

**Goal**: Understand the repository before creating MEMORY.md.

#### 1. Survey the Repository

```bash
# Structure
ls -la
find . -maxdepth 2 -name "*.md" | head -20

# Size and activity
wc -l CLAUDE.md README.md 2>/dev/null
git log --oneline -20
git log --all --oneline | wc -l

# Project type indicators
ls src/ lib/ tests/ docs/ 2>/dev/null
```

#### 2. Read Existing Documentation

Check CLAUDE.md, README.md, any docs/ files. Note what is already documented and what gaps exist.

#### 3. Identify Project Type

- **Application**: has src/, build configs, deployment files
- **Library**: has lib/, package.json/setup.py, published API
- **Infrastructure**: has terraform/, ansible/, docker-compose
- **Analysis/Research**: has data/, notebooks/, scripts
- **Monorepo**: has packages/ or workspaces, multiple package.json

#### 4. Determine Undocumented Knowledge

What commands are used repeatedly? What workflows exist but are not written down? What gotchas have been
discovered? What files are most important but not obvious?

#### 5. Check for Existing MEMORY.md

If MEMORY.md exists, skip to Phase 4 (Maintain and Update) or Phase 5 (Garbage Collection).

**Output**: Mental model of what sections MEMORY.md needs, tailored to this project.

---

### Phase 2: Create MEMORY.md

**Goal**: Write the initial MEMORY.md from scratch using real data from the repository.

#### 1. Start with the Header

```markdown
# Repository Memory - Current State

**Last updated**: YYYY-MM-DD

Quick reference for working in this repository. See `CLAUDE.md` for repository overview.

---
```

#### 2. Fill Current Status

Gather real numbers from the repository. Do not estimate or use placeholders.

```bash
# Examples of gathering real metrics
git log --oneline | wc -l                    # Total commits
ls src/**/*.ts 2>/dev/null | wc -l           # Source files
find tests/ -name "*.test.*" | wc -l         # Test files
git branch -r | wc -l                        # Remote branches
```

#### 3. Build Quick File Reference

Identify the 8-15 most important files. Group by purpose. Include current counts where relevant.

#### 4. Document Workflows

Capture 1-3 key workflows performed regularly. Each workflow must include actual commands with real flags and
arguments. Include expected output where helpful. Do NOT write "run the appropriate command" -- write the actual
command.

#### 5. Add Important Cases / Lessons Learned

Any gotchas, mistakes made, or non-obvious facts about the project. Format as: what happened, what the lesson
was. Skip this section if starting fresh with no accumulated knowledge.

#### 6. Add Quick Reference

Essential commands used daily, grouped by category. One-liner format with brief comments.

#### 7. Set the Date

Update "Last updated" to today's date. For statistics sections, include the date so staleness is visible.

**Output**: Complete MEMORY.md file, under 350 lines, with real data.

---

### Phase 3: Align with CLAUDE.md

**Goal**: Ensure MEMORY.md and CLAUDE.md complement each other without duplication.

#### 1. If CLAUDE.md Exists

Review it for overlap. Move any workflows or commands from CLAUDE.md to MEMORY.md. Add cross-references in both
directions.

```markdown
# In CLAUDE.md (pointing to MEMORY.md):
- **MEMORY.md**: Complete workflow reference and repository state

# In MEMORY.md (pointing back):
See `CLAUDE.md` for repository overview and core principles.
```

#### 2. If CLAUDE.md Does Not Exist

Consider creating one with bare essentials: project purpose, core principles, file organization, restrictions.
Point to MEMORY.md for workflows. Keep it under 150 lines.

#### 3. Verify the Hierarchy

- CLAUDE.md has no procedures or commands
- MEMORY.md has no project overview or purpose statement
- Each fact appears in exactly one file
- Cross-references are in place

**Output**: Both files aligned with clear separation of concerns.

---

### Phase 4: Maintain and Update

**Goal**: Keep MEMORY.md current as the project evolves.

#### Triggers for Update

- Statistics changed (new files, tests added, versions bumped)
- New workflow established or existing one changed
- Important lesson learned (real bug found, gotcha discovered)
- Phase or milestone completed
- Date in MEMORY.md is more than 1 week old

#### Update Process

1. Check what changed since last update
2. Update affected sections (not just one -- if a metric changed, update both the Status and Statistics sections)
3. Update "Last updated" date
4. Verify numbers match reality (cross-check with actual file counts, git output)
5. Check file size -- if approaching 500 lines, trigger garbage collection (Phase 5)

#### Staleness Detection

```bash
# Check MEMORY.md freshness
grep "Last updated" MEMORY.md
wc -l MEMORY.md
```

If "Last updated" is more than 1 week old, the file is stale and should be refreshed. If more than 2 weeks old,
treat it as unreliable -- verify every number before citing it.

**Output**: Updated MEMORY.md with current data and today's date.

---

### Phase 5: Garbage Collection

**Goal**: Trim MEMORY.md back to 250-350 lines when it exceeds 500.

#### The Evaluation Question

For every section: "Will this information help someone work in this repository in the future?"

#### Keep

- Current state and statistics (not historical)
- Active workflows with commands
- Essential quick reference commands
- Real examples with lessons that prevent future mistakes
- File references for key files

#### Remove

- Historical data not needed for current workflow (old statistics, completed milestones)
- Information that duplicates CLAUDE.md
- Verbose explanations that can be condensed to one line
- Lists of completed or closed items
- "Recent work" entries older than 1-2 cycles
- Redundant descriptions (same concept explained multiple ways)

#### Process

1. Count current lines: `wc -l MEMORY.md`
2. Identify each section's line count
3. Score each section: essential (keep as-is), condensable (keep but shorten), removable (delete)
4. Remove/condense targeting 250-350 lines
5. Verify the document still works standalone after removal
6. Check for broken cross-references
7. Document the reduction in the commit message

**Output**: MEMORY.md trimmed to target size with no loss of working knowledge.

---

## MEMORY.md Template

Generic template adaptable to any project type. Replace bracketed text with real content.

```markdown
# Repository Memory - Current State

**Last updated**: YYYY-MM-DD

Quick reference for working in this repository. See `CLAUDE.md` for repository overview.

---

## Current Status

- **[Primary metric]**: [value]
- **[Secondary metric]**: [value]
- **[Tertiary metric]**: [value]

---

## Quick File Reference

**[Category 1]** (e.g., Source, Config, Data):
- `path/to/key-file` - Brief description ([count] if relevant)
- `path/to/another` - Brief description

**[Category 2]** (e.g., Tests, Documentation):
- `path/to/file` - Brief description

**Documentation**:
- `CLAUDE.md` - Repository instructions and essentials
- `MEMORY.md` - This file - workflows and current state

---

## [Primary Workflow]

Complete process for [most common task].

### Step 1: [Action]

```bash
actual-command --with-real-flags
```

### Step 2: [Action]

[Commands and expected output]

**Checklist**:
- [ ] [Verification step 1]
- [ ] [Verification step 2]

---

## [Secondary Workflow] (if applicable)

[Complete workflow with commands]

---

## Important Cases / Lessons Learned

### [Case Name]
**What happened**: [Brief description]
**Lesson**: [What to do differently / what to remember]

---

## Quick Reference

**Essential commands**:
```bash
# [Category]
command-1  # What it does
command-2  # What it does
```

**Key principles**:
1. [Principle with brief explanation]
2. [Principle with brief explanation]

---

## Statistics

**Current (YYYY-MM-DD)**:
- [Metric]: [Value]
- [Metric]: [Value]
```

### Adaptation by Project Type

- **Application**: Current Status = version, environment, deployment state. Workflows = build, deploy, debug.
- **Library**: Current Status = version, test coverage, API surface. Workflows = test, publish, API changes.
- **Infrastructure**: Current Status = environment counts, resource state. Workflows = provision, update, rollback.
- **Analysis/Research**: Current Status = data metrics, processing state. Workflows = data pipeline, analysis.
- **Monorepo**: Quick File Reference is especially important. May need per-package workflow sections.

---

## Red Flags

**Signs MEMORY.md is unhealthy:**
- Over 500 lines -- needs garbage collection
- "Last updated" date is more than 2 weeks old -- stale and unreliable
- Contains project overview that belongs in CLAUDE.md -- wrong tier
- Workflows use placeholder commands instead of real ones -- not actionable
- Contains historical records (changelogs, lists of completed items) -- archive, not memory
- Same information appears in both CLAUDE.md and MEMORY.md -- duplication
- No actual commands or code blocks -- too abstract to be useful
- Contains information only useful in one session -- belongs in a context dump, not MEMORY.md

**Signs you do NOT need MEMORY.md:**
- Project has fewer than 5 files and one obvious workflow
- CLAUDE.md already covers everything needed (under 150 lines total)
- Project is a one-off script or experiment
- No recurring workflows exist

---

## Best Practices

1. **Write from experience, not speculation**: Wait until you have actually worked in the repo and discovered
   workflows and gotchas. Do not create a speculative MEMORY.md on day one.

2. **Update incrementally**: Add one section or update one set of numbers at a time. Do not rewrite the entire
   file each cycle.

3. **Real examples over templates**: When documenting a lesson, use the actual case that taught you. Include file
   paths, line numbers, real data.

4. **Test the cold start**: Could someone with access to the repo and CLAUDE.md + MEMORY.md start working
   effectively without asking questions? If not, MEMORY.md is missing something.

5. **Garbage collect proactively**: Do not wait for 500 lines. If you notice a section that no longer reflects
   reality, update or remove it immediately.

6. **Cross-reference, do not duplicate**: If CLAUDE.md says "base commit is X," do not repeat it in MEMORY.md.
   Reference it: "See CLAUDE.md for base commit."

7. **Date everything**: Always update "Last updated." For statistics, include the date in the section so
   staleness is visible at a glance.

---

## Checklist

### Creating MEMORY.md
- [ ] Surveyed repository structure and existing documentation
- [ ] Current Status section uses real numbers from the repository
- [ ] Quick File Reference covers the 8-15 most important files
- [ ] At least one workflow section with complete, runnable commands
- [ ] No overlap with CLAUDE.md content
- [ ] Cross-references to CLAUDE.md and docs/*.md where appropriate
- [ ] "Last updated" date set
- [ ] File is under 350 lines

### Maintaining MEMORY.md
- [ ] Statistics match reality (cross-checked with actual counts)
- [ ] Workflows reflect current process (commands still work)
- [ ] "Last updated" date is current
- [ ] No sections are stale or obsolete
- [ ] File size checked (under 500 lines)

### Garbage Collection
- [ ] Applied "Will this help someone work here in the future?" test to each section
- [ ] Removed historical data not needed for workflow
- [ ] Condensed verbose explanations
- [ ] Removed duplication with CLAUDE.md
- [ ] File reduced to 250-350 line target
- [ ] Document still works standalone after removal
- [ ] No broken cross-references

---

## Version History

- **1.0.0** (2026-04-30): Initial version based on GRUB2 review project MEMORY.md patterns and documentation
  hierarchy experience

---

## See Also

- **refresh-docs** - For coordinated updates across CLAUDE.md, MEMORY.md, and docs/*.md
- **memory-dump** - For session-specific context dumps (model transitions, session restoration)
- **create-skill** - For capturing reusable workflows as global skills
---

**Remember**: MEMORY.md is working memory, not permanent storage. If you would not look at the information next
week, it does not belong here.
