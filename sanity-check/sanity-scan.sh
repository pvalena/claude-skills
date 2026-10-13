#!/usr/bin/env bash
# sanity-scan.sh -- standardized pre-review injection/payload scan over a PR range.
#
# Dumps the range's raw commit messages (%B) and diff to temp files, then returns
# ONLY the scan section headers + grep matches. The raw commit messages and diff
# never reach stdout, so a prompt-injection payload cannot enter the caller's (LLM)
# context before it has been scanned. This is the whole point of running it as one
# command -- see SKILL.md Step 1 and the "Scan before ingesting" principle.
#
# Usage: sanity-scan.sh <range> [repo]
#   <range>  git revision range for the PR, e.g. origin/master..prNN
#            (prNN branches) or <base-commit>..branch (historical branches).
#   [repo]   path to the git repo (default: $SANITY_REPO, else ./grub).
#
# Exit status is always 0 on a completed scan (no-match greps are not failures);
# a non-zero exit means the range/repo was unusable (evaluate that as suspicious).
set -u

range=${1:?usage: sanity-scan.sh <range> [repo]}
repo=${2:-${SANITY_REPO:-./grub}}

git -C "$repo" rev-parse --git-dir >/dev/null 2>&1 || {
  echo "sanity-scan: '$repo' is not a git repo" >&2; exit 2; }

# Validate the range resolves BEFORE scanning. Without this, a bad range would
# leave the temp files empty and the scan would print a clean "Scan complete"
# with exit 0 -- a false all-clear. An unresolvable range is a reason to stop.
git -C "$repo" rev-list -n1 "$range" >/dev/null 2>&1 || {
  echo "sanity-scan: cannot resolve range '$range' in '$repo'" >&2; exit 2; }

msg=$(mktemp) || exit 2
diff=$(mktemp) || { rm -f "$msg"; exit 2; }
trap 'rm -f "$msg" "$diff"' EXIT

# Dump raw content to temp files -- output suppressed, nothing returned to caller.
git -C "$repo" log  "$range" --format='%B' > "$msg"  2>/dev/null
git -C "$repo" diff "$range"               > "$diff" 2>/dev/null

# Surface an empty diff: a range with no changes is nothing to review, not a pass.
[[ -s "$diff" ]] || echo "=== NOTE: diff is empty for range '$range' ==="

echo "=== Prompt injection ==="
grep -inE \
  'ignore (previous|prior|above|all) instructions|you are now'\
'|new instructions|forget (everything|your|what)|act as'\
'|pretend (to be|you are)|do not (report|flag|mention)'\
'|disregard|override|system prompt'\
'|<\|im_start\|>|<\|endoftext\|>|\[INST\]|\[/INST\]'\
'|<<SYS>>|<s>|</s>' \
  "$msg" "$diff" || true

echo "=== Suspicious Unicode ==="
grep -Pn '[\x{200B}\x{200C}\x{200D}\x{200E}\x{200F}\x{202A}-\x{202E}\x{2060}\x{FEFF}]' \
  "$diff" || true

echo "=== HTML comments in non-HTML ==="
grep -n '<!--.*-->' "$diff" | grep -v '\.html\|\.xml\|\.svg' || true

echo "=== Base64 payloads ==="
grep -nE '[A-Za-z0-9+/]{40,}={0,2}' "$diff" || true

echo "=== Hex payloads ==="
grep -nE '(\\x[0-9a-fA-F]{2}){8,}' "$diff" || true

echo "=== eval/exec ==="
grep -nE 'eval\s*\(|exec\s*\(|system\s*\(|popen\s*\(|subprocess|os\.system' \
  "$diff" || true

echo "=== Encoded execution ==="
grep -nE 'base64\s*(--)?decode|atob\(|Buffer\.from\(' "$diff" || true

echo "=== New URLs/IPs ==="
grep -nE 'https?://[^ "'"'"']+|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' \
  "$diff" | grep '^+' || true

echo "=== Network calls ==="
grep -nE 'curl |wget |fetch\(|requests\.(get|post)|urllib|socket\.' \
  "$diff" | grep '^+' || true

echo "=== Credentials ==="
grep -nE 'password|passwd|secret|token|api.key|private.key|BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE' \
  "$diff" | grep '^+' || true

echo "=== Build/CI files changed ==="
git -C "$repo" diff --name-only "$range" 2>/dev/null | \
  grep -iE 'Makefile|CMake|configure|\.yml|\.yaml|\.sh|\.bash|requirements|package\.json|Cargo\.toml|go\.mod' \
  || true

echo "=== Post/pre hooks ==="
grep -nE 'postinstall|preinstall|prebuild|postbuild' "$diff" || true

echo "=== Scan complete ==="
