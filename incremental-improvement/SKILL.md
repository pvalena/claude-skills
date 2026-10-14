---
name: Incremental Improvement
description: Find the highest-impact achievable improvement: a workflow win or an artifact-quality fix, then prove it
author: pvalena
version: 2.2.0
tags: [workflow, automation, analysis, productivity, measurement, roi, prioritization, experimental]
---

# Incremental Improvement Skill (Experimental)

**Purpose**: Systematically find the single most impactful and achievable improvement — either in a
workflow's measurable friction, or in the *quality* of an artifact you rely on — implement that one
change, and verify it delivered value.

> **Experimental**: both the ROI/measurement framework (Mode A) and the cold-review
> mode (Mode B) are new and not yet validated across diverse project types.

## When to Use This Skill

**Mode A (measured workflow optimization)** — when you:
- Complete a major workflow or project phase and want to improve the next cycle
- Notice repeated friction, errors, or wasted time in a process
- Want a concrete, measurable win rather than a vague "things could be better"
- Are ready to invest 1-4 hours implementing one improvement and proving its value

**Mode B (cold-review enhancement)** — when you:
- Have an artifact (skill, doc, script, template) that is central and worth getting right
- Just wrote or extracted something and want a fresh pass to catch what authoring missed
- Want to raise quality (completeness, correctness, robustness) where "minutes saved" doesn't apply

## Core Principles

**One improvement at a time**: Don't brainstorm 10 ideas and implement none. Find the best one,
implement it, measure it, then repeat the cycle.

**Characterize "before" first**: Capture the current state before you change it — baseline numbers
for Mode A, a ranked finding inventory for Mode B. If you can't characterize "before," you can't
show the change helped.

**Impact x Achievability**: The best improvement is not the highest-impact one (too hard) or the
easiest one (too trivial). It's the one where impact x achievability is maximized.

**Prove it worked**: An improvement you can't show the value of is just a change. Mode A proves it
with before/after numbers and ROI; Mode B proves it with the folded-in fixes passing the artifact's
checks. The cycle isn't complete until the value is demonstrated.

## Improvement Modes

This skill covers two kinds of incremental improvement. Both pick the single highest-impact
achievable change, make just that one, and prove it — they differ only in how "impact" and "proof"
are measured:

- **Mode A — Measured workflow optimization** (the Complete Workflow, Phases 1–5 below): reduce
  quantifiable friction in a repeated process. Impact = time/errors saved; proof = before/after
  numbers and ROI.
- **Mode B — Cold-review enhancement** (the "Cold-Review Enhancement" section further down): raise
  the *quality* of an artifact — a skill, doc, script, or template. Impact = a ranked inventory of
  findings; proof = the folded-in fixes passing the artifact's checks.

Pick the mode that fits what you're improving; the Red Flags and Checklist near the end note which
parts apply to each.

## Complete Workflow

