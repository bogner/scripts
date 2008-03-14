#!/bin/sh
# sets the environment up so commands work as expected

# use "! -z" instead of -n, -n doesn't work for null
if [ -z $ENV_IS_SET ]; then
    export ENV_IS_SET=1
    export PATH=$HOME/local/bin:$HOME/scripts:$PATH
fi

# Enable colors for ls, etc.
eval `dircolors -b`
# Alias definitions.
alias ls="ls --color=auto"
alias ll="ls -l"
alias la="ls -A"
alias l="ls -Al"
alias grep="grep --color"
alias rm="rm -i"
alias psu="ps -U $USER"
alias enscript="enscript -2rE"
[ -f $HOME/scripts/set_env_local.sh ] && source $HOME/scripts/set_env_local.sh
