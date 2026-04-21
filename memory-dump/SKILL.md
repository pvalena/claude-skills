---
name: Memory Dump
description: Create comprehensive context dumps for model transitions and session restoration
author: pvalena
version: 1.0.0
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
- Archiving completed work with full context

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

**Simple session** (< 5 file changes, single workflow):
- Lightweight dump focusing on changes and next steps

**Complex session** (multiple workflows, many files, ongoing work):
- Comprehensive dump with full state capture

**Output**: Decision on dump comprehensiveness level

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

**Output**: Checklist of sections needed

### Phase 2: Structure the Dump

**Goal**: Create organized framework for information

#### 1. Choose File Location

**Recommendations:**
- **Project-specific dumps**: In project root or docs/ directory
  - Example: `DUMP_MEMORY.md`, `SESSION_STATE.md`
  - Best for: Ongoing project work, team handoffs

- **Global dumps**: In `~/.claude/` or temp directory
  - Example: `~/.claude/session_dumps/YYYY-MM-DD.md`
  - Best for: Cross-project state, model transitions

**Output**: Decided file path

#### 2. Create Dump Header

```markdown
# CONTEXT DUMP FOR [PURPOSE]
**Generated**: YYYY-MM-DD HH:MM
**Session Type**: [New/Continuation/Handoff]
**Working Directory**: /full/path/to/directory
**Additional Directories**: [If any]

---

## SESSION SUMMARY

### Primary Work Completed This Session
1. Task 1
2. Task 2
3. Task 3

### Previous Session Context (if continuation)
[Brief summary of what led here]
```

**Output**: Structured header with metadata

### Phase 3: Capture Core State

**Goal**: Document current state comprehensively

#### 1. Repository State

For each git repository involved:

```markdown
## REPOSITORY STATE

### Project Purpose
[One paragraph describing what this repository is for]

### Current Statistics
- Key metric 1: value
- Key metric 2: value
- Key metric 3: value

### File Structure
```
/project/root/
├── file1.ext          (purpose/description)
├── directory/
│   ├── file2.ext      (purpose/description)
│   └── file3.ext      (purpose/description)
└── important/
    └── file4.ext      (purpose/description)
```

### Git Status
```
Branch: branch-name
Status: [ahead/behind/clean]
Recent commits: (last 5)
hash1 commit message
hash2 commit message

Untracked files:
- file1
- file2

Modified files:
- file3
- file4
```
```

**Commands to gather this:**
```bash
pwd
git status
git log --oneline -5
git branch --show-current
git status --porcelain
```

#### 2. Session Work Details

For each major task or file modified:

```markdown
## DETAILED WORK THIS SESSION

### 1. [Task/Feature Name]

**File**: /path/to/file.ext

**Changes made**:
- Change 1 (line X)
- Change 2 (lines Y-Z)
- Change 3 (section W)

**Issues fixed** (if applicable):
- Bug 1: [description, what was wrong, how fixed]
- Bug 2: [description, what was wrong, how fixed]

**Code snippets** (for critical changes):
```language
# Before:
old code

# After:
new code
```

**Rationale**: Why these changes were made
```

**Output**: Complete change log with context

#### 3. Workflow Patterns

Document established patterns:

```markdown
## WORKFLOW PATTERNS ESTABLISHED

### [Workflow Name]
1. Step 1
2. Step 2
3. Step 3

**Example:**
```bash
command1
command2
```

**Output**: Expected result
```

### Phase 4: Capture Knowledge

**Goal**: Preserve learned information and decisions

#### 1. Core Principles & Constraints

```markdown
## CORE PRINCIPLES & CONSTRAINTS

### [Domain/Area]
- **Principle name**: Description and rationale
- **Constraint name**: What it is and why it matters
- **Standard name**: What must be followed

### Examples
- **Zero false positives**: Every bug must be verified (why: credibility)
- **120 char width**: All docs must be <120 chars (why: readability standard)
```

#### 2. Important Learned Lessons

