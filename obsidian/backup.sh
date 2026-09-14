#!/bin/bash
# Bundled in Obsidian Backup.app. Keep compatible with Apple's Bash 3.2.
set -uo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

readonly ICLOUD="${OBSIDIAN_BACKUP_ICLOUD:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents}"
readonly BASE="${OBSIDIAN_BACKUP_BASE:-$HOME/.obsidian-backup}"
readonly REPO="$BASE/repo"
readonly LOG="$BASE/backup.log"
readonly -a EXCLUDES=(
  --exclude '.DS_Store'
  --exclude '*.icloud'
  --exclude '.trash'
  --exclude '.git'
  --exclude '.obsidian/workspace.json'
  --exclude '.obsidian/workspace-mobile.json'
  --exclude '.obsidian/cache'
)

log() {
  printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"
}

die() {
  log "FATAL: $*"
  exit 1
}

cleanup() {
  local status=$?
  if [[ -d "$stage/previous" ]]; then
    log "Previous snapshot retained at $stage/previous"
  else
    rm -rf "$stage"
  fi
  tail -n 2000 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
  exit "$status"
}

discover_vaults() {
  local vault
  if ! find "$ICLOUD" -mindepth 2 -maxdepth 2 -type d -name .obsidian -print0 \
    > "$stage/discovered" 2>> "$LOG"; then
    die 'Cannot enumerate iCloud vaults. Enable Full Disk Access for Obsidian Backup.app.'
  fi

  while IFS= read -r -d '' vault; do
    case "$vault" in
      *$'\n'*) die 'Vault paths cannot contain newlines' ;;
    esac
    printf '%s\n' "${vault%/.obsidian}"
  done < "$stage/discovered"

  if [[ -f "$BASE/vaults.conf" ]]; then
    while IFS= read -r vault || [[ -n "$vault" ]]; do
      case "$vault" in
        ''|\#*) continue ;;
      esac
      vault="${vault/#\~/$HOME}"
      [[ -d "$vault/.obsidian" ]] || die "Configured vault is unavailable: $vault"
      printf '%s\n' "${vault%/}"
    done < "$BASE/vaults.conf"
  fi
}

validate_vault_names() {
  local vault name key
  : > "$stage/names"
  while IFS= read -r vault; do
    name=$(basename "$vault")
    key=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')
    case "$key" in
      .*|readme.md) die "Reserved vault name: $name" ;;
    esac
    if grep -Fqx -- "$key" "$stage/names"; then
      die "Duplicate vault name: $name"
    fi
    printf '%s\n' "$key" >> "$stage/names"
  done < "$stage/vaults"
}

sync_vault() {
  local vault=$1 name=$2 incoming live tracked
  incoming="$stage/incoming/$name"

  if ! find "$vault" -name '.trash' -prune -o -path '*/.obsidian/cache' -prune -o \
    -name '*.icloud' -print > "$stage/placeholders" 2>> "$LOG"; then
    log "ERROR [$name]: cannot enumerate vault files"
    return 1
  fi
  if [[ -s "$stage/placeholders" ]]; then
    log "ABORT [$name]: iCloud placeholders found; download the vault before backing up"
    return 1
  fi
  mkdir -p "$incoming" || die "Cannot prepare snapshot for $name"
  if ! rsync -a "${EXCLUDES[@]}" "$vault/" "$incoming/" 2>> "$LOG"; then
    log "ERROR [$name]: rsync into staging directory failed"
    return 1
  fi

  live=$(find "$incoming" -type f | wc -l | tr -d ' ') || die "Cannot count snapshot files for $name"
  tracked=$(git -C "$REPO" ls-files -- "$name" | wc -l | tr -d ' ') || die "Cannot count tracked files for $name"
  if (( tracked > 0 && live < tracked * 9 / 10 && tracked - live > 20 )); then
    log "ABORT [$name]: snapshot has $live files, repo tracks $tracked; refusing mass deletion"
    return 1
  fi

  # Keep the previous copy recoverable if replacement is interrupted.
  if [[ -e "$REPO/$name" ]]; then
    mv "$REPO/$name" "$stage/previous" || die "Cannot preserve previous snapshot for $name"
  fi
  if ! mv "$incoming" "$REPO/$name"; then
    if [[ -d "$stage/previous" ]]; then
      mv "$stage/previous" "$REPO/$name"
    fi
    die "Cannot install snapshot for $name"
  fi
  rm -rf "$stage/previous"
}

