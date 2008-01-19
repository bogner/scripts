#!/bin/bash
content="$1"
isstdin=0
if [ $# -lt 1 ]; then
    content=mktemp
    cat - > $content
    isstdin=1
fi
true
while [ $? -eq 0 ]; do
    nc -v -v -l -p 80 -c \
"while read str; do if [ \${#str} -le 1 ]; then break; fi; done
echo -e \
\"HTTP/1.1 200 OK\r
Date: \$(date)\r
Server: netcat $(nc -h 2>&1 | head -1)\r
Content-Type: $(file -bi "$content")\r
\r\"; \
cat \"$content\"
"
done
if [ $isstdin -eq 1 ]; then
    rm -f $content
fi
