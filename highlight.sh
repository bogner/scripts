#!/bin/bash
esc=$(echo -e '\033')
color=31
exp=''
while [ $# -gt 0 ] && [ "$1" != "--" ]; do
    exp="$exp;"'s/\('"$1"'\)/'"$esc"'[1;'"$color"'m\1'"$esc"'[0m/g'
    color=$(( color + 1 ))
    shift
done

sed "${exp#;}" $@
