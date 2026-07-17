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
├── review/             — Full code review workflow (the flagship skill, v3.9)
├── sanity-check/       — Quick pre-review scan for malicious intent/injection
└── verify-fix/         — Verify security patches block attack vectors
```

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
- `patch-evaluation` — classify/dedup/inspect patch sets against upstream
- `create-skill` — meta-skill for creating new skills

## Key Conventions

- **SKILL.md format**: YAML frontmatter (`---` delimiters, must be first line)
  with `name`, `description`, `version`, `tags` fields, then markdown body.
  The `description` field is critical — Claude Code uses it for discoverability.
- **Line width**: 120 characters max in all skill files.
- **Sizing**: 150–400 lines typical; domain-heavy skills (review) up to 800.
- **Sections**: `## When to Use`, `## Workflow` (or `## Complete Workflow`),
  `## Version History` are required. `## See Also` is recommended.
- **Validation**: Run `create-skill/validate_skills.sh ~/.claude/skills`
  to check all skills. Fix errors; warnings are advisory.

## Commit Conventions

- **Version history in SKILL.md**: Keep entries to one line per version.
  Detailed changelogs go in the git commit message, not in the skill file.
- **Commit messages**: Prefix with skill name (e.g., `review: trim v3.9`).
  Include verbose change details here since SKILL.md version history is
  kept brief.

See `MEMORY.md` for current metrics, validation details, and lessons learned.

## Development Workflow

```bash
# Validate all skills
~/.claude/skills/create-skill/validate_skills.sh ~/.claude/skills

# Check a specific skill's line count
wc -l SKILL-NAME/SKILL.md

# Check lines over 120 chars
awk 'length > 120' SKILL-NAME/SKILL.md
```
