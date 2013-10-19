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

c_files='.*\.(cc?|hh?|([ch][px+]{2}))'
find -type f -regextype posix-awk -iregex "$c_files" -printf '"%p"\n' | \
    cscope -bqk "${@:1:$#-1}" -i-

rm -f /tmp/cscope.pid;
