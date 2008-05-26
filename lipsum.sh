#!/bin/bash

function elem() {
    [[ " $2 " == *" $1 "* ]]
}

if elem "$2" "paras words bytes lists"; then
    what=$2
else
    what=paras
fi
if [ -n "$1" ]; then
    amount=$1
else
    amount=2
fi

wget -O - --post-data="amount=$amount&what=$what&start=yes&generate=Generate+Lorem+Ipsum" http://lipsum.com/feed/html 2>/dev/null | html2text | sed '/Lorem ipsum dolor sit amet/,$!d; $d'
