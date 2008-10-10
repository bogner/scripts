#!/bin/bash
color=31
exp=''
while [ $# -gt 0 ] && [ "$1" != "--" ]; do
    exp="$exp;"'s/\('"$1"'\)/\o33[1;'"$color"'m\1\o33[0m/g'
    color=$(( color + 1 ))
    shift
done

sed "${exp#;}" $@
