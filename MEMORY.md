# Repository Memory - Current State

**Last updated**: 2026-10-14

Quick reference for working in this repository. See `CLAUDE.md` for the repository
overview and conventions, and `DUMP_MEMORY.md` for the exhaustive cross-session
knowledge transfer.

---

## Current Status

- **Skills**: 16
- **Validation**: 0 errors, 27 warnings (all advisory — see breakdown below)
- **Commits**: 62 total
- **Largest skill**: review at 930L (over the soft <800 target; core workflow, see note)
- **Smallest skill**: todo at 89L

### Skill line counts (2026-10-14)

| Skill | Lines | Notes |
|-------|------:|-------|
| auto-memory | 526 | owns MEMORY.md lifecycle |
| bug-patterns | 173 | experimental; catalog, extracted from review |
| commit | 238 | project-aware; reads repo-config |
| create-skill | 378 | includes validate_skills.sh |
| delegate-and-verify | 170 | produce-then-verify sub-agent orchestration |
| incremental-improvement | 450 | experimental; Mode A (measured) + Mode B (cold-review) |
| memory-dump | 279 | defines CLAUDE.md/MEMORY.md/DUMP_MEMORY.md tiers |
| patch-evaluation | 314 | experimental |
| refresh-docs | 442 | owns cross-file doc synchronization |
| repo-config | 118 | authoritative per-project config |
| review | 930 | flagship; domain-heavy core workflow |
| review-toolbox | 201 | bundles the `rtb` read-only wrapper |
| sanity-check | 228 | bundles `sanity-scan.sh` |
| todo | 89 | pending-only backlog; prune when done |
| upstream-fix | 131 | per-issue fix commits in isolated worktrees |
| verify-fix | 332 | |

---

## Quick File Reference

**Key files**:
- `CLAUDE.md` — Repo overview, structure, conventions
- `MEMORY.md` — This file (working knowledge)
- `DUMP_MEMORY.md` — Exhaustive cross-session knowledge transfer
- `README.md` — Public-facing skill listing
- `TODO.txt` — Pending-only backlog (currently: review-skill future work)
- `.claude/repo-config.yml` — Authoritative project config (line width, validation,
  commit prefix, version files); skills read this first (see `repo-config` skill)
- `create-skill/validate_skills.sh` — Validation script for all skills

**Skill ownership boundaries** (to avoid duplication):
- **auto-memory** owns MEMORY.md lifecycle: creation, structure, GC, template
- **refresh-docs** owns cross-file synchronization: coordinated updates across tiers
- **repo-config** is the single source of truth for mechanical parameters
- **review** is the flagship; the review pipeline is sanity-check → review → verify-fix → upstream-fix
- **review-toolbox** (`rtb`) is the mandatory read path for all source inspection in the pipeline
- **bug-patterns** is the catalog review/sanity-check/verify-fix consult (don't inline patterns)
- **delegate-and-verify** owns the sub-agent orchestration pattern; review and upstream-fix instantiate it

---

## Validation Workflow

Run after any skill edit — this is the `validation` command declared in
`.claude/repo-config.yml` (the authoritative source):

```bash
~/.claude/skills/create-skill/validate_skills.sh ~/.claude/skills
```

**Current warnings (27)** — all advisory:
- 18× asymmetric See Also (hub-spoke: specialists → review/create-skill/etc., not reciprocated — by design)
- 4× version-history entries over 3 lines (auto-memory, incremental-improvement, memory-dump, sanity-check)
- 2× long description lines + 2× description-length (review-toolbox, upstream-fix — intentionally rich)
- 1× review over the <800 soft target (930L; core workflow, extraction already done)

**Validator checks** (in order):
1. Frontmatter: starts with `---`, has name/description/version/tags
2. Required sections: `## When to Use`, `## Workflow` variant, `## Version History`
3. `**Purpose**` statement
4. Recommended: `## See Also`
5. Sizing: error >800 (soft; review is grandfathered), warning >600
6. Line width: warning if any line > `line_width` (120)
7. Cross-references: See Also targets exist, no duplicates
8. Version history: entries should be ≤3 lines each
9. Description length: warning >120 chars
10. Asymmetric See Also: A→B but B↛A (second pass)

**Known `wc -c` gotcha**: the description length check subtracts 1 from `wc -c`
output (trailing newline). Don't revert the `desc_len=$((desc_len - 1))` line.

---

## Editing Skills

### Adding a new skill
1. Create `skill-name/SKILL.md` with YAML frontmatter
2. Include required sections (When to Use, Workflow, Version History) + `**Purpose**`
3. Add `## See Also` with related skills (prefer reciprocal links)
4. Register it in CLAUDE.md (tree + category) and README.md
5. Run validator, fix errors
6. Commit with `skill-name: …` prefix and a verbose body

### Trimming / restructuring a large skill
- **Extract** a self-contained, growable, loosely-coupled block into its own skill and
  leave a link stub (e.g. bug-patterns pulled out of review; delegate-and-verify generalized
  from review + upstream-fix). Connect, don't gut — keep domain specifics in the caller.
- Condense version history to ≤3-line entries (detail goes in the git commit message)
- Replace duplicated content with cross-references to the owning skill

### Version history convention
One line per version (≤3 lines). Verbose changelogs go in git commit messages.

---

## Lessons Learned

### awk picks up `##` inside code blocks
When counting section sizes with `awk`, `##` inside fenced code blocks counts as a
boundary. Use `grep -n '^## '` to find real sections, then compute ranges.

### Asymmetric See Also warnings are expected
Hub-spoke patterns (many skills → `review`, not reciprocated) produce many advisory
warnings by design. The user decides which asymmetries to fix.

### Experimental catalogs stay experiential
`bug-patterns` records flaws actually encountered; new patterns are either real entries
or clearly-separated draft "candidate" names — never invented descriptions. Young skills
are marked experimental.

### Cold-review (Mode B) beats warm self-review
Reviewing a just-written artifact "cold" (as if written by someone else) surfaces
omissions the author can't see. This loop is now codified as Mode B in
`incremental-improvement`; it produced the delegate-and-verify and bug-patterns enhancements.

---

## Deferred Work

See `TODO.txt` — review-skill future work (potential enhancements): investigation-file
guidance, the thin "Reviewing Multiple MRs" section, a Phase 4 example, and clarifying the
Phase 2 vs Phase 6 overlap. TODO.txt is pending-only: remove items when done (history is in git).

---

## Quick Reference

```bash
# Validate all skills
~/.claude/skills/create-skill/validate_skills.sh ~/.claude/skills

# Check specific skill size / long lines / sections
wc -l skill-name/SKILL.md
awk 'length > 120' skill-name/SKILL.md
grep -n '^## ' skill-name/SKILL.md

# Git log for a specific skill
git log --oneline -- skill-name/
```
