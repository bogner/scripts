#!/bin/bash
true
while [ $? -eq 0 ]; do
    nc -v -v -l -p 80 -c \
'while read str; do if [ ${#str} -le 1 ]; then break; fi; done
echo -e \
"HTTP/1.1 303 See Other\r
Cache-Control: max-age = 604800\r
Connection: close\r
Date: $(date)\r
Location: http://www.ece.ualberta.ca/~jbogner/\r
Server: netcat $(nc -h 2>&1 | head -1)\r
Content-Length: 128\r
Content-Type: application/xhtml+xml\r
\r
<html>\r
<head>\r
  <title>Bogner Lives Here</title>\r
</head>\r
<body>\r
  Netcat is redirecting you elsewhere.\r
</body>\r
</html>\r
"'
done;
