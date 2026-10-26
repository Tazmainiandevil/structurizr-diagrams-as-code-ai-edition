#!/usr/bin/env bash
# Prints one workspace folder per line.
#   workspaces.sh              every folder that holds a workspace.dsl
#   workspaces.sh BASE [HEAD]  only the folders changed between BASE and HEAD
# Falls back to every workspace when BASE is empty, all zeros (new branch) or
# unknown to git, or when the pipeline or this script changed.
set -euo pipefail

base="${1:-}"
head="${2:-HEAD}"

all() {
  find . -mindepth 2 -maxdepth 2 -name workspace.dsl \
    -not -path './docs/*' -not -path './.git/*' -print \
    | sed -e 's|^\./||' -e 's|/workspace\.dsl$||' | sort
}

if [[ -z "$base" || "$base" =~ ^0+$ ]] || ! git cat-file -e "${base}^{commit}" 2>/dev/null; then
  all
  exit 0
fi

changed="$(git diff --name-only "$base" "$head")"

if grep -qE '^(\.github/|scripts/)' <<<"$changed"; then
  all
  exit 0
fi

while IFS= read -r folder; do
  while IFS= read -r file; do
    # A plain prefix test, so folder names are never read as patterns.
    if [[ "$file" == "$folder"/* ]]; then
      echo "$folder"
      break
    fi
  done <<<"$changed"
done < <(all)
