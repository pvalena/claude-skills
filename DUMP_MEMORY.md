# DUMP_MEMORY.md — Claude Code Skills Library

Exhaustive cross-session knowledge transfer for this repo. The most durable of the three
documentation tiers; it captures *why things are the way they are* and the mental models
behind the collection, not the live metrics.

**On restoration, read in this order:** `CLAUDE.md` (what the repo is, conventions) →
`MEMORY.md` (current status, line counts, validation state, lessons) → this file (deep
model + decisions). Current numbers live in MEMORY.md; this file intentionally avoids
restating counts that would drift. For history, `git log` is authoritative.

---

## What this repo is

A personal library of reusable Claude Code skills (author: pvalena), one skill per
directory as `skill-name/SKILL.md`, loaded from `~/.claude/skills/*/SKILL.md`. Domains:
code review, security, documentation, and workflow automation. See `CLAUDE.md` for the
full structure tree and categories.

---

## Architecture & mental models

### Three documentation tiers (defined by the `memory-dump` skill)
- **CLAUDE.md** — repo instructions: what it is, how to work, conventions.
- **MEMORY.md** — working knowledge: current status, metrics, validation, lessons.
- **DUMP_MEMORY.md** — this file: everything learned across sessions, exhaustive.
Reference truth across tiers (point at a skill's own phase list), never transcribe it —
copies drift silently.

### repo-config is the single source of truth
Mechanical parameters (line width, validation command, commit prefix/body style, version
files) live once in `.claude/repo-config.yml` and are authoritative. CLAUDE.md/MEMORY.md
and the skills describe conventions in prose and *point at* the config rather than
restating its values, so they cannot drift. `.gitignore` tracks `.claude/repo-config.yml`
while ignoring the rest of `.claude/` (`.claude/*` + `!.claude/repo-config.yml`). Reader
contract precedence: explicit path/env → repo-config.yml → discovery fallback → built-in
default; degrade gracefully when absent.

### The code-review pipeline
`sanity-check` (malicious-intent scan) → `review` (deep human-directed review) →
`verify-fix` (confirm the fix blocks the vector) → `upstream-fix` (produce per-issue fix
commits). `review` is the flagship and the deep counterpart to the built-in `/review` and
`/code-review` automated triage.

### The read-path boundary (`rtb` / review-toolbox)
All source inspection in the pipeline goes through `rtb` (bundled in review-toolbox): a
read-only wrapper that only ever runs `git -C <repo> <whitelisted-read-subcmd>` — no
writes, checkout, cd, or network. The value is a single Bash permission approval and a
structurally read-only boundary. `review` and `sanity-check` mandate it; raw git in any
form (`git -C`, `cd && git`, `git | sed`) is disallowed because agents told to "follow
exactly" were copying raw-git examples and bypassing the boundary. Commands include
cat/show/grep/log/diff/messages/ls/refs/facts; `rtb facts` hands a sub-agent its
read-context up front.

### The delegation pattern (`delegate-and-verify`)
A task-agnostic produce-then-verify orchestration generalized from the duplicated shape in
`review` (two-agent pipeline, multi-MR) and `upstream-fix`: isolate per unit (one item or
a coherent batch) → size the batch by weight + shared context → worker produces (fresh
context, parallel-safe, writes to a known path) → separate fresh-context adversarial
verifier refutes (re-derives from primary source) → orchestrator gates (spot-check red
flags only, never pass claims through unaudited) → remediate until clean (capped, then
escalate) → synthesize for the human. The skill owns the orchestration; callers keep their
domain. Trust does not launder through delegation: untrusted input stays untrusted, and an
agent's own output is untrusted (why the adversarial pass + spot-checks exist).

### Two modes of incremental improvement
`incremental-improvement` covers **Mode A** (measured workflow optimization: friction
table → ROI → implement → prove with before/after numbers) and **Mode B** (cold-review
enhancement: read an artifact cold, rank findings by impact, owner selects, fold in
honestly, validate). Mode B's ranked finding inventory is the qualitative analog of Mode
A's ROI table. The modes compose: B surfaces frictions to automate (→A); an A improvement
delivered as an artifact deserves a B cold-read; and B's "run the checks" step is itself a
Mode-A automation (e.g. the validator).

---

## Key patterns & decisions (with rationale)

- **Extract, don't gut.** When a block is large, self-contained, growable, and loosely
  coupled, extract it into its own skill with a link stub (bug-patterns ← review;
  delegate-and-verify ← review + upstream-fix). Integration is minimal and *connecting*:
  add a pointer + reciprocal See Also, keep domain specifics in the caller.
- **Cold-review beats warm self-review.** A just-written artifact is reviewed as if written
  by someone else; the author's context hides omissions. Codified as Mode B. This loop
  produced the delegate-and-verify robustness set and the bug-patterns template.
- **Experiential catalogs stay honest.** `bug-patterns` records flaws actually hit. New
  coverage is either a real entry or a clearly-separated draft "candidate" *name* — never
  an invented description. Young/unproven skills are marked experimental.
- **TODO.txt is pending-only.** Remove an item when done (do NOT annotate "DONE"); history
  lives in git. Owned by the `todo` skill (prioritize by impact × achievability, draft,
  prune).
- **Version history is terse.** ≤3 lines per entry in SKILL.md; verbose detail goes in the
  git commit body. Commit convention: `skill-name:` prefix + verbose body.
- **Warnings are triaged, not blindly cleared.** Asymmetric hub-spoke See Also, deliberately
  rich (long) descriptions, and review's length are accepted as advisory/intentional.

---

## Security constraints & guarantees (do not weaken)

- **`rtb` is read-only by construction** — never add a write subcommand to `GIT_READ_OK`
  or bypass the `gitr` guard; never restore a broad `Bash(git *)` allow.
- **sanity-check scans before ingest.** `sanity-scan.sh` dumps raw commit messages/diff to
  temp files and returns only section headers + grep matches, so an injection payload never
  enters the LLM context before it is scanned. A bad range exits non-zero (range-resolve
  guard) rather than a false all-clear — keep that guard.
- **Embargo awareness.** Keep private/embargoed review material out of version control; the
  real example config at a RHEL-internal path must never be copied into the repo.
- **Don't push.** Work is committed locally; a human opens PRs / pushes.

---

## Recent major work (this line of sessions)

See `git log` for specifics; highlights (most recent first): incremental-improvement Mode A/B
reconciliation and Mode B addition; bug-patterns enhancement (template, false positives,
draft candidates) and its extraction from review; delegate-and-verify new skill + wiring
into review/upstream-fix; upstream-fix new skill; rtb `messages`/`diff`/`log` additions and
read-path enforcement; sanity-scan.sh bundling; repo-config skill + authoritative config seed.

---

## Gotchas

- `awk` counts `##` inside fenced code blocks as section boundaries — use `grep -n '^## '`.
- The validator's description-length check subtracts 1 from `wc -c` (trailing newline);
  don't revert `desc_len=$((desc_len - 1))`.
- Long descriptions trip two warnings at once ("lines over 120" + "description is N chars")
  — intentional for discoverability on review-toolbox/upstream-fix.
- Run the validator with `;` to capture its exit code, not `&&`/pipe.
