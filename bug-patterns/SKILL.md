---
name: Bug Patterns
description: Catalog of recurring code-review bug patterns: language-neutral checks plus project-specific examples
author: pvalena
version: 1.1.0
tags: [code-review, bugs, patterns, security, correctness, reference, experimental]
---

# Bug Patterns Skill

> **Status: experimental (new).** This catalog is young: the vetted entries are few, the candidate
> list near the end is unvetted, and it will expand as real reviews feed it back. Treat every entry
> as a prompt to look, not a confirmed finding.

**Purpose**: A growing reference catalog of recurring bug patterns to check during code or
security review. Language-neutral patterns apply to any review; the project-specific section
holds API-contract examples that illustrate the *shape* of such bugs and are meant to be
replaced with the idioms of the code you actually review. This is a lookup list, not a
workflow -- the `review`, `sanity-check`, and `verify-fix` skills drive the process; this
skill is what they consult.

## When to Use

- During a review's read-and-verify passes, as a checklist of things that commonly go wrong
  (e.g. the `review` skill's "What to Look For" step and its Verify/Double-Check passes).
- When triaging a diff for likely-defect hot spots (`sanity-check`, `verify-fix`).
- As the place to record a new pattern after a review surfaces one worth reusing.

## Workflow

Use this as a reference alongside a review workflow, not as a standalone procedure:

1. While reading the changed source, scan for each language-neutral pattern below.
2. A pattern is a *prompt to look*, never a finding on its own -- confirm it against the
   actual code before reporting it (see the `review` skill's zero-false-positive rule).
3. Swap the project-specific examples for the error-handling/parsing idioms of the code you
   actually review; add new entries here as you discover them, so the catalog grows.

## Adding an entry

This catalog grows from real reviews. When a review surfaces a reusable pattern, add it under the
right section using this shape (keep it a few lines; the full analysis belongs in the review's
reasoning file):

- **Name** — a short, searchable label.
- **Smell** — what draws attention in the diff or source.
- **Why it's a bug** — the concrete consequence.
- **Confirm** — how to tell a real hit from a false positive (what to read to be sure).
- **Fix / generalize** — the typical fix, and the language-neutral lesson behind it.

Record only patterns you **actually hit** -- don't invent them (that is what the draft "Candidate
Patterns" section is for). Once a section grows long, group its entries by category (memory,
control-flow, types, error-handling, concurrency, injection, docs).

## Language-Neutral Patterns

Vetted patterns drawn from real reviews; worth checking on any review, regardless of language.

**Resource leak (FILE stream):**
```
fdopen(fd, "r") opens a FILE stream. If fclose(fp) is never called, both the
FILE stream buffer and the underlying fd leak. Check every fdopen has a matching
fclose on all return paths.
```

**Error/success conflation:**
```
Function returns errno (non-zero) on error and 1 on success. Caller tests
`if (ret)` treating both as the same condition. Error silently treated as
success. Check return value semantics match caller expectations.
```

**Dead code from branch ordering:**
```
Shell case statement: x*) matches before x), making x) unreachable. In C:
default case before specific cases. Check that more specific patterns precede
wildcards/defaults.
```

**Mutation of storage owned by an accessor:**
```
An accessor returns a pointer into internal/shared storage (often const char *).
Code that casts away const and mutates through the pointer corrupts that storage.
Even "temporary" mutations (*ext = '\0'; ...; *ext = '.';) are UB and fragile.
Fix: copy before mutation (e.g. strdup), free the copy after use.
(GRUB example: grub_env_get() returns internal environment-table storage.)
```

**Platform-dependent type sizes:**
```
sizeof(long) is 4 on 32-bit, 8 on 64-bit. If a spec defines a field as 64-bit,
using long is correct only on 64-bit. Confirm which platforms a module actually
builds for before assuming a width -- a build config may include 32-bit targets.
Use fixed-width types (e.g. uint64_t) for spec-defined sizes.
```

**Documentation/code mismatch:**
```
Docs describe one delimiter/format/behavior, code implements another. Users
following docs get broken results. Cross-reference documentation against actual
parsing code.
```

**Dead code from guard conditions:**
```
Guard condition guarantees a value (e.g., !ptr means ptr is NULL). Code inside
the guard operates on that value redundantly (e.g., free(ptr) where ptr is
always NULL). Check what the guard condition guarantees about variables inside
the block.
```

## Common False Positives

The flip side of the catalog -- things that look like a listed pattern but are not. Check these
before reporting (also drawn from real reviews):

**Double-free that isn't:** a `ptr = NULL` between the two frees makes the second free a no-op.
**NULL deref that isn't:** a guard earlier in the function already ensures the pointer is non-NULL.
**Resource leak / bad fd test:** `fd = open(...); if (!fd) return;` -- fd 0 is a *valid* descriptor,
so `!fd` is the wrong test (use `fd < 0`). The defect is the check, not a leak.

## Project-Specific Patterns (GRUB/C examples -- replace with your project's)

These illustrate the *shape* of API-contract bugs, not a fixed checklist. Swap in
the error-handling and parsing idioms of the code you actually review.

**Wrong error check for a parse API (grub_strtol/grub_strtoull):**
```
grub_strtol() never sets *endp to NULL. On parse failure, *endp points into the
string and grub_errno is set, so "if (endp != NULL)" is always true. The correct
check is "if (grub_errno == GRUB_ERR_NONE)". Generalize: verify a parser's actual
failure signal, not an assumed one.
```

**Leaked global error state (grub_errno):**
```
grub_errno is a global that persists until cleared. If a "non-fatal" operation
fails and sets grub_errno but the function returns GRUB_ERR_NONE, a later
grub_print_error() prints a spurious message. Clear the global after
intentionally-ignored failures. Generalize: any global/thread-local error state
(errno, GetLastError) leaks across best-effort calls if not reset.
```

## Candidate Patterns (draft -- not yet battle-tested)

**These are category placeholders, not vetted entries.** They name common bug classes worth adding
*once we actually hit one* and can describe it from a real case -- do not treat them as findings, and
do not copy their names into a review. Promote a candidate into the sections above (as a full entry
per "Adding an entry") when a real review surfaces it; until then they only mark intended coverage.
**Needs real-world feedback.**

- Integer overflow / wraparound in size or index math (e.g. `n * size` allocations).
- Off-by-one / loop- and buffer-bound errors.
- Use-after-free and double-free (beyond the false-positive note above).
- Signedness bugs (signed/unsigned comparison; a negative value flowing into a `size_t`).
- Use of uninitialized memory or variables.
- Missing NULL check after allocation, before dereference.
- Injection: untrusted input reaching a sink (command, SQL, path traversal, format string).
- TOCTOU / races on shared or filesystem state.

## See Also

- **review** - Full code review workflow; consults this catalog in its "What to Look For"
  and verification passes.

## Version History

- **1.1.0** (2026-10-14): Added an "Adding an entry" template (+ grow-by-category guidance), a
  "Common False Positives" section (folded from `review`), and a clearly-separated draft "Candidate
  Patterns" list (category placeholders, unvetted). Marked the skill experimental.
- **1.0.0** (2026-10-14): Initial version -- extracted from the `review` skill's "Common Bug
  Patterns" section into a standalone, growable catalog (7 language-neutral patterns + GRUB/C
  project-specific examples).
