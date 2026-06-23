#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="$HOME/.agents/skills"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$REPO_DIR/skills.manifest"
SUBMODULE_DIR="$REPO_DIR/external"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "[DRY RUN] No changes will be made."
  echo
fi

die() { echo -e "${RED}ERROR:${NC} $1" >&2; exit 1; }
warn() { echo -e "${YELLOW}WARN:${NC} $1" >&2; }
info() { echo -e "${GREEN}→${NC} $1"; }

need_pull=false

# ── 1. Pull submodules ──────────────────────────────────────────────
info "Pulling submodule updates..."
cd "$REPO_DIR"

for sub in "$SUBMODULE_DIR"/*/; do
  [[ -d "$sub" ]] || continue
  name="$(basename "$sub")"
  if [[ ! -f "$sub/.git" ]] && [[ ! -d "$sub/.git" ]]; then
    warn "$name is not a git checkout, skipping pull"
    continue
  fi
  if $DRY_RUN; then
    info "[dry-run] would pull $name"
  else
    cd "$sub"
    git fetch origin
    git checkout "$(git rev-parse --abbrev-ref HEAD)" 2>/dev/null || true
    git merge --ff-only "origin/$(git rev-parse --abbrev-ref HEAD)" || {
      warn "$name: fast-forward failed (you may have local changes). Skipping."
    }
    cd "$REPO_DIR"
    need_pull=true
  fi
done

if $need_pull; then
  info "Submodules updated. Run 'git add external/ && git commit -m \"Update submodule pins\"' to pin the new SHAs."
fi

# ── 2. Read manifest and sync symlinks ───────────────────────────────
info "Syncing symlinks from $MANIFEST..."
mkdir -p "$SKILLS_DIR"

created=0
skipped=0
errors=0

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  [[ -z "${line// }" ]] && continue

  parts=($line)
  if [[ ${#parts[@]} -lt 2 ]]; then
    warn "Malformed manifest line: $line"
    ((errors++)) || true
    continue
  fi

  entry="${parts[0]}"
  target_name="${parts[1]}"

  remote="${entry%%:*}"
  source_path="${entry#*:}"

  if [[ "$remote" == "$entry" ]] || [[ -z "$source_path" ]]; then
    warn "Malformed entry (expected remote:path): $entry"
    ((errors++)) || true
    continue
  fi

  source_abs="$SUBMODULE_DIR/$remote/$source_path"
  target_abs="$SKILLS_DIR/$target_name"

  if [[ ! -d "$source_abs" ]]; then
    warn "Source does not exist: $source_abs — skill may have moved upstream"
    ((errors++)) || true
    continue
  fi

  if [[ -d "$target_abs" ]] && [[ ! -L "$target_abs" ]]; then
    warn "$target_abs exists and is a real directory, NOT a symlink. Refusing to clobber."
    warn "  Remove it manually first if you want to replace it: rm -rf $target_abs"
    ((skipped++)) || true
    continue
  fi

  # Compute relative path from ~/.agents/skills/ to source
  rel="$(python3 -c "import os; print(os.path.relpath('$source_abs', '$SKILLS_DIR'))")"

  if $DRY_RUN; then
    if [[ -L "$target_abs" ]]; then
      current="$(readlink "$target_abs")"
      if [[ "$current" == "$rel" ]]; then
        info "[dry-run] $target_name → $rel  (unchanged)"
      else
        info "[dry-run] $target_name → $rel  (was $current)"
      fi
    else
      info "[dry-run] $target_name → $rel  (new)"
    fi
  else
    if [[ -L "$target_abs" ]] || [[ -e "$target_abs" ]]; then
      rm -f "$target_abs"
    fi
    ln -s "$rel" "$target_abs"
    info "$target_name → $rel"
  fi
  ((created++)) || true
done < "$MANIFEST"

echo
echo "Done.  created=$created  skipped=$skipped  errors=$errors"

if $DRY_RUN; then
  echo "Run without --dry-run to apply changes."
elif [[ $created -gt 0 ]]; then
  echo
  echo "Active symlinks in $SKILLS_DIR:"
  for link in "$SKILLS_DIR"/*/; do
    name="$(basename "$link")"
    if [[ -L "$link" ]]; then
      target="$(readlink "$link")"
      echo "  $name → $target"
    fi
  done
fi
