# Repository Memory - Current State

**Last updated**: 2026-07-18

Quick reference for working in this repository. See `CLAUDE.md` for repository overview.

---

## Current Status

- **Skills**: 9 (auto-memory, create-skill, incremental-improvement, memory-dump,
  patch-evaluation, refresh-docs, review, sanity-check, verify-fix)
- **Validation**: 0 errors, 15 warnings (all advisory — asymmetric See Also, sizing)
- **Commits**: 33 total
- **Largest skill**: review at 789L (under 800 hard max, above 600 "consider trimming")
- **Smallest skill**: memory-dump at 218L

### Skill line counts (2026-07-18)

| Skill | Lines | Notes |
|-------|------:|-------|
| auto-memory | 493 | |
| create-skill | 375 | includes validate_skills.sh |
| incremental-improvement | 369 | |
| memory-dump | 218 | |
| patch-evaluation | 314 | experimental |
| refresh-docs | 437 | deduped with auto-memory in v1.2.0 |
| review | 789 | domain-heavy, acceptable per sizing guidelines |
| sanity-check | 247 | |
| verify-fix | 327 | |

---

## Quick File Reference

**Key files**:
- `CLAUDE.md` — Repo overview, structure, conventions (72L)
- `MEMORY.md` — This file
- `TODO.txt` — Deferred work items for the review skill (31L)
- `create-skill/validate_skills.sh` — Validation script for all skills (147L)

**Skill ownership boundaries** (to avoid duplication):
- **auto-memory** owns MEMORY.md lifecycle: creation, structure, GC, template
- **refresh-docs** owns cross-file synchronization: coordinated updates across tiers
- **review** is the flagship; review pipeline is: sanity-check → review → verify-fix

---

## Validation Workflow

Run after any skill edit:

```bash
~/.claude/skills/create-skill/validate_skills.sh ~/.claude/skills
```

**Current warnings (15)** — all advisory:
- 2× sizing warnings (auto-memory 493L, review 789L)
- 4× long-line warnings (various skills)
- 9× asymmetric See Also (hub-spoke: many skills → review, not all reciprocated)

**Validator checks** (in order):
1. Frontmatter: starts with `---`, has name/description/version/tags
2. Required sections: `## When to Use`, `## Workflow` variant, `## Version History`
3. `**Purpose**` statement
4. Recommended: `## See Also`
5. Sizing: error >800, warning >600
6. Line width: warning if any line >120 chars
7. Cross-references: See Also targets exist, no duplicates
8. Version history: entries should be ≤3 lines each
9. Description length: warning >120 chars
10. Asymmetric See Also: A→B but B↛A (second pass)

**Known `wc -c` gotcha**: The description length check subtracts 1 from `wc -c`
output because `wc -c` counts the trailing newline. This was a bug found and
fixed during development — don't revert the `desc_len=$((desc_len - 1))` line.

---

## Editing Skills

### Adding a new skill

1. Create `skill-name/SKILL.md` with YAML frontmatter
2. Include required sections (When to Use, Workflow, Version History)
3. Add `**Purpose**` statement after the title
4. Add `## See Also` with related skills
5. Run validator, fix errors
6. Commit with `skill-name: initial version` message

### Trimming a large skill

Techniques used successfully on review (914→789L) and refresh-docs (759→437L):
- Condense version history to one-liners (detail goes in git commit message)
- Replace duplicated content with cross-references to the owning skill
- Collapse code blocks to compact lists where the structure is more important than syntax
- Remove verbose anti-pattern explanations — one line per anti-pattern suffices

### Version history convention

One line per version in SKILL.md. Verbose changelogs go in git commit messages.
Example: `- **1.2.0** (2026-07-18): Deduped with auto-memory skill`

---

## Lessons Learned

### awk picks up `##` inside code blocks
When counting section sizes with `awk`, `##` headings inside markdown fenced
code blocks get counted as section boundaries. Use `grep -n '^## '` with line
numbers to find real top-level sections, then calculate sizes from line ranges.

### Validator testing requires `;` for exit code capture
`./validate_skills.sh; echo "Exit: $?"` — NOT `./validate_skills.sh && echo` or
piped through `echo "Exit: $?"` in the same command, which captures the wrong `$?`.

### Asymmetric See Also warnings are expected
Hub-spoke patterns (many skills reference `review`, but `review` doesn't reference
all of them back) produce many warnings. This is advisory and by design — the user
decides which asymmetries to fix.

---

## Deferred Work

See `TODO.txt` for review skill future work:
1. Extract GRUB-specific Common Bug Patterns (option a/b/c in TODO.txt)
2. Clarify review scope vs automated PR review (/review, /code-review)
3. Potential enhancements (investigation files, parallel review, Phase 4, Phase 2/6)

---

## Quick Reference

```bash
# Validate all skills
~/.claude/skills/create-skill/validate_skills.sh ~/.claude/skills

# Check specific skill size
wc -l skill-name/SKILL.md

# Find long lines (>120 chars)
awk 'length > 120' skill-name/SKILL.md

# Check a skill's sections and sizes
grep -n '^## ' skill-name/SKILL.md

# Git log for a specific skill
git log --oneline -- skill-name/
```
