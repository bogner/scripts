#!/usr/bin/env python
''' April fools! Your normal ls binary is at /bin/ls.real '''

import fcntl
import os
import struct
import subprocess as sp
import sys
import termios

REAL_LS = '/bin/ls'
if sys.argv[0] == REAL_LS:
    REAL_LS = REAL_LS + '.real'

def find_max_width(lines):
    return max(line_width(line) for line in lines)

def line_width(line):
    w = 0
    chars = [x for x in line]
    while chars:
        char = chars.pop(0)
        if char == "\t":
            w += 8 - (w%8)
        elif ord(char) == 0x1b:
            while chars and chars.pop(0) != "m": pass
        else:
            w += 1
    return w

def fallback_to_real_ls():
    sys.exit(sp.call([REAL_LS] + sys.argv[1:]))

if not sys.stdout.isatty():
    fallback_to_real_ls()

rows, cols = map(int, os.popen('stty size', 'r').read().strip().split())
cols -= 12
if cols < 30:
    fallback_to_real_ls()

cowls_input, ls_out = os.openpty()
fcntl.ioctl(ls_out, termios.TIOCSWINSZ, struct.pack('HHHH', rows, cols, 0, 0))
sp.call([REAL_LS] + sys.argv[1:], stdout=ls_out)

fcntl.fcntl(cowls_input, fcntl.F_SETFL,
            fcntl.fcntl(cowls_input, fcntl.F_GETFL) | os.O_NONBLOCK)
buf = os.fdopen(cowls_input).read()
lines = buf.split('\n')
if not lines:
    lines = ["Moo..."]
width = find_max_width(lines)

if len(lines) == 1:
    sides = ["<>"]
else:
    sides = ["/\\"] + ["||"] * (len(lines)-2) + ["\\/"]
border_len = 4*((width+8)/4) - 1
print " " * 5 + "_" * border_len
for line, edges in zip(lines, sides):
    padding = width - line_width(line.rstrip())
    prefix = " " * 4 + edges[0] + "\t" + line.rstrip() + " " * padding
    padding = 4*((line_width(prefix)+4)/4) - line_width(prefix)
    right_edge = " " * padding + edges[1]
    print prefix + right_edge
print " " * 5 + "^" * border_len
print ("        \\   ^__^\n"
       "         \\  (oo)\_______\n"
       "            (__)\\       )\\/\\\n"
       "                ||----w |\n"
       "                ||     ||")
