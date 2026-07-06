#!/usr/bin/env bash
# extract — unpack common archive formats with a single command.
set -euo pipefail

PROG="${0##*/}"
DEST="."
LIST=0

usage() {
  cat <<USAGE
$PROG — extract common archive formats with one command.

usage: $PROG [-h] [-l] [-C DIR] <archive> [<archive>...]

  -C, --dir DIR   extract into DIR (created if needed; default: current dir)
  -l, --list      list archive contents instead of extracting

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

stream_out() {
  local file="$1" tool="$2" suffix="$3"
  need "$tool"
  "$tool" -c "$file" > "$DEST/$(basename "${file%"$suffix"}")"
}

extract_one() {
  local file="$1"
  [[ -f "$file" ]] || die "no such file: $file"
  mkdir -p "$DEST"

  case "$file" in
    *.tar.gz|*.tgz)   need tar;   tar -xzf "$file" -C "$DEST" ;;
    *.tar.bz2|*.tbz2) need tar;   tar -xjf "$file" -C "$DEST" ;;
    *.tar.xz|*.txz)   need tar;   tar -xJf "$file" -C "$DEST" ;;
    *.tar)            need tar;   tar -xf  "$file" -C "$DEST" ;;
    *.gz)             stream_out "$file" gunzip .gz ;;
    *.bz2)            stream_out "$file" bunzip2 .bz2 ;;
    *.Z)              stream_out "$file" uncompress .Z ;;
    *.zip)            need unzip; unzip -q "$file" -d "$DEST" ;;
    *.7z)             need 7z;    7z x -o"$DEST" "$file" >/dev/null ;;
    *.rar)            need unrar; unrar x "$file" "$DEST/" ;;
    *)                die "unknown archive type: $file" ;;
  esac

  printf '%s: extracted %s -> %s\n' "$PROG" "$file" "$DEST"
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
      -h|--help) usage; exit 0 ;;
      -C|--dir)  DEST="${2:-}"; [[ -n "$DEST" ]] || die "-C needs a directory"; shift 2 ;;
      -l|--list) LIST=1; shift ;;
      --)        shift; while [[ $# -gt 0 ]]; do files+=("$1"); shift; done ;;
      -*)        die "unknown option: $1" ;;
      *)         files+=("$1"); shift ;;
    esac
  done
  [[ ${#files[@]} -gt 0 ]] || { usage; exit 1; }
  for file in "${files[@]}"; do
    if [[ $LIST -eq 1 ]]; then list_one "$file"; else extract_one "$file"; fi
  done
}

main "$@"
