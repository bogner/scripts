#!/bin/bash

[ -z "$fmt" ] && fmt="%lg"

if [ $# -gt 0 ]; then
    awk "BEGIN {printf(\"$fmt\n\",$*)}"
    exit
fi
while read i; do
    case $i in
        hex)   fmt="0x%08x";;
        dec)   fmt="%d";;
        num)   fmt="%lg";;
        fmt=*) fmt="$(echo $i | awk -F= '{print $2}')";;
        *)     awk "BEGIN {printf(\"$fmt\n\",$i)}";;
    esac
done
