#compdef ccc-rmobjs.sh

(( $+functions[_ccc_object_files] )) ||
_ccc_object_files() {
  local -a objects
  objects=(${(f)"$(find . -name '*.o' | awk -F/ '{print $NF}')"})
  _describe 'object' objects
}

_arguments \
    "*: :_ccc_object_files"

# Local Variables:
# mode: Shell-Script
# sh-indentation: 2
# indent-tabs-mode: nil
# sh-basic-offset: 2
# End:
# vim: ft=zsh sw=2 ts=2 et
