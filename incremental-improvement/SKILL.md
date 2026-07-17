---
name: Incremental Improvement
description: Find the highest-impact achievable improvement in a workflow, implement it, and measure the result
author: pvalena
version: 2.0.0
tags: [workflow, automation, analysis, productivity, measurement, roi, prioritization, experimental]
---

# Incremental Improvement Skill (Experimental)

**Purpose**: Systematically find the single most impactful and achievable improvement in a workflow,
measure the current state, implement the change, and verify measurable enhancement.

> **Experimental**: ROI scoring and measurement framework not yet validated
> across diverse project types.

## When to Use This Skill

Use this skill when:
- Completing a major workflow or project phase and want to improve the next cycle
- Noticing repeated friction, errors, or wasted time in a process
- Wanting a concrete, measurable win rather than a vague "things could be better"
- Ready to invest 1-4 hours implementing one improvement and proving its value

## Core Principles

**One improvement at a time**: Don't brainstorm 10 ideas and implement none. Find the best one,
implement it, measure it, then repeat the cycle.

**Measure first, improve second**: If you can't measure the current state, you can't prove the
improvement worked. Baseline measurement is mandatory, not optional.

**Impact x Achievability**: The best improvement is not the highest-impact one (too hard) or the
easiest one (too trivial). It's the one where impact x achievability is maximized.

**Prove it worked**: An improvement without measured before/after data is just a guess. The cycle
isn't complete until you have numbers showing the change delivered value.

## Complete Workflow

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

## Example: GRUB Review Workflow

### Phase 1: Observation

Observed one week of review workflow:

| # | Friction Point          | Freq/week | Min/each | Errors/week | Manual? |
|---|-------------------------|-----------|----------|-------------|---------|
| 1 | Doc consistency check   | 5         | 10       | 2           | Yes     |
| 2 | Format to 120 chars     | 10        | 5        | 3           | Yes     |
| 3 | Review file creation    | 10        | 8        | 0           | Yes     |
| 4 | Statistics sync         | 3         | 5        | 1           | Yes     |

### Phase 2: Scoring

```
#1: Weekly cost = 5x10 + 2x15 = 80 min.  Effort = 2h.  ROI = 4160/120 = 34.7x
#2: Weekly cost = 10x5 + 3x5  = 65 min.  Effort = 1h.  ROI = 3380/60  = 56.3x ← selected
#3: Weekly cost = 10x8         = 80 min.  Effort = 1.5h. ROI = 4160/90 = 46.2x
#4: Weekly cost = 3x5 + 1x10  = 25 min.  Effort = 1h.  ROI = 1300/60  = 21.7x
```

Selected: #2 (format checking). Highest ROI, lowest effort, low risk.

### Phase 3: Implementation

Created `check_format.sh` -- scans all review files for lines > 120 chars, reports violations.
1 hour to implement and test.

### Phase 4: Measurement

After 1 week of use:

| Metric              | Before     | After      | Change  |
|----------------------|-----------|------------|---------|
| Time per check       | 5 min     | 10 sec     | -97%    |
| Weekly time          | 50 min    | 1.7 min    | -97%    |
| Late violations      | 3/week    | 0/week     | -100%   |
| Actual annual saving | --        | 42 hours   | --      |
| Actual ROI           | --        | 42x        | --      |

### Phase 5: Next Cycle

Re-observed workflow. #3 (review file creation) now the highest remaining friction.
Started next cycle.

## Red Flags

**Don't use this skill when:**
- The process is used less than 3x/week (not enough frequency to justify)
- You can't measure the current state (no baseline = no proof)
- The "improvement" is speculative ("this might be useful someday")
- Implementation effort exceeds 8 hours (that's a project, not an increment)
- You're optimizing something already under 1 minute

**Warning signs of bad improvements:**
- Can't write a concrete success metric with numbers
- ROI calculation comes out below 3x
- "Feels like it should be better" without friction data
- Improvement addresses a problem you've experienced once

## Checklist

Use this checklist for each improvement cycle:

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

## Version History

- **1.0.0** (2026-04-13): Initial version based on GRUB review workflow optimization
- **2.0.0** (2026-04-21): Complete rewrite. Replaced generic framework with measurement-driven
  workflow. Added concrete scoring formula, mandatory baseline/after measurement, single-item
  focus, and real ROI calculation. Removed generic brainstorming categories, placeholder output
  template, and duplicate workflow steps.

## See Also

- **refresh-docs** - For documentation maintenance workflows
- **review** - For code review processes
- **create-skill** - For capturing improvements as reusable skills

---

**Key Principle**: An improvement you can't measure is just a change. Measure before, implement,
measure after, prove value.