commit_snapshot() {
  local added modified deleted touched scope summary=''
  if ! git -C "$REPO" add -f -A 2>> "$LOG"; then
    log 'git: STAGING FAILED'
    return 1
  fi
  if git -C "$REPO" diff --cached --quiet; then
    log 'git: no changes'
    return 0
  fi

  added=$(git -C "$REPO" diff --cached --diff-filter=A --name-only | wc -l | tr -d ' ') || return 1
  modified=$(git -C "$REPO" diff --cached --diff-filter=M --name-only | wc -l | tr -d ' ') || return 1
  deleted=$(git -C "$REPO" diff --cached --diff-filter=D --name-only | wc -l | tr -d ' ') || return 1
  touched=$(git -C "$REPO" diff --cached --name-only | cut -d/ -f1 | sort -u) || return 1
  case "$touched" in
    *$'\n'*) scope='vaults' ;;
    *) scope=$(printf '%s' "$touched" | tr '[:upper:] ' '[:lower:]-') ;;
  esac
  (( added > 0 )) && summary="$added added"
  (( modified > 0 )) && summary="${summary:+$summary, }$modified modified"
  (( deleted > 0 )) && summary="${summary:+$summary, }$deleted deleted"

  if ! git -C "$REPO" commit -q -m "chore($scope): $summary" 2>> "$LOG"; then
    log 'git: COMMIT FAILED'
    return 1
  fi
  log "git: committed — chore($scope): $summary"
}

push_snapshot() {
  if ! git -C "$REPO" push -q origin main 2>> "$LOG"; then
    log 'git: PUSH FAILED'
    return 1
  fi
  log 'git: pushed'
}

mirror_dropbox() {
  local dropbox='' candidate name destination failed=0
  for candidate in "${OBSIDIAN_BACKUP_DROPBOX:-$HOME/Dropbox}" \
    "$HOME/Library/CloudStorage/Dropbox" "$HOME/Dropbox (Personal)"; do
    if [[ -d "$candidate" ]]; then
      dropbox=$candidate
      break
    fi
  done
  if [[ -z "$dropbox" ]]; then
    log 'dropbox: FAILED — no Dropbox folder found'
    return 1
  fi

  while IFS= read -r name; do
    destination="$dropbox/Backups/Obsidian/$name"
    if ! mkdir -p "$destination" 2>> "$LOG"; then
      log "dropbox [$name]: cannot create destination"
      failed=1
    elif rsync -a --delete \
      --exclude '.DS_Store' --exclude '*.icloud' \
      "$REPO/$name/" "$destination/" 2>> "$LOG"; then
      log "dropbox [$name]: mirrored"
    else
      log "dropbox [$name]: RSYNC FAILED"
      failed=1
    fi
  done < "$stage/synced"

  return "$failed"
}

main() {
  local leftover vault name failed=0
  mkdir -p "$BASE" || exit 1
  [[ -d "$REPO/.git" ]] || die 'Work repo missing — run enable.sh'
  [[ -r "$ICLOUD" ]] || die 'Cannot read iCloud. Enable Full Disk Access for Obsidian Backup.app.'
  for leftover in "$BASE"/.snapshot.*; do
    [[ ! -d "$leftover/previous" ]] || die "Interrupted snapshot retained at $leftover; recover it before running again"
  done

  stage=$(mktemp -d "$BASE/.snapshot.XXXXXX") || die 'Cannot create staging directory'
  trap 'cleanup' EXIT
  discover_vaults > "$stage/vaults"
  [[ -s "$stage/vaults" ]] || die 'No vaults found'
  validate_vault_names

  : > "$stage/synced"
  while IFS= read -r vault; do
    name=$(basename "$vault")
    if sync_vault "$vault" "$name"; then
      printf '%s\n' "$name" >> "$stage/synced"
    else
      failed=1
    fi
  done < "$stage/vaults"
  [[ -s "$stage/synced" ]] || die 'Nothing synced; stopping before commit'

  # Attempt both destinations even if one fails.
  commit_snapshot || failed=1
  push_snapshot || failed=1
  mirror_dropbox || failed=1
  if (( failed == 0 )); then
    date '+%Y-%m-%d %H:%M:%S %z' > "$BASE/last-success"
  fi
  return "$failed"
}

main "$@"
