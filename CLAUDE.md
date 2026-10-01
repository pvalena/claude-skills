# Claude Code Skills Library

Personal collection of reusable Claude Code skills for code review,
documentation, security, and workflow automation. Author: pvalena.

## Repository Structure

Each skill lives in its own directory with a single `SKILL.md` file.
Skills are loaded by Claude Code from `~/.claude/skills/*/SKILL.md`.

```
├── auto-memory/        — Create/maintain project-level MEMORY.md files
├── commit/             — Project-aware commit workflow with convention discovery
├── create-skill/       — Meta-skill: framework for creating new skills
│   └── validate_skills.sh  — Validation script for all skills
├── incremental-improvement/ — Find and measure highest-impact workflow improvement
├── memory-dump/        — Exhaustive knowledge-transfer dumps across sessions
├── patch-evaluation/   — Evaluate patch sets against upstream (backport/forwardport)
├── refresh-docs/       — Coordinated documentation updates across file tiers
├── repo-config/        — Authoritative per-project config (.claude/repo-config.yml)
├── review/             — Full code review workflow (the flagship skill)
├── review-toolbox/     — Read-only source inspection via the bundled `rtb` wrapper
│   └── rtb                 — Read-only git/fs wrapper for review
├── sanity-check/       — Quick pre-review scan for malicious intent/injection
├── todo/               — Prioritize a TODO backlog, draft the top item, prune when done
└── verify-fix/         — Verify security patches block attack vectors
```

Mechanical parameters are declared once in `.claude/repo-config.yml` (the
authoritative source of truth); see the `repo-config` skill.

## Skill Categories

**Code review pipeline** (used together, in order):
1. `sanity-check` — fast malicious-intent scan before review
2. `review` — full code review with reasoning files and draft fixes
3. `verify-fix` — verify security patches actually block the vulnerability

**Documentation**:
- `auto-memory` — project MEMORY.md creation and maintenance
- `memory-dump` — cross-session knowledge transfer documents
- `refresh-docs` — coordinated updates across CLAUDE.md/MEMORY.md/docs/

**Process**:
- `incremental-improvement` — measure-implement-prove improvement cycle
- `todo` — prioritize a TODO backlog by impact × achievability, draft and prune
- `patch-evaluation` — classify/dedup/inspect patch sets against upstream
- `repo-config` — authoritative per-project config read by other skills
- `create-skill` — meta-skill for creating new skills

**Review tooling**:
- `review-toolbox` — read-only source inspection via the bundled `rtb` wrapper

## Key Conventions

Mechanical parameters (line width, validation command, commit prefix, version
files) live in `.claude/repo-config.yml` — the authoritative source of truth
(see the `repo-config` skill). This file describes conventions in prose; it does
not restate the config's values, so they can't drift.

- **SKILL.md format**: YAML frontmatter (`---` delimiters, must be first line)
  with `name`, `description`, `version`, `tags` fields, then markdown body.
  The `description` field is critical — Claude Code uses it for discoverability.
- **Line width**: see `line_width` in `.claude/repo-config.yml`.
- **Sizing**: 150–400 lines typical; domain-heavy skills may exceed 600.
  All sizing limits are soft guidance, not hard caps.
- **Sections**: `## When to Use`, `## Workflow` (or `## Complete Workflow`),
  `## Version History` are required. `## See Also` is recommended.
- **Validation**: run the `validation` command(s) from `.claude/repo-config.yml`.
  Fix errors; warnings are advisory.

## Commit Conventions

- **Version history in SKILL.md**: Keep entries to one line per version.
  Detailed changelogs go in the git commit message, not in the skill file.
- **Commit messages**: prefix and body style come from `.claude/repo-config.yml`
  (`commit.prefix`, `commit.body_style`) — currently a skill-name prefix
  (e.g., `review: trim v3.9`) with verbose detail in the body.

See `MEMORY.md` for current metrics, validation details, and lessons learned.

## Development Workflow

The validation command below is the `validation` entry in
`.claude/repo-config.yml` (authoritative); the line-width check uses its
`line_width`. Shown here as runnable examples:

```bash
# Validate all skills
~/.claude/skills/create-skill/validate_skills.sh ~/.claude/skills

# Check a specific skill's line count
wc -l SKILL-NAME/SKILL.md

# Check lines over the configured line_width
awk 'length > 120' SKILL-NAME/SKILL.md
```
