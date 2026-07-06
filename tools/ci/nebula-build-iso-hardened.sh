#!/usr/bin/env bash
set -euo pipefail
# nebula-build-iso-hardened.sh
# Hardened wrapper that runs on the self-hosted runner via sudo.
# - Only allows builds from approved refs (configurable).
# - Verifies the checked-out commit matches origin to avoid building unpushed local changes.
# - Optionally enforces signed-tag verification if /etc/nebula-build-signing-key.pub exists.
# - Calls /usr/local/bin/nebula-build-iso.sh (the secure build wrapper).
#
# Install:
# - Copy this file to /usr/local/bin/nebula-build-iso-hardened.sh
# - chmod 0750 /usr/local/bin/nebula-build-iso-hardened.sh
# - chown root:root /usr/local/bin/nebula-build-iso-hardened.sh
# - Add sudoers entry to allow the runner user to execute it:
#     actions-runner ALL=(ALL) NOPASSWD: /usr/local/bin/nebula-build-iso-hardened.sh
#
# Allowed refs:
# - By default this script allows:
#     refs/heads/main
#     refs/heads/release/*
#     refs/tags/*
# - To override, create /etc/nebula-build-allowed with one glob per line (git ref patterns)

LOGDIR="/var/log"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG="$LOGDIR/nebula-build-hardened-$TIMESTAMP.log"
echo "[hardened-build] Starting at $(date)" | tee -a "$LOG"

GITHUB_WS="${GITHUB_WORKSPACE:-}"
if [ -z "$GITHUB_WS" ]; then
  echo "[hardened-build] ERROR: GITHUB_WORKSPACE is not set. Aborting." | tee -a "$LOG"
  exit 2
fi

cd "$GITHUB_WS"

# Determine Git ref (GITHUB_REF is provided by Actions). Fall back to HEAD symbolic ref.
G_REF="${GITHUB_REF:-$(git symbolic-ref -q HEAD || git rev-parse --short HEAD)}"
echo "[hardened-build] GITHUB_REF = ${G_REF}" | tee -a "$LOG"

# Load allowed patterns
ALLOWED_FILE="/etc/nebula-build-allowed"
if [ -f "$ALLOWED_FILE" ]; then
  MAPFILE=()
  while IFS= read -r line; do
    case "$line" in
      ''|\#*) continue ;;
      *) MAPFILE+=("$line") ;;
    esac
  done < "$ALLOWED_FILE"
else
  # default allowed patterns
  MAPFILE=("refs/heads/main" "refs/heads/release/*" "refs/tags/*")
fi

# Function to test glob match
matches_allowed() {
  local ref="$1"
  for pat in "${MAPFILE[@]}"; do
    if [[ "$ref" == $pat ]]; then
      return 0
    fi
  done
  return 1
}

if ! matches_allowed "$G_REF"; then
  echo "[hardened-build] ERROR: ref '$G_REF' not allowed by policy." | tee -a "$LOG"
  echo "[hardened-build] Allowed patterns:" | tee -a "$LOG"
  printf '%s\n' "${MAPFILE[@]}" | tee -a "$LOG"
  exit 3
fi

# Verify the commit exists on origin to avoid building arbitrary local commits
CURRENT_COMMIT="$(git rev-parse --verify HEAD)"
echo "[hardened-build] Current commit: $CURRENT_COMMIT" | tee -a "$LOG"

# Ensure origin URL is present; fallback to GITHUB_SERVER_URL/GITHUB_REPOSITORY if set
if git remote get-url origin >/dev/null 2>&1; then
  :
else
  if [ -n "${GITHUB_SERVER_URL:-}" ] && [ -n "${GITHUB_REPOSITORY:-}" ]; then
    git remote add origin "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}" || true
  fi
fi

# Fetch remote refs (shallow) for verification
git fetch --no-tags --depth=1 origin "+refs/heads/*:refs/remotes/origin/*" || {
  echo "[hardened-build] WARNING: git fetch failed; cannot verify commit on origin. Aborting." | tee -a "$LOG"
  exit 4
}

