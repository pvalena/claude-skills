---
name: Memory Dump
description: Create exhaustive knowledge-transfer dumps from context for model transitions, session restoration, and cross-directory continuity
author: pvalena
version: 2.0.0
tags: [meta, context, session-management, model-transition, restoration, continuity, knowledge-transfer]
---

# Memory Dump Skill

**Purpose**: Create exhaustive knowledge-transfer documents from the current context window that enable seamless continuation of work across model transitions, session boundaries, context compactions, and working directories. Think logbook, not snapshot.

## When to Use This Skill

Use this skill when:
- Approaching context window limits (token budget running low)
- Switching to a newer/different Claude model version
- Taking extended breaks from complex multi-session work
- Need to preserve detailed session state for future reference
- Creating handoff documentation for collaborative work
- Work spans multiple directories/repos that need a unified reference

## Core Principles

**Write from memory, not from discovery.** Do NOT run commands (git status, ls, grep) to gather state. Write everything from what is already in the context window. The dump captures what was learned, decided, and understood — not what `git log` says right now. If you need to verify something, do it BEFORE invoking this skill, not during.

**Logbook over snapshot.** A good dump teaches. It explains WHY things are the way they are, not just WHAT they are. A reader should understand the domain, the constraints, the failure modes, and the reasoning — not just the current file state. Structure around the domain and the work, not around "what I did today".

**Everything reusable.** Include every technical lesson, every non-obvious decision, every failure path discovered. A lesson that seems obvious now will not be obvious to a fresh model in a new context window. When in doubt, include it.

**Dense and complete.** Prefer tables for cross-referencing (fix matrices, module mappings, ticket status). Prefer inline code for patterns and commands. One thorough explanation beats three brief mentions. Long lines are fine — prioritize completeness over formatting.

**Standalone.** No "as mentioned before" references. No "see above". Every section should be understandable by a reader who jumped directly to it. Spell out acronyms on first use. Include file paths, branch names, commit SHAs.

## Structure

A dump has these sections, ordered from broadest context to most specific state. Not all sections are needed for every dump — skip what doesn't apply.

### 1. Header

```markdown
# CONTEXT DUMP — [topic/project name]
**Generated**: YYYY-MM-DD HH:MM
**Session Type**: [New/Continuation/Handoff]
**Primary Working Directory**: /full/path
```

### 2. What This Project Is

One or two paragraphs of domain context. What does this codebase do? What problem is being solved? Why does this work matter? A fresh model reading this section should understand the domain well enough to make judgment calls.

### 3. Repository Layout

All repos, branches, worktrees, and their relationships. Include:
- Paths, branch names, versions
- Which directories are worktrees of which repos (this is easy to get wrong)
- Related repos that are NOT worktrees (separate git histories)
- Cross-reference tables when naming conventions differ across versions (e.g., module numbering)
- Key tools and scripts with their invocation syntax

### 4. The Technical Domain

This is the core teaching section. Structure it around the DOMAIN, not the session history. For a security fix project, this means the vulnerability class. For a refactoring project, this means the architecture. For a migration, this means the before/after systems.

Include:
- **The pattern being fixed/built/changed** — general description, then every specific instance with data flows
- **Each instance** with: source of data → writer/transform → sink/consumer, which branches are affected, what the fix is, code snippets of before/after
- **What was verified safe** and WHY — the negative findings are as important as the positive ones. Include the reasoning so a future model doesn't re-investigate the same files.
- **Cross-cutting concerns** — things that affect multiple instances (e.g., "printf '%q' escaping is consumed on source, so downstream writers need their own escaping")

### 5. Status Per Work Unit

For multi-branch/multi-component work, a per-unit status table with commit SHAs, then detailed notes per unit. Include:
- What's done (with commit SHAs)
- What's unfixed and why
- Bugs found during the work (e.g., missed companion changes in cherry-picks)
- A summary matrix table for quick scanning