*(Mode A — measured workflow optimization. For improving an artifact's quality, see Mode B below.)*

### Phase 1: Observe and Measure Current State

**Goal**: Find friction through observation and attach numbers to it.

Don't brainstorm abstractly. Instead, observe the actual workflow in action and record what you see.

#### 1. Instrument the Workflow

Run through the workflow (or review a recent execution) and record:

```
For each step in the workflow:
  - What is done (action)
  - How long it takes (seconds/minutes)
  - Whether it's manual or automated
  - Whether errors occurred (count them)
  - Whether it was repeated unnecessarily
```

**Concrete techniques:**
- **Time a task**: `time ./script.sh` or note wall-clock time for manual steps
- **Count errors**: `grep -c "ERROR\|FAIL\|MISMATCH" output.log`
- **Count repetitions**: How many times did you run the same command/edit?
- **Measure file churn**: `git log --oneline --since="1 week" -- path/ | wc -l`
- **Count manual steps**: How many things require human judgment vs. could be automated?

#### 2. Build the Friction Table

Record every point of friction with measured data:

```markdown
| # | Friction Point              | Frequency    | Time/Occurrence | Errors/Week | Manual? |
|---|-----------------------------|------------- |-----------------|-------------|---------|
| 1 | Verify doc consistency      | 5x/week      | 10 min          | 2 mismatches| Yes     |
| 2 | Format review to 120 chars  | 10x/week     | 5 min           | 3 violations| Yes     |
| 3 | Create review file skeleton | 10x/week     | 8 min           | 0           | Yes     |
| 4 | Check commit count matches  | 10x/week     | 3 min           | 1 miss/week | Yes     |
```

**Rules**:
- Use actual numbers, not "often" or "sometimes"
- Frequency must be per-day or per-week, not vague
- Time must be measured or estimated in minutes, not "a while"
- Error count must be from real observation, not hypothetical

### Phase 2: Score and Select

**Goal**: Pick the single best improvement to implement.

#### 1. Calculate Impact Score

For each friction point, calculate:

```
Weekly time cost  = frequency_per_week x minutes_per_occurrence
Weekly error cost = errors_per_week x estimated_rework_minutes_per_error
Total weekly cost = weekly_time_cost + weekly_error_cost
```

Example from the friction table above:

```
#1: Doc consistency    = 5 x 10 + 2 x 15  = 80 min/week
#2: Format to 120 char = 10 x 5 + 3 x 5   = 65 min/week
#3: Review skeleton    = 10 x 8 + 0        = 80 min/week
#4: Commit count check = 10 x 3 + 1 x 20   = 50 min/week
```

#### 2. Estimate Implementation Effort

For each, estimate:
- **Hours to implement**: Be honest. Include testing and documentation.
- **Ongoing maintenance**: Will it need updates? How often?
- **Risk**: Could it break something? (low/medium/high)

```
#1: 2 hours, low maintenance, low risk
#2: 1 hour, no maintenance, low risk
#3: 1.5 hours, low maintenance, low risk
#4: 1 hour, no maintenance, low risk
```

#### 3. Calculate ROI and Select

```
ROI = (weekly_cost_minutes x 52) / (implementation_hours x 60)
    = annual_minutes_saved / implementation_minutes
```

```
#1: (80 x 52) / (2 x 60) = 4160 / 120 = 34.7x ROI
#2: (65 x 52) / (1 x 60) = 3380 / 60  = 56.3x ROI  ← highest
#3: (80 x 52) / (1.5 x 60) = 4160 / 90 = 46.2x ROI
#4: (50 x 52) / (1 x 60) = 2600 / 60  = 43.3x ROI
```

**Select the highest ROI item** that also has low risk. If the top item has medium/high risk,
consider the next one down.

**Winner**: #2 (format checking) - highest ROI at 56.3x, low risk, 1 hour to implement.

#### 4. Define Success Criteria

Before implementing, write down exactly what "success" looks like:

```markdown
## Improvement: Automated format checking (check_format.sh)

**Baseline (measured)**:
- Time per format check: 5 minutes (manual scan + fix)
- Frequency: 10x/week
- Errors caught late: 3 violations/week found during review

**Target (after)**:
- Time per format check: < 30 seconds (run script)
- Frequency: 10x/week (unchanged)
- Errors caught late: 0 (caught at creation time)

**Success metric**: Weekly time on format checking drops from 50 min to < 5 min
**Verification method**: Time myself for 1 week after implementation
```

### Phase 3: Implement

**Goal**: Build the improvement and integrate it into the workflow.

#### 1. Implement (time-boxed)

- Set a time box equal to your estimated implementation hours
- Build the minimum viable version that addresses the friction
- Don't over-engineer: the goal is the measured improvement, not a perfect tool

#### 2. Test Against Real Data

- Run on actual workflow data, not contrived examples
- Verify output matches what manual process would produce
- Check edge cases from your error observations in Phase 1

#### 3. Integrate Into Workflow

- Replace the manual step with the automated/improved one
- Document how to use it (one paragraph or a comment in the script)
- Make it the default path (not an optional extra step)

### Phase 4: Measure and Prove

**Goal**: Verify the improvement delivered measurable value.

This phase is not optional. Without it, you have no evidence the change was worth making.

#### 1. Run the Improved Workflow

Use the improvement for at least 5 occurrences (ideally a full week) and record the same metrics
from Phase 1:

```markdown
| Metric                  | Before (measured) | After (measured) | Change        |
|-------------------------|-------------------|------------------|---------------|
| Time per occurrence     | 5 min             | 20 sec           | -93%          |
| Weekly time spent       | 50 min            | 3.3 min          | -93%          |
| Errors caught late      | 3/week            | 0/week           | -100%         |
| Annual time saved       |                   |                  | ~40 hours     |
| Implementation cost     |                   |                  | 1 hour        |
| Actual ROI              |                   |                  | 40x           |
```

#### 2. Assess Result

Compare actual ROI to predicted ROI:

- **Actual > Predicted**: Improvement delivered more than expected. Good.
- **Actual ~ Predicted**: Improvement delivered as expected. Good.
- **Actual < Predicted but positive**: Still a net win, but estimates were optimistic.
- **Actual < 1x**: Improvement cost more than it saves. Investigate why. Consider reverting.

#### 3. Record the Improvement

Document the completed improvement for future reference:

```markdown
## Completed: check_format.sh (2026-04-13)
- **Problem**: Manual format checking took 5 min/review, 3 violations/week caught late
- **Solution**: Shell script checking 120-char line width
- **Result**: 5 min → 20 sec per check, 0 late violations
- **Actual ROI**: 40x (40 hours saved annually, 1 hour invested)
```

### Phase 5: Repeat

After completing one improvement cycle, return to Phase 1 and re-observe. The workflow has changed --
previous friction points may have shifted. Run the full cycle again on the next highest-impact item.

**Cadence**: One improvement per week or per project phase is sustainable. More than that risks
incomplete implementation and unmeasured results.

## Scoring Reference

### Quick ROI Calculation

```
ROI = (frequency_per_week x minutes_saved x 52) / (implementation_hours x 60)
```

| ROI    | Interpretation                                              |
|--------|-------------------------------------------------------------|
| > 50x  | Exceptional. Implement immediately.                         |
| 10-50x | Strong. Implement when time available.                      |
| 3-10x  | Moderate. Implement if low risk and low effort.             |
| 1-3x   | Marginal. Only implement if it also reduces errors.         |
| < 1x   | Negative ROI. Don't implement unless non-time benefits.     |

**Severity can override ROI.** Rework-minutes don't capture a catastrophic error -- a security hole,
data loss, or a shipped false positive. When an error is high-severity, weight it well above its raw
time cost; preventing one such error can justify the work regardless of the ROI number.

### What Counts as Measurable

Good metrics (use these):
- **Time**: seconds, minutes per task (measurable with `time` or stopwatch)
- **Error count**: mismatches, violations, failures per week
- **Repetition count**: times a command/step is executed per task
- **File churn**: edits to same file, rework cycles

Bad metrics (avoid these):
- "Feels faster" -- measure it
- "Reduces cognitive load" -- proxy it with error count or repetition count
- "Improves quality" -- what specific quality metric changes?
- "More consistent" -- count the inconsistencies before and after

## Example: GRUB Review Workflow (Mode A, end to end)

A compact full-cycle run (the Phase 1–2 walk-throughs above use this same workflow):

| # | Friction Point        | Freq/wk | Min | Err/wk | Weekly cost     | Effort | ROI    |
|---|-----------------------|---------|-----|--------|-----------------|--------|--------|
| 1 | Doc consistency check | 5       | 10  | 2      | 80 min          | 2h     | 34.7x  |
| 2 | Format to 120 chars   | 10      | 5   | 3      | 65 min          | 1h     | 56.3x ←|
| 3 | Review file creation  | 10      | 8   | 0      | 80 min          | 1.5h   | 46.2x  |
| 4 | Statistics sync       | 3       | 5   | 1      | 25 min          | 1h     | 21.7x  |

Selected **#2** (highest ROI, low effort/risk). Implemented `check_format.sh` (1h) to scan review
files for >120-char lines. Measured after a week: 5 min → 10 sec/check, late violations 3/wk → 0,
~42 hours saved annually (actual ROI ~42x, matching the estimate). Next cycle: #3 is now the top
remaining friction.

## Cold-Review Enhancement (Mode B)

Not every improvement is a timed workflow step. Strengthening an *artifact* — a skill, a doc, a
script, a template — is also an incremental improvement, but its "measurement" is qualitative:
completeness, correctness, robustness, clarity. Use this mode on an artifact the team relies on.

The move that makes it work is **reviewing cold**: read the artifact as if it arrived from someone
else, with no memory of writing it. Your own authoring context hides the omissions; a genuinely
fresh reading surfaces them. (Same principle as the fresh-context verifier in `delegate-and-verify`
— an independent pass has no shared blind spots.)

### Procedure

1. **Read it cold.** Pretend it was written by someone else and review the whole thing as an
   external reviewer would — judge what is actually *there*, not what you *meant*.
2. **Enumerate findings.** List everything omitted, unclear, fragile, duplicated, contradictory, or
   likely to grow. For a load-bearing artifact, diligence is the value — look hard.
3. **Rank by impact; drop the zero-impact.** Order findings by impact/criticality and discard the
   trivial. If there are many, surface only the high-priority set. This ranked inventory *is* the
   "measurement" for a qualitative change — the analog of Mode A's ROI table.
4. **Let the owner choose.** Present the ranked findings and let the owner pick which to fold in;
   don't unilaterally bloat the artifact. Each accepted finding is one scoped improvement.
5. **Apply honestly, then validate.** Fold in the chosen items and run the artifact's checks (e.g.
   the skills validator). Keep integrity: don't invent content to fill a gap — for an experiential
   artifact, name the gap as a draft/candidate and mark the artifact experimental until real use
   vets it. Record what changed (version history / changelog).

