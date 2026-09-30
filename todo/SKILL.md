---
name: TODO
description: Prioritize a TODO backlog by impact and achievability, draft a plan for the top item, prune when done.
author: pvalena
version: 1.0.0
tags: [planning, prioritization, workflow, backlog]
---

# TODO Skill

**Purpose**: Turn a backlog of deferred work into action. Given a TODO file (or scattered
`TODO`/`FIXME`/`HACK` notes), rank items by impact and achievability, draft a brief actionable
plan for the highest-leverage one, execute it, and prune the entry when it's done.

## When to Use

- A `TODO.txt`/`TODO.md` (or code `TODO`/`FIXME` comments) has accumulated and you need to pick
  what to do next — not just do the first thing listed.
- The user asks "what should I work on?", "pick the most impactful task", or "plan the next step".
- Before starting deferred work, to convert a one-line backlog note into a concrete plan.
- After finishing an item, to keep the backlog honest (remove what's done).

## Core Principles

1. **Impact × achievability, not order.** The top of the list is not the top priority. Score both
   dimensions and recommend the item with the best combined leverage that can actually land now.
2. **The TODO file is pending-only.** It lists what remains to be done — nothing else. When an item
   is finished, **remove it entirely**; do not annotate it `DONE`. History lives in git, not here.
3. **Draft before doing.** A one-line backlog note is not a plan. Expand the chosen item into scope,
   concrete changes, steps, and an effort/risk estimate before touching code.
4. **Recommend, don't just survey.** Present the ranking, then name one pick and why — the user can
   override, but the default should be decided.

## Workflow

1. **Gather** — read the TODO file; if asked, also scan the tree for `TODO`/`FIXME`/`HACK` comments.
   Treat each distinct item (and each sub-option) as a candidate.
2. **Score & rank** — rate every candidate on **impact** (how much it helps: reach, correctness,
   removing a defect, unblocking other work) and **achievability** (effort, risk, blast radius,
   whether it lands in one pass). Present a compact ranked table (see below).
3. **Recommend** — name the single best impact × achievability pick and say why in one line. Note
   any candidate that is high-impact but not achievable now (call it out, don't pick it).
4. **Draft the top item** — expand it into a brief plan: scope (files/sections), the concrete
   changes, ordered steps, and an effort/risk estimate. Offer distinct sub-approaches only when
   they genuinely differ; recommend one.
5. **Confirm, then execute** — on the user's go-ahead, implement the plan. Keep edits no larger than
   the draft promised.
6. **Prune** — when the item is done, **delete it from the TODO file** (do not mark it DONE). If the
   work spawned genuinely new follow-ups, add those as fresh pending entries. Commit with the change.

## Ranking Format

Present candidates as a table, most-leverage first:

| # | Task | Impact | Effort | Notes |
|---|------|--------|--------|-------|
| 1 | short task name | High/Med/Low | Low/Med/High | why it ranks here; blockers |

Follow the table with a one-line recommendation ("Recommend #1 — highest leverage and achievable in
one pass"). Keep impact/effort to High/Med/Low — precision here is false confidence.

## Drafting a Plan

For the chosen item, keep the draft brief and concrete:

- **Scope** — exactly which files/sections change; explicitly what stays untouched.
- **Changes** — the substantive edits, shown or described precisely (not "improve X").
- **Steps** — an ordered list ending with: validate, update the TODO file (prune), commit.
- **Effort/risk** — rough size (lines/passes) and risk level; note anything hard to reverse.
- **Alternatives** — only if a different sub-approach is genuinely viable; recommend one.

## The TODO File

- Format is free — grouped headings, numbered items, sub-options are all fine.
- It records **only outstanding work**. No `DONE` lines, no changelog, no dated history — those
  belong in git commits.
- Completing an item means removing its text. The file shrinks as work lands; that is the point.
- New follow-ups discovered during the work go in as new pending entries, described with enough
  context to be actionable later (what and why, not just a keyword).

## See Also

- **incremental-improvement** — measure-implement-prove cycle for a single chosen improvement.
- **create-skill** — framework/conventions when a backlog item is "create a new skill".

## Version History

- **1.0.0**: Initial version — impact × achievability ranking, plan drafting, and a pending-only
  TODO file that is pruned (not annotated) when items are done.