if git branch -r --contains "$CURRENT_COMMIT" | grep -q .; then
  echo "[hardened-build] Commit found on remote branches." | tee -a "$LOG"
else
  # allow tags that point at this commit
  if git tag --points-at "$CURRENT_COMMIT" | grep -q .; then
    echo "[hardened-build] Commit is pointed-to by a tag on local checkout; verifying remote tags..." | tee -a "$LOG"
    git fetch --tags origin || true
    if git ls-remote --tags origin | grep -q "$CURRENT_COMMIT"; then
      echo "[hardened-build] Commit exists as remote tag." | tee -a "$LOG"
    else
      echo "[hardened-build] ERROR: Commit not present on origin branches or tags. Aborting." | tee -a "$LOG"
      exit 5
    fi
  else
    echo "[hardened-build] ERROR: Commit not present on origin branches or tags. Aborting." | tee -a "$LOG"
    exit 5
  fi
fi

# Optional: enforce signed-tag verification if a public key is installed
if [ -f /etc/nebula-build-signing-key.pub ]; then
  echo "[hardened-build] Signing key detected; enforcing signed-tag verification." | tee -a "$LOG"
  if ! command -v gpg >/dev/null 2>&1; then
    echo "[hardened-build] ERROR: gpg not installed on runner. Install gnupg and retry." | tee -a "$LOG"
    exit 6
  fi
  GNUPGHOME="$(mktemp -d)"
  export GNUPGHOME
  gpg --import /etc/nebula-build-signing-key.pub >/dev/null 2>&1 || {
    echo "[hardened-build] ERROR: failed to import signing key" | tee -a "$LOG"
    rm -rf "$GNUPGHOME"
    exit 7
  }
  # If ref is a tag, verify that tag is a valid signed tag
  if [[ "$G_REF" == refs/tags/* ]]; then
    tag="${G_REF#refs/tags/}"
    echo "[hardened-build] Verifying signed tag: $tag" | tee -a "$LOG"
    if git verify-tag "$tag" >/dev/null 2>&1; then
      echo "[hardened-build] Tag verification succeeded." | tee -a "$LOG"
    else
      echo "[hardened-build] ERROR: Tag signature verification failed for $tag" | tee -a "$LOG"
      rm -rf "$GNUPGHOME"
      exit 8
    fi
  else
    # For branch/commit builds require that a signed tag points to the same commit
    tags=$(git tag --points-at "$CURRENT_COMMIT" || true)
    if [ -n "$tags" ]; then
      ok=0
      for t in $tags; do
        if git verify-tag "$t" >/dev/null 2>&1; then
          ok=1
          echo "[hardened-build] Found signed tag $t pointing to commit." | tee -a "$LOG"
          break
        fi
      done
      if [ "$ok" -ne 1 ]; then
        echo "[hardened-build] ERROR: No signed tags pointing to the current commit." | tee -a "$LOG"
        rm -rf "$GNUPGHOME"
        exit 9
      fi
    else
      echo "[hardened-build] ERROR: No tags point to the current commit; signed-tag policy requires a signed tag." | tee -a "$LOG"
      rm -rf "$GNUPGHOME"
      exit 10
    fi
  fi
  rm -rf "$GNUPGHOME"
fi

# Everything checks out. Call the normal wrapper to run the build.
if [ -x "/usr/local/bin/nebula-build-iso.sh" ]; then
  echo "[hardened-build] Invoking build wrapper..." | tee -a "$LOG"
  /usr/bin/env bash /usr/local/bin/nebula-build-iso.sh 2>&1 | tee -a "$LOG"
  echo "[hardened-build] Build wrapper finished." | tee -a "$LOG"
else
  echo "[hardened-build] ERROR: secure wrapper /usr/local/bin/nebula-build-iso.sh not found or not executable." | tee -a "$LOG"
  exit 6
fi

echo "[hardened-build] Completed at $(date)" | tee -a "$LOG"
exit 0
