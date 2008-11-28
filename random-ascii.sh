#!/bin/bash
# generate a random ascii string with the given length, or a random
# length between 5 and 15

die () {
    echo "$0: $@"
    exit
}

case $# in
    0) count=$(( $RANDOM * 10 / 32767 + 5 ));;
    1) count=$1;;
    *) die "usage: $0 [length]";;
esac

cat /dev/urandom | \
    perl -e 'while (<>) { s/[^[:print:]]//g; print; }' | \
    head -c $count
echo
