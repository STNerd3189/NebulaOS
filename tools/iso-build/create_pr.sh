#!/usr/bin/env bash
set -euo pipefail

# create_pr.sh - helper to open a pull request from this branch into the repo's default branch
# Requires GitHub CLI (gh) configured and authenticated locally.
# Usage: ./create_pr.sh --title "My PR title" --body "PR body"

TITLE="Add hybrid BIOS+UEFI ISO build tools (Arch flow, Docker, Secure Boot helpers)"
BODY="Adds tools/iso-build with scripts to build a hybrid BIOS+UEFI ISO, an Arch/pacstrap flow, Docker container wrapper, and Secure Boot signing helpers."
HEAD_BRANCH="iso/hybrid-build-scripts"

# Determine default branch via gh
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

if [ -z "$DEFAULT_BRANCH" ]; then
  echo "Could not determine default branch. Please specify base branch manually or run gh repo view with authentication."; exit 1
fi

gh pr create --base "$DEFAULT_BRANCH" --head "$HEAD_BRANCH" --title "$TITLE" --body "$BODY" || {
  echo "gh pr create failed. You can run the above command manually after authenticating gh." ; exit 1
}

echo "PR created against $DEFAULT_BRANCH from $HEAD_BRANCH"