```markdown
## IMPORTANT LEARNED LESSONS

### From [Task/Feature]
1. **Lesson title** - What was learned, why it matters
2. **Mistake avoided** - What could have gone wrong, how prevented
3. **Best practice discovered** - What works well, when to use

### From [Debugging/Problem-Solving]
1. **Problem**: What went wrong
   **Cause**: Root cause identified
   **Solution**: How it was fixed
   **Prevention**: How to avoid in future
```

#### 3. User Preferences & Patterns

```markdown
## USER PREFERENCES & PATTERNS

### Communication Style
- Preference 1
- Preference 2

### Workflow Preferences
- How user likes to work
- What user values

### Quality Standards
- What user considers important
- What user rejects
```

### Phase 5: Document Pending State

**Goal**: Enable immediate continuation

#### 1. Pending/Known Issues

```markdown
## PENDING/KNOWN ISSUES

### Category 1
1. **Issue name**: Description
   - Status: [Not started/In progress/Blocked]
   - Context: Why this is an issue
   - Action needed: What should be done

### Category 2
[Continue pattern...]
```

#### 2. Next Logical Steps

```markdown
## SESSION ENDING STATE

### Current State
- Element 1: state
- Element 2: state

### Tasks Completed
- ✓ Task 1
- ✓ Task 2

### Tasks In Progress
- ⧗ Task 3 (50% complete - waiting for X)
- ⧗ Task 4 (just started)

### Next Logical Steps (Not Started)
1. Step 1 (priority: high)
2. Step 2 (priority: medium)
3. Step 3 (priority: low)
```

#### 3. Context Restoration Instructions

```markdown
## CONTEXT RESTORATION INSTRUCTIONS

When loading this dump:
1. Working directory is `/path/to/directory`
2. Check [file/command] for current state
3. Key constraint: [important thing to remember]
4. User values: [important preference]
5. Next action: [what to do first]

**Quick verification:**
```bash
command to verify state
```
Expected output: [what should be seen]
```

### Phase 6: Add Supporting Information

**Goal**: Include reference material

#### 1. Command Patterns & Aliases

```markdown
## COMMAND PATTERNS & ALIASES

### Common Operations
```bash
# Task 1
command pattern

# Task 2
command pattern
```

### Project-Specific Commands
```bash
# Special operation
command with explanation
```
```

#### 2. File Formats & Templates

If work involves structured formats:

```markdown
## FILE FORMATS

### Format Name
```format
template or example
```

**Requirements:**
- Requirement 1
- Requirement 2
```

#### 3. Key Statistics & Metrics

```markdown
## KEY STATISTICS & METRICS

### Category 1
- Metric name: value (context: why it matters)
- Metric name: value (context: why it matters)

### Historical Comparison (if applicable)
- Metric: before → after
- Metric: before → after
```

### Phase 7: Finalize and Save

**Goal**: Complete and verify dump

#### 1. Add Timestamp Trail

```markdown
## TIMESTAMP TRAIL

- Session start: ~YYYY-MM-DD (approximate or from logs)
- Key event 1: YYYY-MM-DD HH:MM
- Key event 2: YYYY-MM-DD HH:MM
- Dump created: YYYY-MM-DD HH:MM
```

#### 2. Add End Marker

```markdown
---

## END OF CONTEXT DUMP

**Total sections**: X
**Estimated token count**: ~X-Y tokens
**Comprehensiveness**: [Minimal/Moderate/Exhaustive]
**Format**: Markdown with embedded code blocks
**Restoration confidence**: [Low/Medium/High]
```

#### 3. Verify Completeness

Checklist:
- [ ] Header with metadata complete
- [ ] Session summary included
- [ ] Repository state documented
- [ ] All modified files listed with changes
- [ ] Workflows and patterns captured
- [ ] Principles and constraints documented
- [ ] Pending issues listed
- [ ] Next steps identified
- [ ] Restoration instructions clear
- [ ] Timestamps included
- [ ] End marker present

**Output**: Complete, verified dump file

## Dump Structure Template

### Minimal Dump (Simple Sessions)

