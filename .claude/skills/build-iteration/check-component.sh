#!/usr/bin/env bash
# Checks that the arrows in the solution's Component diagram (design/03-component.md) match the implementation's imports.
# Usage: .claude/skills/build-iteration/check-component.sh <package directory>…
# Prints mismatched arrows as "< only in imports" / "> only in the diagram", and exits with status 1 if there are any.
# Arrows to external elements (Component_Ext, ContainerDb_Ext) are not compared.
set -u
status=0
for dir in "$@"; do
  design="$dir/design/03-component.md"
  declare -A module=()
  while read -r id name; do
    module[$id]=$name
  done < <(grep -oE '^\s*Component\((\w+), "[A-Za-z.]+"' "$design" | sed -E 's/^\s*Component\((\w+), "([^"]+)"/\1 \2/')
  relations=$(grep -oE 'Rel\((\w+), (\w+)' "$design" | sed -E 's/Rel\((\w+), (\w+)/\1 \2/' |
    while read -r from to; do
      [[ -n "${module[$from]:-}" && -n "${module[$to]:-}" ]] && echo "${module[$from]} -> ${module[$to]}"
    done | sort -u)
  imports=$({
    for source in "$dir"/src/Kakeibo/*.hs; do
      name="Kakeibo.$(basename "$source" .hs)"
      grep -oE '^import (qualified )?Kakeibo\.[A-Za-z]+' "$source" | sed -E "s/^import (qualified )?/$name -> /"
    done
    grep -oE '^import Kakeibo\.[A-Za-z]+' "$dir/app/Main.hs" | sed -E 's/^import /Main -> /'
  } | sort -u)
  difference=$(diff <(echo "$imports") <(echo "$relations") | grep '^[<>]')
  if [[ -n "$difference" ]]; then
    echo "$design"
    echo "$difference"
    status=1
  fi
  unset module
done
exit $status
