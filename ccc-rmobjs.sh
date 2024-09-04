#!/bin/sh

die() { echo "ccc-rmobjs: error: $@" >&2; exit 1; }
[[ $# -gt 0 ]] || die "usage: $(basename $0) [obj.o...]"

objs=
while [[ $# -gt 0 ]]; do
  case $1 in
    *.o) objs="$1 $objs"; shift;;
    *)   die "Not an object file: $1";
  esac
done

for o in $objs; do
    for f in $(find . -name $o); do
        echo "Removing $f"
        rm $f
    done
done
