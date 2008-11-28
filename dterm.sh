#!/bin/bash
# run a terminal in a dtach session

die () {
    echo "$0: $@"
    exit
}

if [ $# -ge 1 ] && [[ $1 != -* ]]; then
    term=$1
else
    for s in urxvtcd urxvt rxvt-unicode rxvt xterm; do
        if type -t $s >/dev/null; then
            term=$s
            break
        fi
    done
fi

[ -e ~/.dtach ] || mkdir ~/.dtach

biggest=$(ls -v ~/.dtach | \
    sed -n 's/^dtach-term\.\([0-9]*\)\.dtach/\1/p' | \
    tail -1)
[ -n "$biggest" ] && next=$(( biggest + 1 )) || next=1
export SOCK=~/.dtach/dtach-term.$next.dtach

type -t dtach >/dev/null || die "dtach: command not found"

$term -e dtach -c $SOCK -r winch -Ez $SHELL