### When Mode B fits

- A central skill, template, or doc worth getting right (missing cases, ambiguity, or fragility
  cost more than the review does).
- Right after writing or extracting an artifact — a cold second pass catches what authoring missed.
- **Not** for throwaway or rarely-used artifacts, where the review costs more than it returns.

### Mode B example (this skills repo)

Right after extracting the `delegate-and-verify` and `bug-patterns` skills, each got a cold read:
- **delegate-and-verify**: the cold pass found the skill described the *shape* of delegation but
  omitted how to brief an agent, failure/abort handling, a remediate-loop cap, and verifier
  independence. Ranked, owner-selected, folded in, re-validated.
- **bug-patterns**: the cold pass found no entry template (for a catalog meant to grow) and a
  missing false-positive section; those were folded in, and gaps were named as draft candidates
  rather than invented.

In both, the warm author had not seen the gaps; the cold read did.

## Combining the modes

The modes compose -- a real improvement cycle often uses both:
- **B → A**: a cold review frequently surfaces a *recurring manual friction* worth automating -- a
  Mode A candidate. (Cold-reading the review workflow is what surfaced manual format-checking, the
  Mode A example above.)
- **A → B**: a Mode A improvement is often *delivered as an artifact* (a script or skill). Give that
  artifact a Mode B cold-read before you make it the default path.
