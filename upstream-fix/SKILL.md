---
name: Upstream Fix
description: Turn verified vulnerability findings into per-issue fix commits on an upstream source tree, each isolated in its own worktree/branch, written by a sub-agent and adversarially reviewed, without building or testing (CI compiles). Embargo-aware.
author: pvalena
version: 1.0.0
tags: [security, fix, patch, upstream, worktree, adversarial-review, subagents, embargo]
---

# Upstream Fix Skill

**Purpose**: Convert **already-verified** vulnerability findings (e.g. the reasoning/finding files a
prior `review` pass produces) into **upstream source fixes** — one commit per issue, each on its own
branch/worktree, written by a sub-agent and then **adversarially reviewed** by a separate sub-agent,
iterating until the review is clean. No building, compiling, or testing — a CI pipeline does that.

This is the step *after* triage/evaluation: triage decides *what is real and worth fixing*; this skill
*produces the fix and proves it holds up to scrutiny*, ready for a human to open as PRs.

## When to Use

- You have a set of confirmed issues, each with enough analysis to fix (affected file/function, root
  cause, a recommended fix) — typically the per-issue finding/reasoning files from a `review` pass.
- You have the **upstream source tree** checked out and a base branch (e.g. `master`) to fix against.
- You want isolated, independently-reviewable fix commits, not a build or a release.

## Core Principles

1. **One issue, one branch, one worktree, one commit.** Isolation lets fix/review agents run in
   parallel without conflicting, and keeps each fix independently reviewable and revertable.
2. **Agents do the work; you orchestrate and gate.** A sub-agent writes each fix; a *separate*
   adversarial sub-agent reviews it. You create the worktrees, launch the agents, and make the human
   calls (skip/redirect, remediation, push). Use the subagent model policy for this host (Sonnet).
3. **Fix the shipped truth you're targeting.** Patch the *base branch's actual code* — it may differ
   from the version the finding was analyzed against. Adapt; if the bug is already fixed there, stop
   and report, don't invent a change.
4. **Never build/compile/run/test.** Inspection and editing only; CI compiles. (Source inspection of
   *other* trees for cross-checking stays read-only via the `review-toolbox` skill.)
5. **Prove the fix adversarially.** Every fix is reviewed by an agent tasked to *refute* it before it
   is considered done. A fix is "done" only when a review verdict is SOUND.
6. **Don't push.** The human opens PRs. Keep issue data local (embargo-aware); the fix commits and
   review reports live in the source repo, upstream-shaped.

## Workflow

### Phase 0 — Gather
Collect, per issue: the finding files (affected file/function, root cause, recommended fix) and the
base repo + base branch. Confirm the base branch ref.

### Phase 1 — Pre-flight existence check (orchestrator)
For each issue, confirm the **affected file/function actually exists on the base branch**. A finding
against a *downstream-only* file (introduced by distro patches, absent upstream) **cannot be fixed on
an upstream base** — flag it and ask the human whether to **skip** it or **redirect** it to the
downstream tree. Do this before creating worktrees so you don't set up dead branches.

### Phase 2 — Create isolated worktrees (orchestrator, sequential)
Create one branch + worktree per fixable issue, all off the base branch, **worktree dir named = branch**:
```
git -C <repo> worktree add -b <branch> <parent>/<branch> <base>
```
Do this **sequentially in the orchestrator**, not inside parallel agents — concurrent `git worktree
add` races the repo's worktree/ref state. Create a `review/` directory in the base repo for reports.

### Phase 3 — Fix agents (one sub-agent per worktree, parallel)
Launch a sub-agent per issue. Give each: its worktree path, the finding-file paths (read-only), and
hard rules. Each agent:
1. Reads the finding, locates the real vulnerable code **in its worktree** (adapt to the base
   branch's code; if already fixed, stop and report).
2. Makes a **minimal, style-matching** fix.
3. Commits with a documenting message (see below). Self-verifies (`git show`, clean `git status`).
4. Does **not** build/compile/run/test, touch other dirs, or push.

**Commit message:** subsystem-prefixed subject (`net/dns: …`); body = root cause + trigger + impact +
what the fix does; trailers `Resolves: <ISSUE-KEY>` then a `Co-Authored-By:` line **for every model
used** — both the fix sub-agent's model and the orchestrator's model (they differ). No `Signed-off-by`
(the maintainer adds that on submission).

### Phase 4 — Adversarial review (one sub-agent per committed fix, parallel)
After a fix is committed, launch a *separate* sub-agent (fresh context) that uses the **`review`**
skill in a **refutation stance**: try to prove the fix wrong/incomplete (correctness, completeness —
sibling call sites / other writers, regression risk, soundness/style). It writes a report to
`review/<ISSUE-KEY>.md` with: commit SHA, verdict (`SOUND` / `SOUND-WITH-NITS` / `INSUFFICIENT` /
`INCORRECT`), findings (severity · where · why · suggested change), and human-decision items.

### Phase 5 — Remediate until SOUND
On `INSUFFICIENT`/`INCORRECT`, re-task the original fix agent with the finding; it **amends** its
commit (keep it to one commit) and you **re-review**. Repeat until the verdict is SOUND. (This loop
earns its keep — adversarial passes catch second-order bugs the first fix missed, e.g. a *secondary*
overflow left after the primary one was guarded.)

### Phase 6 — Human gate, then PRs
Present a summary (issue · branch · commit · file · fix · verdict). The human **eyeballs** each
commit + review and pushes PRs. Attach the review text to each PR.

## Review-text conventions (for attaching to PRs)

Write the review as a **clean final-state** document — verdict + the substantive findings and
decision items a reviewer needs. Specifically:
- **Final state only.** If the fix went through remediation, don't narrate the earlier
  INSUFFICIENT→amended story; keep the final verdict and the findings that still matter.
- **Drop review-process technicalities that don't help the reviewer**, e.g.: upstream-vs-downstream
  commentary when the fix is upstream-only; "AI-assisted" notices; "commit-message-accuracy" checks.
- Keep real, actionable items: correctness reasoning, completeness gaps, regression risks, and
  explicit **human-decision items** (optional hardening, out-of-scope attack surface).

## Red Flags

- Running `git worktree add` inside parallel agents — race; create worktrees in the orchestrator.
- An agent "fixing" code that the base branch already fixed — it should detect and report, not invent.
- Fixing a downstream-only file on an upstream base — impossible; skip/redirect (Phase 1).
- Any build/compile/test, or pushing — out of scope; the human pushes, CI builds.
- Shipping a fix on a first green read without the adversarial pass — the refutation pass is the point.

## See Also

- **review** — produces the verified findings this skill consumes; also the per-fix adversarial
  review workflow + report format each fix is held to.
- **verify-fix** — confirm each produced fix actually blocks the vector before the human gate.
- **review-toolbox** — read-only source inspection (`rtb`) for cross-checking other trees.

## Version History

- **1.0.0**: Initial version — per-issue worktree/branch isolation, Sonnet fix sub-agents, adversarial
  review via the `review` skill, remediate-until-SOUND loop, no-build/no-push constraints, multi-model
  co-author trailers, and the final-state review-text conventions.
