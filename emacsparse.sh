#!/bin/bash

output=$(mktemp)
cat > $output
emacsclient -a less -n --eval "(let () (setq compile-command \"cat $output\")(recompile))"
sleep 0.2
rm -f $output
