#!/bin/bash
# get ip addresses from host names and vice versa

for i in $@; do
    echo -ne "$i:\t"
    (host $i || echo '') | tail -n 1 | awk '{print $NF}'
done
