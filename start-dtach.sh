#!/bin/bash
# create a dtach session with the given name
usage="$0 socket_prefix"

function die() {
    echo "$1"
    exit 1
}

[ $# -eq 1 ] || die "$usage"
[ -e ~/.dtach ] || mkdir ~/.dtach
SOCK=~/.dtach/$1.dtach

[ -e ~/.dtach/dtach.bashrc ] || cat > ~/.dtach/dtach.bashrc <<EOF
[ -r /etc/bash.bashrc ] && . /etc/bash.bashrc
[ -r ~/.bashrc ] && . ~/.bashrc
chmod 660 $SOCK
set -o ignoreeof
exit () { echo -e 'C-\\ to detach.\nreally_exit to disconnect everybody and kill the terminal'; }
really_exit () { unset exit; exit; }
EOF

dtach -c $SOCK -r winch -Ez bash --rcfile ~/.dtach/dtach.bashrc
