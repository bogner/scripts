#!/bin/bash

input="$1"
while [ -n "$input" ]; do
    next=""
    for i in $input; do
        next="$next $(ps --ppid $i -o pid=)"
    done
    echo $input
    input=$next
done
