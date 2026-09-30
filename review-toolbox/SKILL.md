---
name: Review Toolbox
description: Read-only source inspection for code/security review via the bundled `rtb` wrapper — named git/fs sources, composable filters, a whitelisted `git -C` read path, and one-approval Bash permission. Use instead of ad-hoc `cd … && git show/grep … | sed …`.
author: pvalena
version: 1.1.0
tags: [review, security, read-only, git, tooling]
---

# Review Toolbox (`rtb`) Skill

**Purpose**: Standardize how a reviewer (you, or a subagent) reads source during code /
vulnerability review. Instead of hand-writing `cd /some/repo && git show TAG:path | sed -n
'…' | grep …` every time, route it through one wrapper: `rtb` (bundled with this skill).
This gives:

- **One-time permission** — approve `Bash(…/rtb:*)` once, not each git/grep/sed.
- **Read-only by construction** — `rtb` only ever runs `git -C <repo> <read-subcmd>` from a
  fixed whitelist; there is no code path that writes, checks out, commits, archives, or `cd`s
  into a repo. Writes are impossible, not just discouraged.
- **Named sources + tags** — repos/paths/tags live in one config (`.rtbrc`) and an optional
  human narrative (a `FACTS.md`); agents get them via `rtb facts` instead of memorizing paths.
- **Composable filters** — `--lines`, `--grep`, `--ctx`, `--head`/`--tail`, `--count` chain
  in one call, replacing `| sed | grep | head` pipelines.

## When to Use

- Any time you would otherwise run `git show <ref>:<file>`, `git grep <pat> <ref> -- …`, or
  `sed -n 'A,Bp'` / `grep -n … -A N` against a review source repo.
- Before spawning a review subagent: run `rtb facts` and paste the output into its prompt so
  it starts with the correct paths, tags, version mapping, and hard rules.

## Workflow

1. **Configure sources once** — create `./.rtbrc` (see Setup) declaring each repo/tree you'll
   read: upstream git source(s) + any patched/unpacked `fs` tree, plus an optional `RTB_FACTS`
   narrative. Run `rtb sources` to confirm they resolve.
2. **Hand facts to the reviewer** — run `rtb facts` and paste the output into your own working
   notes or a review subagent's prompt, so paths/tags/rules are fixed up front.
3. **Read, don't run** — inspect code with `rtb cat` / `rtb grep` / `rtb log` / `rtb ls`,
   chaining `--lines`/`--grep`/`--ctx`/`--head`/`--tail` instead of piping through `sed`/`grep`.
   Pick the source/ref with `--src`/`--ref`.
4. **Verify against what ships** — when a finding depends on patched code, re-check it against
   the shipped/patched source (`--src <release-tree>`), not upstream alone.
5. **Stay inside the wrapper** — never fall back to raw `git`/`sed` pipelines or build/run the
   code; that defeats the read-only permission boundary the wrapper exists to enforce.

## Hard Rules (read first)

1. **Read-only, always.** Never build/compile/run/execute the code under review. `rtb` is the
   only sanctioned way to touch the source repos.
2. **git = `git -C <repo> <read-subcmd>` only.** No raw `git` in the allow-list; no
   `checkout`/`commit`/`archive|tar`/`push`/`reset`. If you truly need a raw git *read* not
   covered by `rtb`, run it explicitly as `git -C <repo> …` and let it prompt — never add a
   broad `Bash(git *)` allow back.
3. **Keep review data local when it's sensitive.** For embargoed / private review material,
   keep inputs and outputs out of version control (e.g. a gitignored work dir) and never post
   externally. (Skip if the code under review is public.)
4. **Compare against the shipped tree.** When a distro/vendor patches upstream, the truth is
   the *patched* tree, not upstream alone — configure both as sources (e.g. `upstream` +
   a `release`/`prep` fs source) and confirm verdicts against what actually ships.

## Setup (one time per project)

1. **Config** — a source registry at `./.rtbrc` in the project (gitignore it if it points at
   private paths). Format:
   ```sh
   SRC_<name>_KIND=git|fs
   SRC_<name>_PATH=/abs/path
   SRC_<name>_REF=<default tag/branch>   # git sources only
   RTB_DEFAULT_SRC=<name>
   RTB_FACTS=./FACTS.md                  # optional narrative fed to subagents
   ```
   Resolution order: `$RTB_CONF` → `./.rtbrc` → `./.review-toolbox.conf`.
