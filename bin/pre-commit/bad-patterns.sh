#!/usr/bin/env bash
#
# pre-commit hook:
# Check for hook scripts that use `sleep`


set -euo pipefail
requested=($@)
# If we source files in our hook scripts, we need to check them too.
additional=()
sleeps=0

# Obviously we shouldn't hit any missing sources, but it's easy enough to check
missing_source=()

add_sourced() {
  sourced=${1//\"}
  # we can't do much with template expansion here.
  if [[ $sourced =~ ^\{\{ ]]; then
    echo "Unable to check included file: ${sourced}"
    return
  fi
  additional+=($sourced)
}

file_check() {
  if [ ! -f "$1" ]; then
    missing_source+=($1)
    return 1
  fi
  while read -r line; do
    # skip comments
    if [[ $line =~ ^\#.* ]]; then continue; fi

    # we're sourcing another file, so we need to check that file too
    if [[ $line == ". "* ]]; then
      sourced=${line##. }
      add_sourced "$sourced"
      continue
    fi

    if [[ $line == "source "* ]]; then
      sourced=${line##source }
      add_sourced "$sourced"
      continue
    fi

    # It's OK to block in the run hook, but nowhere else.
    if [[ ${1##*/} != "run" && $line == *"sleep"* ]]; then
      sleeps=$((sleeps + 1))
      continue
    fi
  done < "$1"
}

for file in "${requested[@]}"; do
  file_check "$file"
done

if [[ ${#additional[@]} -gt 0 ]]; then
  for file in "${additional[@]}"; do
    file_check "$file"
  done
fi

if [[ $sleeps -gt 0 || ${#missing_source[@]} -gt 0 ]]; then
  files=$(printf "; %s" "${requested[@]}")
  if [[ ${#additional[@]} -gt 0 ]]; then
    files+=$(printf "; %s" "${additional[@]}")
  fi
  files=${files:2}
  if [[ ${#missing_source[@]} -gt 0 ]]; then
    sourced=$(printf ", %s" "${missing_source[@]}")
    sourced=${sourced:2}
  fi
  echo "Error detected by Check Bad Patterns."
  echo "We checked these files: ${files}."
  echo ""
  if [[ ${#missing_source[@]} -gt 0 ]]; then
    echo "  Found sourced files that don't exist: ${sourced}"
    echo ""
  fi
  if [[ $sleeps -gt 0 ]]; then
    echo "  Found sleep $sleeps times in hook scripts"
    echo ""
  fi
  echo ""
  exit 1
fi

exit 0
