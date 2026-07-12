#!/usr/bin/env bash
# extract — unpack common archive formats with a single command.
set -euo pipefail

PROG="${0##*/}"
DEST="."
LIST=0
DRYRUN=0

usage() {
  cat <<USAGE
$PROG — extract common archive formats with one command.

usage: $PROG [-h] [-l] [-n] [-C DIR] <archive> [<archive>...]

  -C, --dir DIR   extract into DIR (created if needed; default: current dir)
  -l, --list      list archive contents instead of extracting
  -n, --dry-run   show what would happen without touching disk

Supported: .tar.gz .tgz .tar.bz2 .tbz2 .tar.xz .txz .tar
           .gz .bz2 .Z .zip .7z .rar
USAGE
}

die() {
  printf '%s: error: %s\n' "$PROG" "$1" >&2
  exit 1
}

need() {
  command -v "$1" >/dev/null 2>&1 || die "required tool not found: $1"
}

# run a command, or just print it under --dry-run
run() {
  if [[ $DRYRUN -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

stream_out() {
  local file="$1" tool="$2" suffix="$3"
  need "$tool"
  local out="$DEST/$(basename "${file%"$suffix"}")"
  if [[ $DRYRUN -eq 1 ]]; then
    printf '[dry-run] %s -c %s > %s\n' "$tool" "$file" "$out"
  else
    "$tool" -c "$file" > "$out"
  fi
}

extract_one() {
  local file="$1"
  [[ -f "$file" ]] || die "no such file: $file"
  [[ $DRYRUN -eq 1 ]] || mkdir -p "$DEST"

  case "$file" in
    *.tar.gz|*.tgz)   need tar;   run tar -xzf "$file" -C "$DEST" ;;
    *.tar.bz2|*.tbz2) need tar;   run tar -xjf "$file" -C "$DEST" ;;
    *.tar.xz|*.txz)   need tar;   run tar -xJf "$file" -C "$DEST" ;;
    *.tar)            need tar;   run tar -xf  "$file" -C "$DEST" ;;
    *.gz)             stream_out "$file" gunzip .gz ;;
    *.bz2)            stream_out "$file" bunzip2 .bz2 ;;
    *.Z)              stream_out "$file" uncompress .Z ;;
    *.zip)            need unzip; run unzip -q "$file" -d "$DEST" ;;
    *.7z)             need 7z;    run 7z x -o"$DEST" "$file" ;;
    *.rar)            need unrar; run unrar x "$file" "$DEST/" ;;
    *)                die "unknown archive type: $file" ;;
  esac

  [[ $DRYRUN -eq 1 ]] || printf '%s: extracted %s -> %s\n' "$PROG" "$file" "$DEST"
}

list_one() {
  local file="$1"
  [[ -f "$file" ]] || die "no such file: $file"

  case "$file" in
    *.tar.gz|*.tgz)   need tar;   tar -tzf "$file" ;;
    *.tar.bz2|*.tbz2) need tar;   tar -tjf "$file" ;;
    *.tar.xz|*.txz)   need tar;   tar -tJf "$file" ;;
    *.tar)            need tar;   tar -tf  "$file" ;;
    *.zip)            need unzip; unzip -l "$file" ;;
    *.7z)             need 7z;    7z l "$file" ;;
    *.rar)            need unrar; unrar l "$file" ;;
    *.gz|*.bz2|*.Z)   printf '%s\n' "$(basename "${file%.*}")" ;;
    *)                die "cannot list: $file" ;;
  esac
}

main() {
  local files=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)    usage; exit 0 ;;
      -C|--dir)     DEST="${2:-}"; [[ -n "$DEST" ]] || die "-C needs a directory"; shift 2 ;;
      -l|--list)    LIST=1; shift ;;
      -n|--dry-run) DRYRUN=1; shift ;;
      --)           shift; while [[ $# -gt 0 ]]; do files+=("$1"); shift; done ;;
      -*)           die "unknown option: $1" ;;
      *)            files+=("$1"); shift ;;
    esac
  done
  [[ ${#files[@]} -gt 0 ]] || { usage; exit 1; }
  for file in "${files[@]}"; do
    if [[ $LIST -eq 1 ]]; then list_one "$file"; else extract_one "$file"; fi
  done
}

main "$@"
