#!/bin/bash
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

SOURCE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly REPO=${1:?Usage: prepare-repo.sh REPO}

mkdir -p "$REPO"
cd "$REPO"
if [[ ! -d .git ]]; then
  git init -q -b main .
fi
if [[ $(git symbolic-ref --short HEAD) != main ]]; then
  printf '%s\n' 'Backup repo must be on main.' >&2
  exit 1
fi
if ! git diff --cached --quiet; then
  printf '%s\n' 'Resolve staged changes in the backup repo first.' >&2
  exit 1
fi

git lfs install --local
cat > .gitignore <<'IGNORE'
.DS_Store
*.icloud
IGNORE
cat > .gitattributes <<'ATTRIBUTES'
*.png  filter=lfs diff=lfs merge=lfs -text
*.jpg  filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.webp filter=lfs diff=lfs merge=lfs -text
*.pdf  filter=lfs diff=lfs merge=lfs -text
ATTRIBUTES
cp "$SOURCE/backup-readme.md" README.md

git add -- .gitignore .gitattributes README.md
if ! git diff --cached --quiet; then
  git commit -q -m 'chore: configure vault backup'
fi
