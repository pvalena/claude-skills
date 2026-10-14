---
name: Bug Patterns
description: Catalog of recurring code-review bug patterns: language-neutral checks plus project-specific examples
author: pvalena
version: 1.0.0
tags: [code-review, bugs, patterns, security, correctness, reference]
---

# Bug Patterns Skill

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

## Language-Neutral Patterns

These are worth checking on any review, regardless of language.

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

## See Also

- **review** - Full code review workflow; consults this catalog in its "What to Look For"
  and verification passes.

## Version History

- **1.0.0** (2026-10-14): Initial version -- extracted from the `review` skill's "Common Bug
  Patterns" section into a standalone, growable catalog (7 language-neutral patterns + GRUB/C
  project-specific examples).
