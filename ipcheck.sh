#!/bin/bash
# check your current ip address
wget -O - checkip.dyndns.org 2>/dev/null | \
    /bin/grep -o "\([0-9]*\.\)\{3\}[0-9]*"