### 6. External References

Ticket/issue mappings, report file locations, test script locations. Tables work well here.

### 7. Technical Lessons Learned

Each lesson as a self-contained paragraph with:
- **The fact/rule** — stated directly
- **Why it matters** — what breaks if you get it wrong
- **The non-obvious part** — what a reasonable person would get wrong without this lesson

These should be reusable beyond this specific project. "printf -v creates globals, not caller locals" is reusable. "We fixed file X on line 42" is not — that belongs in section 5.

Also include:
- User preferences and constraints (communication style, commit message rules, scope limitations)
- Process constraints (embargo, review requirements)

### 8. Pending Work

What's left to do, ordered by priority. For each item: what it is, why it matters, what the proposed approach is (if known).

### 9. Context Restoration Instructions

Practical instructions for a fresh model picking up this work:
- Which files to read first
- Key constraints to remember
- What NOT to do (push to remote, mention exploits in commits, etc.)

### 10. Timestamp Trail

Chronological record of when major milestones happened across sessions.

### 11. End Marker

```markdown
## END OF CONTEXT DUMP
**Comprehensiveness**: [Minimal/Moderate/Exhaustive]
**Restoration confidence**: [Low/Medium/High]
```

## What Makes a Good Dump

**Good**: "printf '%q' produces shell-safe escaping that is consumed when the output is sourced. After sourcing, the variable holds the RAW value. This means printf '%q' protects exactly ONE sourcing step. If the value is then passed to another unescaped writer (like die()), the protection is gone."

**Bad**: "We used printf '%q' to fix the escaping issue."

**Good**: A module numbering table showing that the same logical module has different numeric prefixes across 4 branches, so you know to look for `74iscsi/` in rawhide but `95iscsi/` in rhel-9.

**Bad**: "Module paths vary across branches."

**Good**: "An intermediate attempt used printf -v which broke dynamic scoping — when callers declare local variables, printf -v creates globals instead of setting the caller's locals. Tests pass if you check globals; the actual caller gets empty strings."

**Bad**: "We tried printf -v but it didn't work, so we used local -n."

## File Location

- **Multi-directory projects**: Place in the parent/umbrella directory that spans all work (e.g., `source-git/DUMP_MEMORY.md` for work spanning `source-git/rawhide/`, `source-git/rhel-10/`, etc.)
- **Single-repo projects**: Place in project root
- **Global/cross-project**: `~/.claude/session_dumps/YYYY-MM-DD-topic.md`

## Relationship to CLAUDE.md and MEMORY.md

- **CLAUDE.md**: Repo instructions — what the repo is, how to work in it, constraints. Loaded automatically.
- **MEMORY.md**: Working knowledge — current status, workflows, quick reference. Invoked when needed.
- **DUMP_MEMORY.md**: Knowledge transfer — everything learned across sessions, structured for a reader who has never seen this work. Not loaded automatically — read on demand when restoring context.

DUMP_MEMORY.md is the most exhaustive of the three. It may duplicate content from CLAUDE.md and MEMORY.md intentionally — it must be standalone. When CLAUDE.md and MEMORY.md exist, the dump should still be self-contained, but can reference them in the restoration instructions ("read CLAUDE.md and MEMORY.md first").

## Version History

- **1.0.0** (2026-04-13): Initial version based on model transition dump creation
- **1.1.0** (2026-04-21): Trimmed from 1008 to ~500 lines; removed redundant templates
- **1.2.0** (2026-04-22): Optimized for LLM-readability and token efficiency
- **2.0.0** (2026-06-11): Major rewrite. Shifted from state-gathering (run commands, capture output) to knowledge-transfer (write from context window). Restructured around domain knowledge and technical lessons instead of session chronology. Added guidance on cross-directory/multi-repo dumps, lesson quality standards, and relationship to CLAUDE.md/MEMORY.md hierarchy.
