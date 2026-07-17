---
name: Verify Security Fix
description: Verify security patches by tracing attack vectors, testing injection prevention, and scanning for variants
author: pvalena
version: 1.0.0
tags: [security, verification, vulnerability, injection, patch, code-review]
---

# Verify Security Fix Skill

**Purpose**: Systematically verify that a security fix actually prevents the
reported vulnerability, preserves existing behavior, and that no analogous
vulnerabilities remain in the codebase.

## When to Use This Skill

Use this skill when:
- A patch has been applied to fix a command injection, code injection, or similar vulnerability
- You need to verify a security fix before shipping it to production
- A vulnerability report (CVE, PSIRT, internal) needs validation against the actual code
- You want to confirm functional equivalence after a security-motivated code change
- You need to scan a codebase for variants of a known vulnerability pattern
- You're writing a verification report for an embargoed or coordinated disclosure

## Core Principles

1. **Trace, don't assume.** Follow data from attacker-controlled source to
   execution sink. Don't trust claims in vulnerability reports — verify against
   the actual code in the actual branch.

2. **Test both directions.** A fix must block malicious input AND preserve
   clean input behavior. Escaping that breaks legitimate values is a regression.

3. **Pattern, not instance.** Every vulnerability is an instance of a pattern.
   After verifying the specific fix, search the codebase for the same pattern
   elsewhere.

4. **Evidence over narrative.** Verification reports include actual command
   output, not descriptions of what should happen.

5. **Distinguish data sources.** Not all input is equal. Separate
   network-reachable (DHCP, DNS, HTTP) from local-only (kernel cmdline,
   config files, sysfs). Network-reachable is the priority for production
   fixes; local-only is hardening.

## Workflow

### Phase 1: Understand the Vulnerability

**Goal**: Build a precise mental model of the attack before looking at the fix.

#### 1. Read the vulnerability report

Identify:
- **Source**: Where does attacker-controlled data enter? (e.g., DHCP option,
  HTTP header, user input field, DNS response)
- **Sink**: Where does it reach dangerous execution? (e.g., `eval`, shell
  sourcing via `. file`, `echo` into a script, SQL query, template rendering)
- **Transform chain**: What happens to the data between source and sink? List
  each function/file/variable hop.
- **Injection mechanism**: What specific syntax breaks out? (e.g., single-quote
  terminates a shell string, backtick triggers command substitution, `--` ends
  option parsing)

#### 2. Verify the report against the code

Read the actual source files cited in the report. Check:
- Do the cited file paths and line numbers exist in this branch/version?
- Is the vulnerable code pattern present as described?
- Is the claimed data source actually reachable from a network attacker?