2. **Permission** — in `.claude/settings.local.json`, allow the wrapper and drop broad shell
   allows:
   ```jsonc
   "allow": [ "Bash(/abs/path/to/rtb:*)", … ]   // add rtb
   // remove: "Bash(git *)", "Bash(grep *)", "Bash(awk *)"  ← these defeat the read-only goal
   ```
3. **(optional) PATH** — `ln -s ~/.claude/skills/review-toolbox/rtb ~/.local/bin/rtb` so you
   can type `rtb` directly. The Bash permission should reference the path you actually invoke.

## Command Reference

```
rtb facts                          # FACTS.md + resolved sources — feed to subagents
rtb sources                        # table of configured sources
rtb refs [--src N]                 # list tags for a git source
rtb cat  <path> [opts]             # show a file (git: at --ref; fs: from disk)
rtb show <path> [opts]             # alias of cat
rtb grep <pattern> [opts] [-- <pathspec…>]   # git grep at ref, or grep -rn on fs
rtb log  <path> [--src N --ref R --head N]
rtb ls   [subpath] [--src N --ref R]
```

Source/ref: `--src NAME` (default from config), `--ref REF` (override tag/branch/commit).
Filters (chain freely; order lines→grep→head/tail): `--lines A,B`, `--grep PAT`,
`--ctx N`/`-C N`, `--head N`, `--tail N`, `--count`.

### Translating old habits

| Old pipeline | `rtb` equivalent |
|---|---|
| `cd R && git show v2.4.0:F \| sed -n '33,75p'` | `rtb cat F --ref v2.4.0 --lines 33,75` |
| `git show v2.4.0:F \| grep -n P -A25 \| head -40` | `rtb cat F --ref v2.4.0 --grep P --ctx 25 --head 40` |
| `git grep -n P v2.4.0 -- F1 F2` | `rtb grep P --ref v2.4.0 -- F1 F2` |
| read a patched/unpacked tree on disk | `rtb cat F --src release` |
| check a different tag | `rtb cat F --ref v2.5.0-rc1` |

## Extending

`rtb` is a single bash file — extend in place, keep it read-only:

- **New post-filter** (e.g. an `awk` transform): add a flag in `parse_common()` and a stage in
  `apply_filters()`/`_filter_*`. Keep the lines→grep→ends ordering predictable.
- **New reader** (e.g. `blame`, `annotate`): add a `cmd_<x>()` and a `main()` case; call `gitr`
  so the read-only whitelist (`GIT_READ_OK`) still applies. To allow a new git read subcommand,
  add it to `GIT_READ_OK` — never bypass `gitr`.
- **New source**: add `SRC_<name>_*` lines to `.rtbrc` and document it in your `FACTS.md`. No
  code change needed.

## Core Principles

1. **One wrapper, one approval, zero writes.** The value is the permission boundary — don't
   route around it with raw `git`/`sed` once it's set up.
2. **Facts flow to agents.** Subagents shouldn't guess paths/tags — hand them `rtb facts`.
3. **Simplicity over portability.** The script is generic and reusable; the per-project
   `.rtbrc`/`FACTS.md` are not meant to be shared.
4. **Composable, not clever.** Prefer chaining `rtb` filters over adding bespoke subcommands.

## See Also

- **review** — full structured code review; use `rtb` as its read path.
- **sanity-check** — quick pre-review malicious-intent scan; `rtb` for the reads.
- **verify-fix** — confirm a patch blocks the vector; `rtb` to diff before/after at each ref.

## Version History

- **1.0.0**: Initial version — read-only `git -C` wrapper with named sources (git+fs),
  composable line/grep/head filters, `facts`/`sources`/`refs`/`cat`/`grep`/`log`/`ls`, and
  one-approval Bash permission model.
- **1.1.0**: Genericized for the shared skills collection and made self-contained — the `rtb`
  script is now bundled alongside this `SKILL.md`; config defaults to `./.rtbrc`; project-specific
  examples/rules removed.