```markdown
# CONTEXT DUMP - [Project Name]
**Generated**: YYYY-MM-DD
**Working Directory**: /path

## Session Summary
[What was done]

## Files Modified
1. file1.ext - [changes]
2. file2.ext - [changes]

## Next Steps
1. Task to do next
2. Another task

## Restoration
Working directory: /path
Key command: `command`
```

### Comprehensive Dump (Complex Sessions)

```markdown
# CONTEXT DUMP FOR [PURPOSE]
**Generated**: YYYY-MM-DD HH:MM
**Session Type**: [Type]
**Working Directory**: /full/path

---

## SESSION SUMMARY
### Primary Work Completed
[List]

### Previous Session Context
[Summary if continuation]

---

## REPOSITORY STATE
### Project Purpose
[Description]

### Current Statistics
[Key metrics]

### File Structure
[Tree with descriptions]

### Git Status
[Branch, commits, changes]

---

## DETAILED WORK THIS SESSION
### 1. [Task Name]
**File**: path
**Changes**: [detailed list]
**Issues fixed**: [if any]
**Code snippets**: [before/after]
**Rationale**: [why]

---

## WORKFLOW PATTERNS ESTABLISHED
### [Workflow Name]
[Steps and examples]

---

## CORE PRINCIPLES & CONSTRAINTS
[Domain knowledge]

---

## IMPORTANT LEARNED LESSONS
[From work this session]

---

## USER PREFERENCES & PATTERNS
[Observed preferences]

---

## PENDING/KNOWN ISSUES
[Issues with status]

---

## SESSION ENDING STATE
### Current State
[Exact state]

### Tasks Completed
[List with ✓]

### Next Logical Steps
[Prioritized list]

---

## CONTEXT RESTORATION INSTRUCTIONS
[Step-by-step restoration guide]

---

## COMMAND PATTERNS & ALIASES
[Common commands used]

---

## FILE FORMATS
[If applicable]

---

## KEY STATISTICS & METRICS
[Relevant metrics]

---

## TIMESTAMP TRAIL
[Timeline of events]

---

## END OF CONTEXT DUMP
**Total sections**: X
**Comprehensiveness**: Exhaustive
**Restoration confidence**: High
```

## Section Reference Guide

### Required Sections (Always Include)

1. **Header with Metadata**
   - Generated date/time
   - Working directory
   - Session type

2. **Session Summary**
   - What was accomplished
   - Previous context if continuation

3. **Repository/Project State**
   - Current state snapshot
   - Git status if applicable

4. **Work Completed**
   - Files modified
   - Changes made
   - Rationale

5. **Next Steps**
   - Pending tasks
   - Known issues
   - Priorities

6. **Restoration Instructions**
   - How to continue
   - Key things to remember

### Optional Sections (Include if Applicable)

7. **Workflow Patterns**
   - If new patterns established

8. **Core Principles**
   - If domain constraints exist

9. **Learned Lessons**
   - If problems solved or insights gained

10. **User Preferences**
    - If preferences observed or important

11. **Command Patterns**
    - If complex commands used repeatedly

12. **File Formats**
    - If structured formats involved

13. **Statistics**
    - If metrics tracked

14. **Timestamp Trail**
    - If timeline important

## Format Guidelines

### Markdown Structure
- Use ATX headings (`#`, `##`, `###`)
- Clear hierarchy (H1 for dump title, H2 for major sections, H3 for subsections)
- Code blocks for commands, file contents, examples
- Lists for sequential items
- Tables for structured comparisons

### Code Blocks
```markdown
```language
code here
```
```

