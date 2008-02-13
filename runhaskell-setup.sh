#!/bin/bash
# a trivial script, because i do this a bunch

runhaskell Setup.lhs configure --user --prefix=$HOME/local
runhaskell Setup.lhs build
runhaskell Setup.lhs install --user
