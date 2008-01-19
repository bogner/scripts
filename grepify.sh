#!/bin/bash
if [ "$#" -eq 1 ]; then
    files="*"
else
    files=""
fi
grep -n --color=always "$@" $files | less -RFX
