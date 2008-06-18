#!/bin/bash

### This top part should be POSIX sh compatible, so that we can source
### it non-interactively and get our path
prepend_path () {
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


# Only continue if we're interactively running bash
[ -z "$PS1" ] || [ $(ps -p $$ -o comm=) != "bash" ] && return

### end of POSIX compatibility

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
[ -e ~/.dir_colors ] || dircolors -p >~/.dir_colors
eval `dircolors -b ~/.dir_colors`
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

export EDITOR="emacsclient -t"
export PAGER="less -FX"

# we want to know our fortune
which fortune 2>/dev/null >/dev/null && fortune
