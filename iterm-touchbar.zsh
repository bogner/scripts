#(( $+functions[_iterm_touchbar_esc] )) ||
_iterm_touchbar_esc() {
  if [ -n "$TMUX" ]; then
    printf "\033Ptmux;\033\033]1337;$@\a\033\\"
  else
    printf "\033]1337;$@\a"
  fi
}

#(( $+functions[_iterm_touchbar_set_label] )) ||
_iterm_touchbar_set_fkey() {
  local -a fkeys
  fkeys=('^[OP'    '^[OQ'     '^[OR'     '^[OS'     '^[[15~'
         '^[[17~'  '^[[18~'   '^[[19~'   '^[[20~'   '^[[21~'
         '^[[23~'  '^[[24~'   '^[[1;2P'  '^[[1;2Q'  '^[[1;2R'
         '^[[1;2S' '^[[15;2~' '^[[17;2~' '^[[18;2~' '^[[19;2~')

  local -a bk_flags
  while [[ "$1" == -* ]]; do
    bk_flags=($bk_flags $1)
    shift
  done

  _iterm_touchbar_esc "SetKeyLabel=F${1}=${2}"
  if [ -n "$3" ] || [ -n "${bk_flags}" ]; then
    bindkey "${bk_flags[@]}" $fkeys[$1] $3
  fi
}

#(( $+functions[_iterm_touchbar_set_label] )) ||
_iterm_touchbar_clear_keys() {
  [ "$1" -le 20 ] || return
  for k in {${1:-1}..20}; do
    _iterm_touchbar_set_fkey -r $k ' '
  done
  # There don't seem to be bindings past 20 - just blank the labels.
  for k in {21..24}; do
    _iterm_touchbar_esc "SetKeyLabel=F${k}= "
  done
}

#(( $+functions[_iterm_touchbar_git] )) ||
_iterm_touchbar_git() {
  local next_key=1
  _iterm_touchbar_state='git'

  _iterm_touchbar_set_fkey $((next_key++)) "⇦" _iterm_touchbar_main

  local -a branches
  branches=(${(f)"$(git branch | sed 's/^[ *]*//')"})
  branches=($branches ${(f)"$(git branch -r | sed 's/^ *//; /origin\/HEAD/d')"})
  for br in ${branches[1,19]}; do
    local fn="_iterm_touchbar_fn_${next_key}"
    local info="$(git branch -vv | sed 's/^[ *]*//' | awk '$1 == "'"$br"'"')"
    eval "$fn () {
      [ -z \"$info\" ] || zle -M \"$info\"
      zle copy-region-as-kill \"$br\"
    }"
    zle -N "$fn"
    _iterm_touchbar_set_fkey $((next_key++)) "$br" "$fn"
  done

  _iterm_touchbar_clear_keys $next_key
}

#(( $+functions[_iterm_touchbar_git] )) ||
_iterm_touchbar_dirstack() {
  local next_key=1
  _iterm_touchbar_state='dir'

  _iterm_touchbar_set_fkey $((next_key++)) "⇦" _iterm_touchbar_main

  for d in ${${(f)"$(dirs -p)"}[1,19]}; do
    local fn="_iterm_touchbar_fn_${next_key}"
    eval "$fn () {
      cd $d
      zle reset-prompt
    }"
    zle -N "$fn"
    _iterm_touchbar_set_fkey $((next_key++)) "$d" "$fn"
  done

  _iterm_touchbar_clear_keys $next_key
}

#(( $+functions[_iterm_touchbar_main] )) ||
_iterm_touchbar_main() {
  local wd next_key=1
  _iterm_touchbar_state=''

  # If we're remoted somewhere, list the host.
  # TODO: tmux?
  if [ "$SSH_CLIENT" ]; then
    _iterm_touchbar_set_fkey $((next_key++)) "🖥 $(hostname -s)"
  fi

  # Get the current workding directory for label 1.
  curdir=$(pwd)
  [[ $curdir == $HOME/* ]] && curdir="~${curdir#$HOME}"
  _iterm_touchbar_set_fkey $((next_key++)) "🗂 $curdir" \
                           _iterm_touchbar_dirstack

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    _iterm_touchbar_set_fkey $((next_key++)) "🎋 $(git current-branch)" \
                             _iterm_touchbar_git
  fi

  _iterm_touchbar_clear_keys $next_key
}

#(( $+functions[_iterm_touchbar_precmd] )) ||
_iterm_touchbar_update() {
  case $_iterm_touchbar_state in
    git) _iterm_touchbar_git;;
    dir) _iterm_touchbar_dirstack;;
    *) _iterm_touchbar_main;;
  esac
}
_iterm_touchbar_state=''

zle -N _iterm_touchbar_git
zle -N _iterm_touchbar_dirstack
zle -N _iterm_touchbar_main

autoload -Uz add-zsh-hook
add-zsh-hook precmd _iterm_touchbar_update

# Local Variables:
# mode: Shell-Script
# sh-indentation: 4
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
