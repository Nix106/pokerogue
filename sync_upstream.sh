#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2024-2025 Pagefault Games
#
# SPDX-License-Identifier: AGPL-3.0-only

# Sync this fork with pagefaultgames/pokerogue:
#   1. Fetch `upstream` and `origin`
#   2. Mirror upstream/beta and upstream/main 1:1 onto the local beta/main and force-push them to `origin`
#   3. Replay ONLY your own commits on top of the updated base branch (your side wins conflicts) and force-push
#   4. Update submodules and reinstall packages
#
# Usage: ./sync_upstream.sh [branch] [--base <beta|main>] [--no-push]
#   branch     branch holding your commits (default: nix-local-stuff)
#   --base     branch to rebase onto (default: beta)
#   --no-push  only update local branches, don't push anything to origin
#
# Your commits are found via the base recorded in `git config sync.lastbase.<branch>`
# (the upstream commit the branch was last rebased onto), so upstream history never gets replayed.
# Close the game / dev server / editor first, or `pnpm install` may fail with EPERM on Windows.

set -euo pipefail

BRANCH="nix-local-stuff"
BASE="beta"
PUSH=1
SYNC_BRANCHES=(beta main)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base) BASE="$2"; shift 2 ;;
    --no-push) PUSH=0; shift ;;
    -h|--help) sed -n '6,19p' "$0"; exit 0 ;;
    *) BRANCH="$1"; shift ;;
  esac
done

cd "$(dirname "$0")"

# Lefthook runs `pnpm i` on every checkout/merge; skip that and install once at the end instead.
export LEFTHOOK=0
export GIT_EDITOR=true

info() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\n\033[1;33m!! %s\033[0m\n' "$*" >&2; }
fail() { printf '\n\033[1;31m!! %s\033[0m\n' "$*" >&2; exit 1; }

git remote get-url upstream >/dev/null 2>&1 || fail "No 'upstream' remote. Add it with: git remote add upstream https://github.com/pagefaultgames/pokerogue.git"
git show-ref --verify --quiet "refs/heads/$BRANCH" || fail "Branch '$BRANCH' doesn't exist."

if [[ -d .git/rebase-merge || -d .git/rebase-apply ]]; then
  fail "A rebase is already in progress. Finish it ('git rebase --continue') or abort it ('git rebase --abort') first."
fi

if ! git diff --quiet --ignore-submodules || ! git diff --cached --quiet --ignore-submodules; then
  fail "You have uncommitted changes. Commit or stash them first (git stash -u)."
fi

info "Fetching upstream and origin"
git fetch upstream --prune
git fetch origin --prune

# Never sit on a mirrored branch, so it can be moved freely
git checkout --quiet "$BRANCH"

for b in "${SYNC_BRANCHES[@]}"; do
  info "Mirroring upstream/$b -> $b"
  git branch -f "$b" "upstream/$b"
  if [[ $PUSH -eq 1 ]]; then
    git push --force-with-lease origin "$b"
  fi
done

info "Replaying your commits from $BRANCH onto $BASE"
NEW_BASE="$(git rev-parse "upstream/$BASE")"
OLD_BASE="$(git config --get "sync.lastbase.$BRANCH" || true)"
if [[ -z "$OLD_BASE" ]] || ! git merge-base --is-ancestor "$OLD_BASE" "$BRANCH" 2>/dev/null; then
  OLD_BASE="$(git merge-base "$BRANCH" "upstream/$BASE")"
  warn "No usable recorded base; falling back to merge-base ${OLD_BASE:0:12}"
fi

echo "Your commits:"
git log --oneline "$OLD_BASE..$BRANCH"

# In a rebase, '-X theirs' means YOUR commits win conflicts
if ! git rebase -X theirs --onto "$NEW_BASE" "$OLD_BASE" "$BRANCH"; then
  fail "Rebase conflict (binary/deleted files can still conflict). Fix them, 'git add', 'git rebase --continue', then: git config sync.lastbase.$BRANCH $NEW_BASE && git push --force-with-lease origin $BRANCH && git submodule update --init && pnpm i"
fi
git config "sync.lastbase.$BRANCH" "$NEW_BASE"

if [[ $PUSH -eq 1 ]]; then
  info "Pushing $BRANCH to origin"
  git push --force-with-lease origin "$BRANCH"
fi

info "Updating submodules and packages"
git submodule update --init --recursive
if ! pnpm install; then
  warn "pnpm install failed. Close the game/dev server/editor and run 'pnpm i' again."
fi

info "Done. $BRANCH is now on top of upstream/$BASE:"
git log --oneline --graph -n 10
