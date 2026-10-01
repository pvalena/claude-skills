# Claude Code Skills

Personal collection of reusable [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
skills for code review, documentation, security, and workflow automation.

_Disclaimer: this is all quite new; please excuse any mistakes or shortcomings._

## Installation

Clone into your Claude Code skills directory:

```bash
git clone https://github.com/pvalena/claude-skills.git ~/.claude/skills
```

Or symlink if you prefer to keep the repo elsewhere:

```bash
git clone https://github.com/pvalena/claude-skills.git ~/repos/claude-skills
ln -s ~/repos/claude-skills ~/.claude/skills
```

Claude Code automatically loads skills from `~/.claude/skills/*/SKILL.md`.

## Skills

### Code Review Pipeline

Used together, in order:

| Skill | Description |
|-------|-------------|
| **sanity-check** | Quick pre-review scan for malicious intent, prompt injection, and suspicious patterns |
| **review** | Full structured code review with reasoning files and draft fixes |
| **verify-fix** | Verify security patches actually block the attack vector |
| **review-toolbox** | Read-only source inspection via the bundled `rtb` wrapper (named git/fs sources, composable filters, one-approval Bash permission) — supports the whole pipeline |

### Documentation

| Skill | Description |
|-------|-------------|
| **auto-memory** | Create and maintain project-level MEMORY.md files for working knowledge |
| **memory-dump** | Exhaustive knowledge-transfer documents for session handoffs |
| **refresh-docs** | Coordinated documentation updates across CLAUDE.md, MEMORY.md, and docs/ |

### Process

| Skill | Description |
|-------|-------------|
| **commit** | Project-aware commits — discovers conventions from CLAUDE.md, runs pre-commit checks |
| **incremental-improvement** | Find and measure the highest-impact workflow improvement |
| **todo** | Prioritize a TODO backlog by impact × achievability, draft the top item, prune when done |
| **repo-config** | Declarative per-project config (`.claude/repo-config.yml`) skills read as the source of truth |
| **patch-evaluation** | Evaluate patch sets against upstream for backport/forwardport *(experimental)* |
| **create-skill** | Meta-skill: framework and conventions for creating new skills |

## Usage

Skills are invoked in Claude Code by name:

```
/commit
/review
/sanity-check
```

Claude Code matches skills by their `description` field, so they may also
activate contextually when your request matches what a skill does.

## Validation

All skills are checked by a validation script:

```bash
~/.claude/skills/create-skill/validate_skills.sh ~/.claude/skills
```

## Author

Pavel Valena ([@pvalena](https://github.com/pvalena))
