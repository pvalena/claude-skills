---
name: Repo Config
description: Declarative per-project config (.claude/repo-config.yml) that skills read as the authoritative source.
author: pvalena
version: 1.0.0
tags: [configuration, conventions, project, tooling]
---

# Repo Config Skill

**Purpose**: Give skills one authoritative place to read project-specific parameters -- line
width, validation commands, version-tracked files, commit conventions -- instead of each skill
re-deriving them by grepping `CLAUDE.md`/`MEMORY.md`/git history every run. The config file is
the source of truth; discovery is only a fallback for what the file does not declare.

This is a **convention plus a reader contract**, not a runtime tool. It defines where the file
lives, what it contains, and the precedence every consuming skill follows.

## When to Use

- Authoring or updating a project's `.claude/repo-config.yml`.
- Writing or editing a skill that needs project parameters (line width, validation command,
  commit prefix, version files) -- read them from here, don't hardcode or re-grep docs.
- Onboarding a repo to the skills library: declare its conventions once, up front.
- Not a runtime executable -- there is nothing to invoke; skills read the file directly.

## Core Principles

1. **The config is the source of truth.** When a key is present in `.claude/repo-config.yml`,
   skills use it verbatim and do **not** also grep `CLAUDE.md`/`MEMORY.md`/git history for that
   value. Discovery fills only keys the file does not set.
2. **Recommended, not required.** Every consuming skill must degrade gracefully: if the file is
   absent, fall back to discovery and built-in defaults exactly as before. No repo is forced to
   adopt it.
3. **One file, generic keys plus per-skill blocks.** Shared parameters live at the top level;
   skill-specific ones live under a named block (`commit:`, …). Unknown keys are ignored, so the
   schema can grow without breaking older skills.
4. **Don't duplicate the authoritative values.** Project docs (`CLAUDE.md`/`MEMORY.md`) should
   point at the config for mechanical parameters rather than restating them, so they can't drift.

## Workflow

### Authoring the config (once per project)

1. **Derive current values.** Use the `commit` skill's discovery (reads `CLAUDE.md`/`MEMORY.md`,
   infers from git history, detects project type) to learn the repo's real conventions -- or take
   them from existing project docs. Record only values you can back with a fact; omit unknowns.
2. **Write `.claude/repo-config.yml`** at the project root using the schema below.
3. **Validate it parses** as YAML and the paths/globs resolve (e.g. the `validation` command runs,
   the `version_files` globs match real files).
4. **De-duplicate docs.** Replace the now-authoritative values in `CLAUDE.md`/`MEMORY.md` with a
   pointer to `.claude/repo-config.yml` so there is a single source of truth.

### Consuming the config (in a skill)

Follow the Reader Contract below: read the file, apply the keys you understand, ignore the rest,
and never fail because the file is missing.

## Schema Reference

```yaml
# .claude/repo-config.yml -- authoritative project config for skills.
# Skills read this first; CLAUDE.md / MEMORY.md / git history are fallback only.

line_width: 120                 # int  -- max line length for checks/formatting
version_files:                  # list -- files whose version must bump on change
  - glob: "*/SKILL.md"          #         shell glob, project-root-relative
    field: "version:"           #         the version key (frontmatter/manifest)
validation:                     # list -- commands run as pre-commit / review gates
  - create-skill/validate_skills.sh .
disabled_checks: []             # list -- generic check names to skip, e.g. [version-bump]

commit:                         # commit-skill block (overrides top-level on overlap)
  prefix: "<skill>: "           #         scope-prefix | conventional | ticket | freeform
  body_style: verbose           #         verbose = detail in commit body | terse
```

| Key | Type | Consumed by | Meaning (fallback if unset) |
|-----|------|-------------|------------------------------|
| `line_width` | int | commit, review, refresh-docs, create-skill | max line length (skip the check) |
| `version_files` | list | commit | files needing a version bump (infer from project type) |
| `validation` | list | commit, review | gate commands to run (discover from docs/Makefile) |
| `disabled_checks` | list | commit | generic checks to skip (none) |
| `commit.prefix` | string | commit | message prefix style (infer from git log) |
| `commit.body_style` | string | commit | detail level in commit body (infer from git log) |

## Reader Contract

Every consuming skill resolves a parameter in this order and stops at the first hit:

1. An explicit path / `$REPO_CONFIG` env var, if the skill supports one.
2. `.claude/repo-config.yml` -- **authoritative**: if the key is here, use it and look no further.
3. Discovery fallback -- `CLAUDE.md`/`MEMORY.md` grep, then git-history inference -- **only** for
   keys absent from the config (or when no config file exists).
4. The skill's built-in default.

Rules for authors: read the file once, apply only the keys you understand, ignore unknown keys,
and treat a missing file as "fall through to discovery" -- never an error.

## Adoption

- **commit** already consumes it: it reads `.claude/repo-config.yml` first, then falls back to
  CLAUDE.md/MEMORY.md/git-history discovery for anything the file omits.
- Other skills reference it for the parameters they use (line width, validation) and fall back to
  discovery when it is absent.
- `.claude/commit.yml` is superseded -- use the single generic `.claude/repo-config.yml`.

## See Also

- **commit** - primary consumer: conventions, checks, version/validation parameters.
- **create-skill** - framework and conventions for building skills that consume this config.
- **refresh-docs** - keeps docs in sync after the config becomes the source of truth.

## Version History

- **1.0.0**: Initial version -- `.claude/repo-config.yml` schema (line_width, version_files,
  validation, disabled_checks, commit block), the authoritative-source reader contract, and
  authoring/consuming workflow. Supersedes the per-skill `.claude/commit.yml`.
