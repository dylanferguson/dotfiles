#!/bin/bash
set -euo pipefail

SOURCE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

shellcheck --shell=bash "$SOURCE"/*.sh
for script in "$SOURCE"/*.sh; do
  /bin/bash -n "$script"
done
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s "$SOURCE/tests" -v
