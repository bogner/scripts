#!/bin/bash
# a trivial script, because i do this a bunch

function die () {
    echo $1
    exit
}

if [ -e Setup.lhs ]; then
    setup=Setup.lhs
elif [ -e Setup.hs ]; then
    setup=Setup.hs
else
    die "No suitable setup file found"
fi

[ "$#" -gt 0 ] && [ "$1" = "clean" ] && runhaskell $setup clean

runhaskell $setup configure --user --prefix=$HOME/local &&
runhaskell $setup build &&
runhaskell $setup install --user
