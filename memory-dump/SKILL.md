---
name: Memory Dump
description: Create comprehensive context dumps for model transitions and session restoration
author: pvalena
version: 1.1.0
tags: [meta, context, session-management, model-transition, restoration, continuity]
---

# Memory Dump Skill

**Purpose**: Create exhaustive context dumps that enable seamless continuation of work when switching
Claude models, resuming after context limits, or preserving session state for future reference.

## When to Use This Skill

Use this skill when:
- Approaching context window limits (token budget running low)
- Switching to a newer/different Claude model version
- Taking extended breaks from complex multi-session work
- Need to preserve detailed session state for future reference
- Creating handoff documentation for collaborative work

## Core Principles

**Exhaustiveness over brevity**: Include everything that might be relevant. Future you (or future model)
doesn't know what will be important.

**Machine-optimized format**: Structure for LLM consumption, not human readability. Dense, factual,
well-organized markdown works best.

**State snapshots**: Capture exact state of files, git repos, pending work, not just summaries.

**Actionable restoration**: Dump should enable immediate continuation without asking questions.

**Timestamp everything**: Dates, sequences, and timelines matter for understanding context evolution.

## Complete Workflow

### Phase 1: Determine Scope

**Goal**: Decide what needs to be captured

#### 1. Assess Session Complexity

Questions to ask:
- How many files were modified this session?
- How many distinct workflows were performed?
- Are there pending/incomplete tasks?
- Is there complex state that's hard to recreate?
- Will this work continue in future sessions?

**Simple session** (< 5 file changes, single workflow): Lightweight dump focusing on changes and next steps.

**Complex session** (multiple workflows, many files, ongoing work): Comprehensive dump with full state
capture.

#### 2. Identify Critical Elements

Must capture:
- Modified files and their current state
- Git repository states (branch, commits, untracked files)
- Pending tasks and known issues
- Workflow patterns established
- Key decisions made and their rationale

Should capture if applicable:
- Command patterns and aliases used
- User preferences observed
- Domain-specific knowledge acquired
- Quality standards and constraints
- Error patterns and solutions

### Phase 2: Structure the Dump

**Goal**: Create organized framework for information

#### 1. Choose File Location

- **Project-specific dumps**: In project root or docs/ (e.g., `DUMP_MEMORY.md`)
- **Global dumps**: In `~/.claude/` or temp directory (e.g., `~/.claude/session_dumps/YYYY-MM-DD.md`)

#### 2. Create Header

```markdown
# CONTEXT DUMP FOR [PURPOSE]
**Generated**: YYYY-MM-DD HH:MM
**Session Type**: [New/Continuation/Handoff]
**Working Directory**: /full/path/to/directory

---

## SESSION SUMMARY

### Primary Work Completed This Session
1. Task 1
2. Task 2

### Previous Session Context (if continuation)
[Brief summary of what led here]
```

### Phase 3: Capture Core State

**Goal**: Document current state comprehensively

#### 1. Repository State

For each git repository involved, capture:

```markdown
## REPOSITORY STATE

### Project Purpose
[One paragraph describing what this repository is for]

### Current Statistics
- Key metric 1: value
- Key metric 2: value

### File Structure
[Tree with purpose annotations for key files]

### Git Status
Branch: branch-name
Status: [ahead/behind/clean]
Recent commits: (last 5)
Untracked/Modified files: [list]
```

**Commands to gather this:**
```bash
pwd && git status && git log --oneline -5 && git branch --show-current
```

#### 2. Session Work Details

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

#### 3. Workflow Patterns

Document any established patterns with steps and example commands.

### Phase 4: Capture Knowledge

**Goal**: Preserve learned information and decisions

#### 1. Core Principles & Constraints

Document domain-specific rules, quality standards, and constraints with rationale.

#### 2. Important Learned Lessons

For each significant lesson:
- **Problem**: What went wrong
- **Cause**: Root cause identified
- **Solution**: How it was fixed
- **Prevention**: How to avoid in future

#### 3. User Preferences & Patterns

Document communication style, workflow preferences, and quality standards observed.

### Phase 5: Document Pending State

**Goal**: Enable immediate continuation

#### 1. Pending/Known Issues

```markdown
## PENDING/KNOWN ISSUES

1. **Issue name**: Description
   - Status: [Not started/In progress/Blocked]
   - Action needed: What should be done
```

#### 2. Session Ending State

```markdown
## SESSION ENDING STATE

### Tasks Completed
- Task 1
- Task 2

### Tasks In Progress
- Task 3 (50% complete - waiting for X)

### Next Logical Steps (Not Started)
1. Step 1 (priority: high)
2. Step 2 (priority: medium)
```

#### 3. Context Restoration Instructions

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

### Phase 6: Add Supporting Information

