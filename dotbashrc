#!/bin/bash

function prepend_path() {
  old_ifs="$IFS"
  IFS=:
  while [ -n "$1" ]; do
    for path in $PATH; do
      [ "$path" = "$1" ] && shift && continue 2;
    done;
    PATH="$1:$PATH"
  done;
  IFS="$old_ifs"
}

prepend_path $HOME/local/bin $HOME/scripts


# If not running interactively, don't do anything else
[ -z "$PS1" ] && return


# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"
# set a fancy prompt
case $TERM in
    dumb)
        ;;
    *)
        COL0='\[\e[0;31m\]' # green
        COL1='\[\e[0;34m\]' # blue
        COL2='\[\e[0;32m\]' # red
        NC='\[\e[0m\]'
        ;;
esac
if [[ ${EUID} == 0 ]] ; then
    PS1="${COL0}\h${COL1} \W \$${NC} "
else
    PS1="${COL2}\u@\h${COL1} \w \$${NC} "
fi
unset COL0 COL1 COL2 NC
# Change the window title of X terminals 
case $TERM in
    xterm*|rxvt*|Eterm)
	PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
        ;;
    screen)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
        ;;
esac
# disable XON/XOFF (c-s should search, not pause)
stty -ixon
# programmable completion
[ -f /etc/bash_completion ] && . /etc/bash_completion


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
alias lpr="lpr -h"
alias vncviewer='vncviewer -shared'

export EDITOR="emacs -nw"
export PAGER="less -F"

# we want to know our fortune
which fortune >/dev/null && fortune
