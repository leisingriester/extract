#!/usr/bin/env bash
# extract — unpack common archive formats with a single command.
set -euo pipefail

PROG="${0##*/}"

usage() {
  cat <<USAGE
$PROG — extract common archive formats with one command.

usage: $PROG [-h] <archive> [<archive>...]
USAGE
}

main() {
  case "${1:-}" in
    ''|-h|--help) usage; exit 0 ;;
  esac
  echo "$PROG: not implemented yet" >&2
  exit 1
}

main "$@"
