#!/bin/bash
# Generates a cscope database recursively under the given directory.
# Protects against running concurrently

die () { echo "$(basename $0): $@" >&2; exit 1; }
type cscope >/dev/null || die "cscope not found"

[ $# -gt 0 ] || die "usage: $0 <flags> topdir"

topdir="${!#}"
cd "$topdir" 2>/dev/null || die "could not change to directory: $topdir"

if [ -e /tmp/cscope.pid ]; then
    die "cscope already running";
else
    echo $$ > /tmp/cscope.pid;
fi;

find_ext_re () {
    # BSD and GNU disagree on how to turn on extended regex...
    path="$1"; shift
    if find --version 2>/dev/null | grep GNU &>/dev/null; then
        find "$path" -regextype posix-extended "$@"
    else
        find -E "$path" "$@"
    fi
}

c_files='.*\.(cc?|hh?|([ch][px+]{2}))'
find_ext_re . -type f -iregex "$c_files" -print | awk '{print "\""$0"\""}' | \
    cscope -bqk "${@:1:$#-1}" -i-

rm -f /tmp/cscope.pid;