Common report errors to catch:
- Wrong file paths (different module versions, renamed files)
- Version mismatch (vulnerability exists in v2 but you're on v1)
- Overstated reachability (claims "DHCP-reachable" but data actually comes
  from kernel cmdline)
- Proposed fixes that introduce new bugs

**Output**: A confirmed source → transform → sink chain with file paths and
line numbers.

### Phase 2: Understand the Fix

**Goal**: Know exactly what changed and why it's correct.

#### 1. Read the patch

```bash
git diff <commit>~1 <commit>     # single commit
git diff <base>..<branch>         # full branch diff
```

#### 2. Classify the fix technique

Common fix patterns:

| Technique | When to use | Watch out for |
|---|---|---|
| `printf '%q'` | Shell variable escaping | Only works under bash, not POSIX sh |
| `printf '%s'` | Write data, not code | Consumer must also change to read data, not source shell |
| Input validation | Reject bad input | Allowlist > denylist; check for bypasses |
| Parameterized queries | SQL injection | Ensure ALL query paths are covered |
| Context-aware escaping | XSS, template injection | Must match the output context (HTML attr vs body vs JS) |
| `local -n` / nameref | Replace `eval` for variable indirection | Requires bash 4.3+; check shell version |
| Quoting/escaping at boundary | General injection | Escape at the write site, not the read site when possible |

#### 3. Check for regressions

- Does the fix change the output format for legitimate input?
- Are there dual consumers (file read as both shell AND plain text)?
- Does escaping produce output that downstream parsers can't handle?

**Output**: Clear understanding of the fix mechanism and any format changes.

### Phase 3: Verify the Fix Blocks the Attack

**Goal**: Prove the specific injection vector no longer works.

#### 1. Reproduce the vulnerable transform

Isolate the vulnerable code path and test it with a crafted payload:

```bash
# Example: shell injection via echo into sourced script
# OLD (vulnerable):
echo "var='$attacker_input'" > /tmp/test.sh
# With payload: attacker_input = "';touch /tmp/pwned;#"
# Produces: var='';touch /tmp/pwned;#'

# NEW (fixed):
printf "var=%q\n" "$attacker_input" > /tmp/test.sh
# Produces: var=\'\;touch\ /tmp/pwned\;\#
```

#### 2. Test multiple injection vectors

Don't test just one payload. Cover the injection mechanism's variants:

| Injection class | Test payloads |
|---|---|
| Shell command substitution | `` `touch /tmp/pwned` ``, `$(touch /tmp/pwned)` |
| Shell command chaining | `; touch /tmp/pwned`, `&& touch /tmp/pwned`, `\|\| touch /tmp/pwned` |
| Quote breakout (single) | `';touch /tmp/pwned;#` |
| Quote breakout (double) | `";touch /tmp/pwned;#` |
| Newline injection | `$'value\nmalicious_command'` |
| Backlash escape | `\\$(touch /tmp/pwned)` |
| SQL injection | `' OR 1=1 --`, `'; DROP TABLE users;--` |
| Path traversal | `../../../etc/passwd`, `....//....//etc/passwd` |

#### 3. End-to-end sourcing/execution test

Don't just compare output strings — actually source/execute the result:

```bash
# Generate the output using the FIXED code
printf '%q ' "$exe" "$@" > /tmp/test-hook.sh
printf '\n' >> /tmp/test-hook.sh

# Source it and check for side effects
rm -f /tmp/pwned
bash -c '. /tmp/test-hook.sh' 2>/dev/null || true
test -f /tmp/pwned && echo "VULNERABLE" || echo "SAFE"
```

**Output**: For each test vector: payload, generated output, execution result
(SAFE/VULNERABLE).

### Phase 4: Verify Functional Equivalence

**Goal**: Prove that legitimate inputs produce identical behavior.

#### 1. Identify representative clean inputs

Use realistic values from the domain:
- Normal case (e.g., `myhost.example.com`, `10.0.2.1`, `iqn.2006-01.com.example:target`)
- Edge cases (empty string, maximum length, special-but-valid characters like
  `:`, `.`, `-`, `_`)
- Unicode if applicable

#### 2. Compare old vs new output

```bash
# For each test input:
echo "Old output: $(echo "$exe" "$clean_input")"
echo "New output: $(printf '%q ' "$exe" "$clean_input"; printf '\n')"
# Verify they are identical for clean inputs
```

If the fix changes the output format (e.g., from shell-script to plain-data),
verify the consumer handles the new format correctly.

**Output**: For each clean input: old output, new output, MATCH/DIFFERS.

### Phase 5: Scan for Related Patterns

**Goal**: Find other instances of the same vulnerability class in the codebase.

#### 1. Identify the vulnerable pattern signature

Abstract the specific bug into a searchable pattern:

```bash
# Example: "echo writing variables into files that get sourced"
grep -rn 'echo.*\$.*>' modules.d/ --include='*.sh' | grep -v '#'

# Example: "eval with variable arguments"
grep -rn 'eval ' modules.d/ --include='*.sh' | grep -v '#'

# Example: "files being sourced from /tmp"
grep -rn '\. /tmp/' modules.d/ --include='*.sh' | grep -v '#'
```

#### 2. Triage each match

For each match, determine:
- **Is the data attacker-controlled?** Trace back to the source. Network input
  = fix needed. Local/hardcoded = hardening only.
- **Is the sink dangerous?** Sourced shell = dangerous. Config file read by a
  parser = usually safe. Command argument with proper quoting = safe.
- **Is it already mitigated?** Check if escaping/validation exists upstream.

#### 3. Classify findings

| Category | Meaning | Action |
|---|---|---|
| Network-exploitable | Attacker data reaches dangerous sink | Fix required |
| Locally exploitable | Local data reaches dangerous sink | Hardening (lower priority) |
| Safe pattern match | Grep hit but data is clean or sink is safe | Document and skip |

**Output**: Table of related patterns with exploitability classification.

### Phase 6: Write the Verification Report

**Goal**: Produce a self-contained document that proves the fix works.

#### Report template

```markdown
# Verification Report: [TICKET-ID]

**Vulnerability:** [One-line summary]
**Commit:** `[hash]` [commit subject]
**Date:** [YYYY-MM-DD]

## Vulnerability summary

[2-3 sentences: what the vulnerability is, how it's triggered, what the
impact is]

## Attack path

1. [Source] (e.g., "DHCP root-path option with payload")
2. [Transform 1] (e.g., "netroot.sh:57 sets netroot=$new_root_path")
3. ...
N. [Sink] (e.g., "dracut-initqueue.sh:37 sources the generated hook")

## Fix applied

[Description of the change with before/after code snippets]

## Verification

### Test N: [Test name]

```
[Actual command and output — copy-pasted, not described]
```

Result: **PASS/FAIL** -- [one-line explanation]

## Scope

- **Fixed:** [list of changed files]
- **Companion changes:** [any related changes needed]
- **Not changed:** [files reviewed but intentionally left alone, with reason]
```

### Report quality checklist

- [ ] Every claim has a file path and line number
- [ ] Every test shows actual command output, not "expected output"
- [ ] Functional equivalence tested for clean inputs
- [ ] End-to-end execution tested (not just string comparison)
- [ ] Scope section documents what was NOT changed and why
- [ ] Report is self-contained (readable without the vulnerability report)

## Red Flags

**Stop and reassess if:**
- The fix changes behavior for clean inputs (regression risk)
- The vulnerability report cites files that don't exist in your branch
- The proposed fix re-introduces a different injection (e.g., replacing `eval`
  with `printf -v` that creates globals instead of setting locals)
- The fix only covers one call site but the vulnerable pattern exists at
  multiple sites
- The data source claimed as "network-reachable" is actually from a trusted
  local source (fix may be unnecessary for production)

## Best Practices

1. **Fix at the earliest safe boundary.** Escaping at the writer is better than
   sanitizing at every consumer. But defense-in-depth (warning at consumer) is
   valuable when you don't control all writers.

2. **Don't fix what's not broken.** If data goes to a config file read by a
   parser (not sourced as shell), `printf '%q'` escaping would corrupt the
   data. Match the fix to the consumption context.

3. **Test under the actual shell.** If the code runs under bash, test under
   bash. `printf '%q'` behavior differs between bash, dash, and zsh.

4. **Clean up test artifacts.** Remove `/tmp/pwned`, `/tmp/test-*.sh`, etc.
   after verification.

5. **Companion changes are part of the fix.** If the fix changes how arguments
   are escaped, callers that relied on the old behavior (e.g., manual quote
   wrapping like `"'$var'"`) must be updated in the same commit.

## Version History

- **1.0.0** (2026-05-14): Initial version based on dracut initramfs DHCP
  injection fix verification workflow

## See Also

- **review** - Full code review workflow for broader analysis
- **sanity-check** - Quick pre-review scan for malicious intent
