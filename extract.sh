#!/usr/bin/env bash
# extract — unpack common archive formats with a single command.
set -euo pipefail

PROG="${0##*/}"

usage() {
  cat <<USAGE
$PROG — extract common archive formats with one command.

usage: $PROG [-h] <archive> [<archive>...]

Supported: .tar.gz .tgz .tar.bz2 .tbz2 .tar.xz .txz .tar
           .gz .bz2 .Z .zip .7z .rar
USAGE
}

die() {
  printf '%s: error: %s\n' "$PROG" "$1" >&2
  exit 1
}

# Ensure an external helper exists before we rely on it.
need() {
  command -v "$1" >/dev/null 2>&1 || die "required tool not found: $1"
}

extract_one() {
  local file="$1"
  [[ -f "$file" ]] || die "no such file: $file"

  case "$file" in
    *.tar.gz|*.tgz)   need tar;       tar -xzf "$file" ;;
    *.tar.bz2|*.tbz2) need tar;       tar -xjf "$file" ;;
    *.tar.xz|*.txz)   need tar;       tar -xJf "$file" ;;
    *.tar)            need tar;       tar -xf  "$file" ;;
    *.gz)             need gunzip;    gunzip -k "$file" ;;
    *.bz2)            need bunzip2;   bunzip2 -k "$file" ;;
    *.Z)              need uncompress; uncompress "$file" ;;
    *.zip)            need unzip;     unzip -q "$file" ;;
    *.7z)             need 7z;        7z x "$file" ;;
    *.rar)            need unrar;     unrar x "$file" ;;
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