Use syntax highlighting when beneficial:
- `bash` for shell commands
- `python`, `javascript`, etc. for code
- `diff` for changes
- `json`, `yaml` for configs
- Generic ``` for templates

### Density vs Clarity
- **Favor density**: Pack information efficiently
- **Use shorthand**: Lists, bullets, brief descriptions
- **Skip prose**: Direct facts over narrative
- **Include specifics**: File paths, line numbers, exact values
- **Code over description**: Show actual code/commands when possible

### Examples vs Abstractions
- Prefer real examples from actual session
- Include actual file paths, commands, outputs
- Show before/after for changes
- Avoid generic placeholders when you have real data

## Common Patterns

### Session Types

**New Project Session**:
- Emphasize project purpose and structure
- Document initial decisions and rationale
- Capture setup and configuration
- Establish patterns for future work

**Continuation Session**:
- Link to previous dumps or state
- Focus on delta (what changed)
- Update metrics and progress
- Maintain continuity

**Debugging Session**:
- Detailed problem description
- Attempts made and results
- Solution found (if any)
- Lessons learned

**Refactoring Session**:
- Before state snapshot
- Changes made and why
- After state snapshot
- Migration path if incomplete

**Model Transition**:
- Exhaustive current state
- All context needed to continue
- User preferences and patterns
- Quality standards and constraints

## Best Practices

1. **Create dumps proactively** - Don't wait until you hit context limits
2. **Be exhaustive** - Include more rather than less
3. **Use actual data** - Real file paths, commands, outputs
4. **Capture rationale** - Why decisions were made, not just what
5. **Include failure paths** - What didn't work and why
6. **Document constraints** - What must be followed
7. **Provide restoration path** - Clear instructions to continue
8. **Timestamp everything** - Dates matter for context
9. **Test restoration** - Can you understand it cold?
10. **Iterate format** - Improve dump structure based on what works

## Restoration Workflow

### When Loading a Dump

1. **Read header first** - Understand context and date
2. **Check session summary** - Get high-level overview
3. **Navigate to directory** - Set working directory
4. **Verify state** - Run commands from restoration instructions
5. **Review pending items** - Understand what's next
6. **Check constraints** - Note important principles/standards
7. **Read detailed sections** - As needed for specific context
8. **Execute next steps** - Continue work

### Verification Commands

After loading dump, verify state:
```bash
# Check location
pwd

# Verify git state
git status
git branch --show-current
git log --oneline -5

# Check files
ls -la
wc -l important_file.ext

# Run project-specific verification
./verify_script.sh
```

## Examples

### Example 1: Simple File Edit Session

```markdown
# CONTEXT DUMP - Config Update
**Generated**: 2026-04-13
**Working Directory**: /home/user/project

## Session Summary
Updated configuration file with new API endpoint.

## Files Modified
1. `config.yaml` - Changed API endpoint from staging to production (line 12)

## Changes
```yaml
# Before:
api_endpoint: https://staging.example.com

# After:
api_endpoint: https://production.example.com
```

## Next Steps
1. Test with production endpoint
2. Deploy if tests pass

## Restoration
Working directory: `/home/user/project`
Key file: `config.yaml`
Verify: `grep api_endpoint config.yaml`
```

### Example 2: Complex Multi-Task Session

```markdown
# CONTEXT DUMP FOR MODEL TRANSITION
**Generated**: 2026-04-13 17:45
**Session Type**: Continuation from context-limited session
**Working Directory**: /home/user/project

## SESSION SUMMARY
### Primary Work Completed
1. Fixed verify_script.sh (4 bugs)
2. Created skill-a (v1.0.0, 402 lines)
3. Created skill-b (v1.0.0, 870 lines)

### Previous Session Context
- Session started with doc updates
- User wanted automation for repetitive tasks
- Created templates and helper scripts

## REPOSITORY STATE
### Project Purpose
Tool management and documentation for X project.

### Current Statistics
- Open items: 48
- Closed items: 15
- Total: 63

### Git Status
```
Branch: main
Ahead of origin by 4 commits

Untracked files:
- file1.txt
- file2.txt
```

## DETAILED WORK THIS SESSION
### 1. Fixed verify_script.sh

**File**: /home/user/project/verify_script.sh

**Issues fixed**:
1. **Line 42**: Pattern extracted wrong number
   ```bash
   # Before:
   count=$(grep -E "pattern" file | grep -oE "[0-9]+" | head -1)

   # After:
   count=$(grep -E "better pattern" file | grep -oE "[0-9]+ items" | grep -oE "[0-9]+")
   ```

2. **Lines 37, 55, 71, 118**: Script exited early
   ```bash
   # Before:
   ((errors++))

   # After:
   errors=$((errors + 1))
   ```
   **Reason**: With `set -e`, `((errors++))` returns 0, treated as failure

