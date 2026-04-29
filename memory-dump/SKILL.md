---
name: Memory Dump
description: Create comprehensive context dumps for model transitions and session restoration
author: pvalena
version: 1.2.0
tags: [meta, context, session-management, model-transition, restoration, continuity]
---

# Memory Dump Skill

**Purpose**: Create exhaustive context dumps that enable seamless continuation of work when switching Claude models, resuming after context limits, or preserving session state for future reference.

## When to Use This Skill

Use this skill when:
- Approaching context window limits (token budget running low)
- Switching to a newer/different Claude model version
- Taking extended breaks from complex multi-session work
- Need to preserve detailed session state for future reference
- Creating handoff documentation for collaborative work

## Core Principles

**Exhaustiveness over brevity**: Include everything that might be relevant. Future you (or future model) doesn't know what will be important.

**Machine-optimized format**: Structure for LLM consumption, not human readability. Dense, factual, well-organized markdown. Do not wrap lines for terminal width -- long lines are fine. Prioritize semantic completeness per line over visual formatting.

**State snapshots**: Capture exact state of files, git repos, pending work, not just summaries.

**Actionable restoration**: Dump should enable immediate continuation without asking questions.

**Timestamp everything**: Dates, sequences, and timelines matter for understanding context evolution.

## Complete Workflow

### Phase 1: Determine Scope

**Goal**: Decide what needs to be captured.

Assess session complexity:
- How many files were modified? How many distinct workflows were performed?
- Are there pending/incomplete tasks? Is there complex state that's hard to recreate?

**Simple session** (< 5 file changes, single workflow): Lightweight dump -- header, session summary, files modified, next steps, restoration instructions only.

**Complex session** (multiple workflows, many files, ongoing work): Full dump using all phases below.

Identify what must be captured:
- Modified files and their current state
- Git repository states (branch, commits, untracked files)
- Pending tasks and known issues
- Workflow patterns established
- Key decisions made and their rationale
- Command patterns, user preferences, domain knowledge, quality standards, error patterns (if applicable)

### Phase 2: Structure the Dump

**Goal**: Create the dump file with header metadata.

Choose file location:
- **Project-specific**: project root or docs/ (e.g., `DUMP_MEMORY.md`)
- **Global**: `~/.claude/` or `~/.claude/session_dumps/YYYY-MM-DD.md`

Write the header:

```markdown
# CONTEXT DUMP FOR [PURPOSE]
**Generated**: YYYY-MM-DD HH:MM
**Session Type**: [New/Continuation/Handoff]
**Working Directory**: /full/path/to/directory

## SESSION SUMMARY

### Primary Work Completed This Session
1. Task 1
2. Task 2

### Previous Session Context (if continuation)
[Brief summary of what led here]
```

### Phase 3: Capture Core State

**Goal**: Document current repository and session state comprehensively.

#### Repository State

For each git repository involved, gather and record:

```bash
pwd && git status && git log --oneline -5 && git branch --show-current
```

```markdown
## REPOSITORY STATE

### Project Purpose
[One paragraph describing what this repository is for]

### Current Statistics
- Key metric 1: value

### File Structure
[Tree with purpose annotations for key files]

### Git Status
Branch: branch-name
Status: [ahead/behind/clean]
Recent commits: (last 5)
Untracked/Modified files: [list]
```

#### Session Work Details

For each major task or file modified:

```markdown
## DETAILED WORK THIS SESSION

### 1. [Task/Feature Name]
**File**: /path/to/file.ext
**Changes made**: [list with line numbers]
**Issues fixed**: [description, what was wrong, how fixed]
**Code snippets** (for critical changes): [before/after]
**Rationale**: Why these changes were made
```

#### Workflow Patterns

Document any established patterns with steps and example commands.

### Phase 4: Capture Knowledge

**Goal**: Preserve learned information, decisions, and preferences.

Document these if applicable:
- **Principles & constraints**: Domain-specific rules, quality standards, constraints with rationale
- **Learned lessons**: For each significant lesson: problem, root cause, solution, prevention
- **User preferences**: Communication style, workflow preferences, quality standards observed
- **Command patterns**: Common operations with project-specific commands
- **Key statistics**: Metrics with context on why they matter

### Phase 5: Document Pending State and Finalize

**Goal**: Enable immediate continuation and close out the dump.

#### Pending/Known Issues

```markdown
## PENDING/KNOWN ISSUES

1. **Issue name**: Description
   - Status: [Not started/In progress/Blocked]
   - Action needed: What should be done
```

#### Session Ending State

```markdown
## SESSION ENDING STATE

### Tasks Completed
- Task 1

### Tasks In Progress
- Task 3 (50% complete - waiting for X)

### Next Logical Steps (Not Started)
1. Step 1 (priority: high)
2. Step 2 (priority: medium)
```

#### Context Restoration Instructions

```markdown
## CONTEXT RESTORATION INSTRUCTIONS

When loading this dump:
1. Working directory is `/path/to/directory`
2. Check [file/command] for current state
3. Key constraint: [important thing to remember]
4. Next action: [what to do first]

**Quick verification:**
[command to verify state]
Expected output: [what should be seen]
```

#### Timestamp Trail and End Marker

```markdown
## TIMESTAMP TRAIL
- Previous session: ~YYYY-MM-DD
- This session: YYYY-MM-DD
- Dump created: YYYY-MM-DD HH:MM

## END OF CONTEXT DUMP
**Comprehensiveness**: [Minimal/Moderate/Exhaustive]
**Restoration confidence**: [Low/Medium/High]
```

## Quality Guidelines

**Do**:
- Create dumps proactively, before hitting context limits
- Use actual data: real file paths, commands, outputs -- never placeholders when real data is available
- Capture rationale (why decisions were made, not just what)
- Include failure paths (what didn't work and why)
- Make dumps standalone -- no "as mentioned before" references
- Test: could a fresh model pick up exactly where you left off with zero questions?

**Don't**:
- Write "Fixed bug" without details, or "Various changes were made"
- Use placeholders when you have real data
- Leave git status without showing actual changes
- Omit timestamps or restoration instructions
- Reference files/concepts without explanation

## Version History

- **1.0.0** (2026-04-13): Initial version based on model transition dump creation
- **1.1.0** (2026-04-21): Trimmed from 1008 to ~500 lines; removed duplicate templates, redundant markdown formatting guidelines, and repeated examples
- **1.2.0** (2026-04-22): Optimized for LLM-readability and token efficiency. Removed duplicate template section, redundant checklist (duplicated workflow), restoration workflow (duplicated Phase 5), and merged red flags with best practices. Removed artificial line-width wrapping. ~414 to ~160 lines.
