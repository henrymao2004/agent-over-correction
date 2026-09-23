#!/usr/bin/env bash
# Publish site/ to the public gallery remote listed in site/.publish-remote
# (gitignored). Packed traces stay with the website.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REMOTE_FILE="$ROOT/site/.publish-remote"
if [ ! -f "$REMOTE_FILE" ]; then
  echo "Create site/.publish-remote with the gallery git remote URL." >&2
  exit 1
fi
REMOTE="$(sed -e 's/[[:space:]]*$//' -e '/^#/d' -e '/^$/d' "$REMOTE_FILE" | head -1)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --depth 1 "$REMOTE" "$TMP"
rsync -a --delete \
  --exclude '.git' \
  --exclude '.DS_Store' \
  --exclude 'publish.sh' \
  --exclude '.publish-remote' \
  "$ROOT/site/" "$TMP/"
if [ -f "$ROOT/LICENSE" ]; then cp "$ROOT/LICENSE" "$TMP/LICENSE"; fi
if [ -f "$ROOT/NOTICE" ]; then cp "$ROOT/NOTICE" "$TMP/NOTICE"; fi
cd "$TMP"
git add -A
if git diff --cached --quiet; then
  echo "No gallery changes to publish."
  exit 0
fi
git commit -m "Publish gallery from site/"
git push
echo "Published."
