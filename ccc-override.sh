#!/bin/sh
# Convenience script for clang's CCC_OVERRIDE_OPTIONS

die() { echo "ccc-override: error: $@" >&2; exit 1; }

help() {
  cat <<HERE
usage: $0 [-q] [edit ...] [cmd ...]

Runs a command with edits specified in the CCC_OVERRIDE_OPTIONS
environment variable, which is recognized by clang.

Edits may be one or more of the following:

  '^': Add FOO as a new argument at the beginning of the command line.

  '+': Add FOO as a new argument at the end of the command line.

  's/XXX/YYY/': Substitute the regular expression XXX with YYY in the command
  line.

  'xOPTION': Removes all instances of the literal argument OPTION.

  'XOPTION': Removes all instances of the literal argument OPTION,
  and the following argument.

  'Ox': Removes all flags matching 'O' or 'O[sz0-9]' and adds 'Ox'
  at the end of the command line.

If no edits are provided, the default is 'O0 -g'
HERE
}

[ -z "$CCC_OVERRIDE_OPTIONS" ] || die "CCC_OVERRIDE_OPTIONS already set?"

export CCC_OVERRIDE_OPTIONS
while :; do
  case $1 in
    ^*)       CCC_OVERRIDE_OPTIONS="$CCC_OVERRIDE_OPTIONS $1"; shift;;
    +*)       CCC_OVERRIDE_OPTIONS="$CCC_OVERRIDE_OPTIONS $1"; shift;;
    s/*)      CCC_OVERRIDE_OPTIONS="$CCC_OVERRIDE_OPTIONS $1"; shift;;
    x*)       CCC_OVERRIDE_OPTIONS="$CCC_OVERRIDE_OPTIONS $1"; shift;;
    O[sz0-9]) CCC_OVERRIDE_OPTIONS="$CCC_OVERRIDE_OPTIONS $1"; shift;;
    X*)       CCC_OVERRIDE_OPTIONS="$CCC_OVERRIDE_OPTIONS $1 $2"; shift 2;;

    -q)       CCC_OVERRIDE_OPTIONS="#$CCC_OVERRIDE_OPTIONS"; shift;;
    -h|--help) help; exit 0;;
    *)         break;
  esac
done
[ -n "$CCC_OVERRIDE_OPTIONS" ] || CCC_OVERRIDE_OPTIONS="O0 -g"

[ $# -gt 0 ] || die "No command provided\n\n$(help)"
exec "$@"
