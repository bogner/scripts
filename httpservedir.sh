#!/bin/bash
notfound="You are asking the wrong questions..."
notimpl="I'm Sorry Dave, I'm afraid I can't do that"

true
while [ $? -eq 0 ]; do
    nc -v -v -l -p 80 -c <<EOD
read str;
case $str in
    GET\ *)
        filename=$(echo $str |\
            sed 's/^[^ ]\+ \(.\+\) HTTP\/1.[01]/\1/; s/%/\\0/' )
        if [ ! -e $dir/"$filename" || "$filename" = *..* ]; then
            response="404 Not Found"
            type="application/xhtml+xml"
            content="<pre>$(cowsay "$notfound")</pre>"
        else if [ -d $dir/"$filename" ]; then
            response="200 OK"
            content="$(ls |\
                     awk '{print \"<a href=\\\"\" \$0 \"\\\">\" \$0 \"</a>\"}')"
            type="application/xhtml+xml"
        fi
        ;;
    *)
        response="501 Not Implemented"
        type="application/xhtml+xml"
        content="<pre>$(cowsay "$notimpl")</pre>"
esac

if [ -z "$content" ]; then
    response="200 OK"
    type=$(file -bi "$filename")
    content=$(cat "$filename")
else
    content=<<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html><head><title>$title</title></head>
<body>$content</body></html>
EOF
fi

while read str; do
    if [ \${#str} -le 1 ]; then
        break;
    fi;
done
echo -e \
"HTTP/1.1 $response\r
Date: \$(date)\r
Server: netcat $(nc -h 2>&1 | head -1)\r
Content-Type: $type\r
\r
$content"
EOD
