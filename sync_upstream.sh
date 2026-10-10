#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2024-2025 Pagefault Games
#
# SPDX-License-Identifier: AGPL-3.0-only

# Sync this fork with pagefaultgames/pokerogue:
#   1. Fetch `upstream` and `origin`
#   2. Merge upstream/beta and upstream/main into the local beta/main and push them to `origin`
#   3. Rebase your working branch on top of the updated base branch and force-push it
#   4. Update submodules and reinstall packages for the final branch
#
# Usage: ./sync_upstream.sh [branch] [--base <beta|main>] [--no-push]
#   branch     branch holding your commits (default: nix-local-stuff)
#   --base     branch to rebase onto (default: beta)
#   --no-push  only update local branches, don't push anything to origin
#
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
    -h|--help) sed -n '6,17p' "$0"; exit 0 ;;
    *) BRANCH="$1"; shift ;;
  esac
done

cd "$(dirname "$0")"

# Lefthook runs `pnpm i` on every checkout/merge; skip that and install once at the end instead.
export LEFTHOOK=0

info() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\n\033[1;33m!! %s\033[0m\n' "$*" >&2; }
fail() { printf '\n\033[1;31m!! %s\033[0m\n' "$*" >&2; exit 1; }

git remote get-url upstream >/dev/null 2>&1 || fail "No 'upstream' remote. Add it with: git remote add upstream https://github.com/pagefaultgames/pokerogue.git"

if ! git diff --quiet --ignore-submodules || ! git diff --cached --quiet --ignore-submodules; then
  fail "You have uncommitted changes. Commit or stash them first (git stash -u)."
fi

info "Fetching upstream and origin"
git fetch upstream --prune
git fetch origin --prune

current_branch() { git symbolic-ref --quiet --short HEAD || true; }

for b in "${SYNC_BRANCHES[@]}"; do
  info "Updating $b from upstream/$b"
  if ! git show-ref --verify --quiet "refs/heads/$b"; then
    git branch "$b" "upstream/$b"
  elif git merge-base --is-ancestor "upstream/$b" "$b"; then
    echo "Already up to date."
  elif git merge-base --is-ancestor "$b" "upstream/$b" && [[ "$(current_branch)" != "$b" ]]; then
    # Fast-forward without checking the branch out
    git branch -f "$b" "upstream/$b"
    echo "Fast-forwarded to upstream/$b."
  else
    # $b has its own commits: a real merge is needed
    git checkout --quiet "$b"
    if ! git merge --no-edit "upstream/$b"; then
      fail "Merge conflict on $b. Fix the files, then 'git add' + 'git commit', and re-run this script (or 'git merge --abort' to undo)."
    fi
  fi

  if [[ $PUSH -eq 1 ]]; then
    git push origin "$b"
  fi
done

info "Rebasing $BRANCH onto $BASE"
git checkout --quiet "$BRANCH"
if ! git rebase "$BASE"; then
  fail "Rebase conflict. Fix the files, 'git add' them, then 'git rebase --continue' (or 'git rebase --abort' to undo). Then run: git submodule update --init && pnpm i && git push --force-with-lease origin $BRANCH"
fi

if [[ $PUSH -eq 1 ]]; then
  info "Pushing $BRANCH to origin"
  git push --force-with-lease origin "$BRANCH"
fi

info "Updating submodules and packages"
git submodule update --init --recursive
if ! pnpm install; then
  warn "pnpm install failed. Close the game/dev server/editor and run 'pnpm i' again."
fi

info "Done. $BRANCH is now on top of $BASE:"
git log --oneline --graph -n 10