**Goal**: Include reference material

Include as applicable:
- **Command patterns**: Common operations with project-specific commands
- **File formats**: Templates or structured format specs used in the project
- **Key statistics**: Metrics with context on why they matter

### Phase 7: Finalize and Save

**Goal**: Complete and verify dump

#### 1. Add Timestamp Trail

```markdown
## TIMESTAMP TRAIL
- Previous session: ~YYYY-MM-DD
- This session: YYYY-MM-DD
- Dump created: YYYY-MM-DD HH:MM
```

#### 2. Add End Marker

```markdown
## END OF CONTEXT DUMP
**Total sections**: X
**Comprehensiveness**: [Minimal/Moderate/Exhaustive]
**Restoration confidence**: [Low/Medium/High]
```

#### 3. Verify Completeness

Run through the checklist below before saving.

## Dump Structure Template

```markdown
# CONTEXT DUMP FOR [PURPOSE]
**Generated**: YYYY-MM-DD HH:MM
**Session Type**: [Type]
**Working Directory**: /full/path

---

## SESSION SUMMARY
### Primary Work Completed
### Previous Session Context (if continuation)

---

## REPOSITORY STATE
### Project Purpose
### Current Statistics
### File Structure
### Git Status

---

## DETAILED WORK THIS SESSION
### 1. [Task Name]
**File**: path | **Changes**: list | **Rationale**: why

---

## WORKFLOW PATTERNS ESTABLISHED

---

## CORE PRINCIPLES & CONSTRAINTS

---

## IMPORTANT LEARNED LESSONS

---

## USER PREFERENCES & PATTERNS

---

## PENDING/KNOWN ISSUES

---

## SESSION ENDING STATE
### Tasks Completed | ### Next Logical Steps

---

## CONTEXT RESTORATION INSTRUCTIONS

---

## COMMAND PATTERNS & ALIASES

---

## KEY STATISTICS & METRICS

---

## TIMESTAMP TRAIL

---

## END OF CONTEXT DUMP
**Comprehensiveness**: Exhaustive
**Restoration confidence**: High
```

**For simple sessions**, use only: Header, Session Summary, Files Modified, Next Steps, Restoration.

## Restoration Workflow

When loading a dump:

1. **Read header** - Understand context and date
2. **Check session summary** - Get high-level overview
3. **Navigate to directory** - Set working directory
4. **Verify state** - Run commands from restoration instructions
5. **Review pending items** - Understand what's next
6. **Check constraints** - Note important principles/standards
7. **Execute next steps** - Continue work

## Checklist

Use this checklist when creating a memory dump:

### Core
- [ ] Header with metadata (date, directory, session type)
- [ ] Session summary included
- [ ] Repository state documented (git status, branch, commits)
- [ ] All modified files listed with changes and rationale
- [ ] Pending issues listed with status
- [ ] Next steps identified and prioritized
- [ ] Restoration instructions clear and actionable

### Knowledge Capture
- [ ] Workflows and patterns captured
- [ ] Principles and constraints documented
- [ ] Learned lessons recorded
- [ ] User preferences noted

### Supporting
- [ ] Command patterns included (if complex commands used)
- [ ] File formats documented (if structured formats involved)
- [ ] Statistics listed (if metrics tracked)
- [ ] Timestamps included
- [ ] End marker present

## Red Flags

**Avoid these common mistakes:**

- **Too brief** - "Fixed bug" without details
- **Too abstract** - Generic placeholders instead of real data
- **Missing context** - Changes without rationale
- **Incomplete state** - Git status without showing actual changes
- **No restoration path** - Unclear how to continue
- **Missing timestamps** - Can't understand timeline
- **Orphaned references** - Mentions files/concepts without explanation

**Warning signs:**
- "Various changes were made" - Be specific
- "The usual workflow" - Document it explicitly
- "As mentioned before" - Dumps are standalone
- Using placeholders when you have real data

## Best Practices

1. **Create dumps proactively** - Don't wait until you hit context limits
2. **Be exhaustive** - Include more rather than less
3. **Use actual data** - Real file paths, commands, outputs
4. **Capture rationale** - Why decisions were made, not just what
5. **Include failure paths** - What didn't work and why
6. **Test restoration** - Can you understand it cold?

## Version History

- **1.0.0** (2026-04-13): Initial version based on model transition dump creation
- **1.1.0** (2026-04-21): Trimmed from 1008 to ~500 lines; removed duplicate templates, redundant
  markdown formatting guidelines, and repeated examples

## See Also

- **create-skill** - Framework for creating skills (meta-skill pattern)
- **refresh-docs** - Documentation maintenance workflows

---

**Remember**: The best dump is one that lets you (or another model) pick up exactly where you left off,
with zero questions needed. When in doubt, include it.