- **Inside B**: step 5's "run the artifact's checks" is itself a Mode-A automated check -- e.g. the
  skills validator. The automation (A) is what makes the quality pass (B) cheap to repeat.

## Red Flags

**Don't use Mode A when:**
- The process is used less than 3x/week (not enough frequency to justify)
- You can't measure the current state (no baseline = no proof) — if it's an artifact, use Mode B
- The "improvement" is speculative ("this might be useful someday")
- Implementation effort exceeds 8 hours (that's a project, not an increment)
- You're optimizing something already under 1 minute

**Mode A warning signs:**
- Can't write a concrete success metric with numbers
- ROI calculation comes out below 3x
- "Feels like it should be better" without friction data
- Improvement addresses a problem you've experienced once

**Mode B (cold-review) warning signs:**
- Reviewing "warm" — trusting what you meant instead of reading what's actually there.
- Inventing content to fill a gap in an experiential artifact (mark it a draft/candidate instead).
- Folding in every finding regardless of impact — rank and select; don't bloat the artifact.

## Checklist

Use the block(s) for the mode you are running (Observe/Score/Implement/Measure for Mode A;
Cold-review for Mode B):

### Observe
- [ ] Ran through or reviewed actual workflow execution
- [ ] Built friction table with measured time, frequency, and error counts
- [ ] All numbers are from observation, not guesses

### Score
- [ ] Calculated weekly cost in minutes for each friction point
- [ ] Estimated implementation effort honestly (including testing)
- [ ] Calculated ROI for each candidate
- [ ] Selected highest ROI item with acceptable risk
- [ ] Wrote success criteria with baseline numbers and targets

### Implement
- [ ] Built minimum viable improvement within time box
- [ ] Tested against real workflow data
- [ ] Integrated into workflow as default path

### Measure
- [ ] Used improvement for at least 5 occurrences
- [ ] Recorded same metrics as baseline
- [ ] Calculated actual ROI
- [ ] Documented before/after comparison
- [ ] Recorded completed improvement for reference

### Cold-review (Mode B)
- [ ] Read the artifact cold, as an external reviewer
- [ ] Enumerated findings (omissions, fragility, duplication, growth)
- [ ] Ranked by impact; dropped the zero-impact ones
- [ ] Owner selected which findings to fold in
- [ ] Applied, kept integrity (no invented content), and ran the artifact's checks

## Version History

- **1.0.0** (2026-04-13): Initial version based on GRUB review workflow optimization
- **2.0.0** (2026-04-21): Complete rewrite. Replaced generic framework with measurement-driven
  workflow. Added concrete scoring formula, mandatory baseline/after measurement, single-item
  focus, and real ROI calculation. Removed generic brainstorming categories, placeholder output
  template, and duplicate workflow steps.
- **2.1.0** (2026-10-14): Added Mode B (cold-review enhancement) -- read an artifact cold, rank
  findings by impact, let the owner select, fold in honestly, validate. The qualitative counterpart
  to the measured workflow; restores the skill's original quality-improvement intent.
- **2.2.0** (2026-10-14): Reconciled Mode A/B framing (principles, when-to-use, red flags, checklist,
  footer no longer assume measurement); added a Mode B example + "Combining the modes"; noted
  severity can override ROI; condensed the duplicated worked example.

## See Also

- **refresh-docs** - For documentation maintenance workflows
- **review** - For code review processes
- **create-skill** - For capturing improvements as reusable skills
- **todo** - For prioritizing which backlog item to improve next

---

**Key Principle**: An improvement you can't characterize is just a change. Capture "before" (numbers
for Mode A, a ranked finding list for Mode B), make the one change, then demonstrate the value (ROI,
or fixes that pass the checks).
