#!/usr/bin/env bash
# extract — unpack common archive formats with a single command.
set -euo pipefail

PROG="${0##*/}"

usage() {
  cat <<USAGE
$PROG — extract common archive formats with one command.

usage: $PROG [-h] <archive> [<archive>...]

Supported: .tar.gz .tgz .tar.bz2 .tbz2 .tar .gz .zip
USAGE
}

die() {
  printf '%s: error: %s\n' "$PROG" "$1" >&2
  exit 1
}

extract_one() {
  local file="$1"
  [[ -f "$file" ]] || die "no such file: $file"

  case "$file" in
    *.tar.gz|*.tgz)   tar -xzf "$file" ;;
    *.tar.bz2|*.tbz2) tar -xjf "$file" ;;
    *.tar)            tar -xf  "$file" ;;
    *.gz)             gunzip -k "$file" ;;
    *.zip)            unzip -q "$file" ;;
    *)                die "unknown archive type: $file" ;;
  esac

  printf '%s: extracted %s\n' "$PROG" "$file"
}

main() {
  case "${1:-}" in
    ''|-h|--help) usage; exit "$( [[ -z "${1:-}" ]] && echo 1 || echo 0 )" ;;
  esac
  for file in "$@"; do
    extract_one "$file"
  done
}

main "$@"
