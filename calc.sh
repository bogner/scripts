#!/bin/bash
# A simple calculator using awk. The output format can be set via a
# printf style string by issuing a command like "fmt=%d", or by
# convenient aliases "hex", "dec", "num".

[ -z "$fmt" ] && fmt="%g"
decls="pi=3.141592653589793;"

if [ $# -gt 0 ]; then
    awk "BEGIN {printf(\"$fmt\n\",$*)}"
    exit
fi
while read -p "> " -e i; do
    history -s "$i"
    case $i in
        "")    ;;
        hex)   fmt="0x%08x";;
        dec)   fmt="%d";;
        num)   fmt="%g";;
        fmt=*) fmt="$(echo $i | awk -F= '{print $2}')";;
        *=*)   decls="$decls$i;";;
        *)     awk "BEGIN {$decls printf(\"$fmt\n\",$i)}";;
    esac
done
echo