[... continue with full detail ...]

## WORKFLOW PATTERNS ESTABLISHED
[... patterns ...]

## CORE PRINCIPLES & CONSTRAINTS
[... principles ...]

## PENDING/KNOWN ISSUES
1. **Doc inconsistency**: File says 15, actual count is 2
   - Action needed: Investigate and fix

## SESSION ENDING STATE
### Tasks Completed
- ✓ Fixed verify_script.sh
- ✓ Created skill-a
- ✓ Created skill-b

### Next Logical Steps
1. Resolve doc inconsistencies (high priority)
2. Test script on all files
3. Commit untracked files

## CONTEXT RESTORATION INSTRUCTIONS
When loading this dump:
1. Working directory is `/home/user/project`
2. Run `./verify_script.sh` to see current issues
3. User values automation and clean docs
4. Next action: Fix doc inconsistencies identified by script

## COMMAND PATTERNS
```bash
# Verify state
./verify_script.sh

# Check files
wc -l data/*.txt
```

## TIMESTAMP TRAIL
- Previous session: ~2026-04-10
- This session: 2026-04-13
- Dump created: 2026-04-13 17:45

## END OF CONTEXT DUMP
**Total sections**: 12
**Comprehensiveness**: Exhaustive
**Restoration confidence**: High
```

## Checklist

Use this checklist when creating a memory dump:

### Planning
- [ ] Determined dump comprehensiveness level needed
- [ ] Identified all modified files and repos
- [ ] Listed all pending/incomplete tasks
- [ ] Noted all workflows and patterns established

### Structure
- [ ] Created dump file in appropriate location
- [ ] Added header with metadata
- [ ] Included session summary
- [ ] Documented repository state

### Core Content
- [ ] Listed all files modified with changes
- [ ] Included code snippets for critical changes
- [ ] Documented rationale for major decisions
- [ ] Captured workflow patterns
- [ ] Listed core principles and constraints
- [ ] Documented learned lessons

### Pending State
- [ ] Listed all known issues
- [ ] Prioritized next steps
- [ ] Documented current exact state
- [ ] Provided restoration instructions

### Supporting Info
- [ ] Included command patterns used
- [ ] Documented file formats (if applicable)
- [ ] Listed relevant statistics
- [ ] Added timestamp trail

### Finalization
- [ ] Added end marker
- [ ] Estimated comprehensiveness
- [ ] Verified completeness
- [ ] Saved to correct location

## Red Flags

**Avoid these common mistakes:**

- ✗ **Too brief** - "Fixed bug" without details
- ✗ **Too abstract** - Generic placeholders instead of real data
- ✗ **Missing context** - Changes without rationale
- ✗ **Incomplete state** - Git status without showing actual changes
- ✗ **No restoration path** - Unclear how to continue
- ✗ **Missing timestamps** - Can't understand timeline
- ✗ **Orphaned references** - Mentions files/concepts without explanation
- ✗ **Human-optimized** - Verbose prose instead of dense facts

**Warning signs:**
- "Various changes were made" - Be specific
- "The usual workflow" - Document it explicitly
- "As mentioned before" - Dumps are standalone
- Using placeholders - Use actual data

## Tips for Different Scenarios

### Approaching Context Limit
- Focus on essentials first
- Capture state snapshots
- Document pending work clearly
- Provide quick restoration path

### Model Transition
- Be exhaustive
- Include all context
- Document user preferences
- Capture quality standards

### Long Break from Work
- Emphasize "why" over "what"
- Document domain knowledge
- Provide reorientation path
- Include links to resources

### Team Handoff
- Assume no prior knowledge
- Document all conventions
- Provide examples
- Include troubleshooting info

## Version History

- **1.0.0** (2026-04-13): Initial version based on model transition dump creation

## See Also

- **create-skill** - Framework for creating skills (meta-skill pattern)
- **refresh-docs** - Documentation maintenance workflows
- [Claude Code context management](https://docs.claude.com/)

---

**Remember**: The best dump is one that lets you (or another model) pick up exactly where you left off,
with zero questions needed. When in doubt, include it.
