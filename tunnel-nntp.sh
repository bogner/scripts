#!/bin/bash

sshcommand="ssh -fN -L1119:tabloid.srv.ualberta.ca:119 feynman.ece.ualberta.ca"
tunnel_pid=$(ps -eo pid,cmd | awk "/^[0-9]* $sshcommand/ {print \$1}" | head)

echo "removing iptables rules"
sudo iptables -t nat -D PREROUTING -p tcp -d news.srv.ualberta.ca --dport 119 -j DNAT --to 127.0.0.1:1119
sudo iptables -t nat -D OUTPUT -p tcp -d news.srv.ualberta.ca --dport 119 -j REDIRECT --to-port 1119

dig +short -x $(ipcheck.sh) | grep ualberta.ca 1>/dev/null
if [ "$?" -eq 0 ]; then
    if [ -n "$tunnel_pid" ]; then
        echo "bringing down ssh tunnel..."
        kill -9 $tunnel_pid
    fi
    echo "tunnel is now DOWN"
else
    echo "adding iptables rules"
    sudo iptables -t nat -A PREROUTING -p tcp -d news.srv.ualberta.ca --dport 119 -j DNAT --to 127.0.0.1:1119
    sudo iptables -t nat -A OUTPUT -p tcp -d news.srv.ualberta.ca --dport 119 -j REDIRECT --to-port 1119
    if [ -z "$tunnel_pid" ]; then
        echo "bringing up ssh tunnel..."
        $sshcommand
    fi
    echo "tunnel is now UP"
fi
