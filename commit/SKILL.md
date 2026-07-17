---
name: Project Commit
description: Project-aware commits — discover conventions from CLAUDE.md, run pre-commit checks, format messages
author: pvalena
version: 1.0.0
tags: [commit, conventions, validation, workflow, pre-commit, git]
---

# Project Commit Skill

**Purpose**: Augment Claude Code's built-in commit workflow with project-specific conventions —
prefix format, pre-commit validation, and quality checks discovered from the project's own
documentation and history.

## When to Use This Skill

Use when:
- Committing in a project with documented commit conventions (prefix, message structure)
- Project has validation scripts that should run before every commit
- Want to catch forgotten version bumps, line width violations, or scope mixing
- Want consistent commit formatting across sessions in the same project

Do NOT use when:
- The project has no conventions and the built-in commit workflow is sufficient
- The user explicitly asks for a quick commit without checks

## Core Principles

**Discover, don't assume.** Read project docs and history to find conventions.
Never carry conventions from one project to another.

**Augment, don't replace.** The built-in commit instructions handle staging,
Co-Authored-By, and message drafting. This skill adds convention discovery and
pre-commit checks on top.

**Fail before committing, not after.** All checks run before `git commit`. A
check that runs after commit is a wasted check.

**Generic checks, project-specific config.** The check types (line width,
version bump, validation) are generic. The parameters (120 chars, SKILL.md,
validate_skills.sh) come from the project.

---

## Workflow

### Phase 1: Discover Conventions

**Goal**: Build a convention profile from project documentation and git history.

#### 1. Check for repo-config (future integration)

Look for `.claude/commit.yml` or `.claude/repo-config.yml`. If present, read
and use it — keys: `prefix`, `validation`, `line_width`, `version_files`,
`body_style`. If absent, proceed to fallback sources below.

#### 2. Read project documentation

```bash
grep -i -A 5 'commit\|prefix\|message.*format' CLAUDE.md 2>/dev/null
grep -i -A 3 'commit\|version.*convention' MEMORY.md 2>/dev/null
```

Look for: prefix format, required checks, validation script paths, line width
limits, version history conventions.

#### 3. Infer from git history

```bash
git log --oneline -20
```

Detect prefix pattern from recent commits:
- `scope: message` — scope-prefix (e.g., `review: trim v3.9`)
- `type(scope): message` — conventional commits
- `TICKET-123: message` — ticket-prefix
- No consistent pattern — freeform

#### 4. Detect project type

Check for version-tracked files to know what needs version bump checks:
- `*/SKILL.md` — skills repo (check `version:` in frontmatter)
- `package.json` — JS/TS (check `"version":`)
- `pyproject.toml` / `setup.py` — Python
- `Cargo.toml` — Rust
- `pom.xml` — Java

#### 5. Find validation commands

```bash
grep -oE '[a-zA-Z0-9/_.-]+\.(sh|py)' CLAUDE.md MEMORY.md 2>/dev/null \
  | sort -u
```

Also check: `Makefile` (make lint/test), `package.json` (npm run lint/test).

#### 6. Output the discovered profile

Report what was found before proceeding — the user should see and confirm:

```
Discovered conventions:
  Prefix:      "skill-name: " (from CLAUDE.md)
  Validation:  create-skill/validate_skills.sh (from MEMORY.md)
  Line width:  120 chars (from CLAUDE.md)
  Version:     */SKILL.md version: field (from project type)
  Body style:  verbose — detail in commit message (from CLAUDE.md)
```

---

### Phase 2: Pre-Commit Checks

**Goal**: Catch project-specific issues before committing.

Run all checks, report all findings. Do not stop at the first failure.

#### Check 1: Project validation

If a validation script was discovered, run it on the relevant scope:

```bash
path/to/validate.sh; echo "Exit: $?"
```

Non-zero exit code → FAIL.

#### Check 2: Line width

If a line width convention was discovered, check only staged files:

```bash
for f in $(git diff --cached --name-only); do
  [ -f "$f" ] && awk -v f="$f" -v w=120 \
    'length > w {print f":"NR": "length" chars"}' "$f"
done
```

Any hits → WARN with file:line details.

#### Check 3: Version bump

If staged changes include version-tracked files with substantive content
changes (not just whitespace), check whether the version field changed:

```bash
git diff --cached -- '*.md' | grep '^[+-]version:'
```

Content changed but no version diff → WARN. This is advisory — the user
may intentionally skip a version bump for minor edits.

#### Check 4: Scope coherence

Review staged file list for unrelated changes:

```bash
git diff --cached --stat
```

If changes span unrelated directories or concerns, suggest splitting.
Always WARN, never FAIL — the user decides.

#### Report findings

```
Pre-commit checks:
  [PASS] Validation: 0 errors
  [WARN] Line width: 2 lines over 120 chars in review/SKILL.md
  [WARN] Version: review/SKILL.md changed but version not bumped
  [PASS] Scope: all changes in review/
```

- Any FAIL → stop and fix before committing
- Any WARN → report to user, ask whether to proceed or fix
- All PASS → proceed to Phase 3

---

### Phase 3: Draft and Commit

**Goal**: Format the commit message per discovered conventions and execute.

#### 1. Apply prefix format

Based on discovered pattern:
- **Scope-prefix** (`skill: message`): determine scope from the primary
  directory of changed files
- **Conventional** (`type(scope): message`): infer type from diff — `feat`
  for new files, `fix` for bug fixes, `docs` for docs only, `refactor`
  for restructuring
- **Ticket-prefix**: extract from branch name or prompt user
- **None**: follow built-in message rules

#### 2. Structure the body

- **Verbose** (e.g., this skills repo): summary line + blank line +
  bullet-point details of each change + blank line + Co-Authored-By.
  Verbose details go in the commit message because version history files
  are kept to one-liners.
- **Brief**: summary line + Co-Authored-By trailer only.

#### 3. Execute

Follow the built-in commit instructions: stage specific files (not
`git add -A`), use HEREDOC format for the message, include Co-Authored-By
trailer. Do not use `--no-verify` unless the user explicitly asks.

#### 4. Post-commit verify

```bash
git log -1 --format='%s'
```

Confirm the prefix and format match the discovered conventions.

---

## Version History

- **1.0.0** (2026-07-18): Initial version

## See Also

- **create-skill** — Includes validate_skills.sh used as pre-commit validation example
- **refresh-docs** — For updating project docs that contain commit conventions
- **auto-memory** — For maintaining MEMORY.md where commit conventions may be documented
