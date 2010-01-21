#!/usr/bin/env python
import csv, sys
from subprocess import Popen, PIPE

ASCII_UNIT_SEPARATOR = 0x1f

def main(argv):
    outstream = sys.stdout

    outstream.write("digraph G {\n")

    sep = '%x' % ASCII_UNIT_SEPARATOR
    logFormat = ('%x' + sep).join(['%h', '%p', '%d'])
    proc = Popen(['git', 'log', '--pretty=format:%s' % logFormat] + argv[1:],
                 stdout = PIPE)
    reader = csv.reader(proc.stdout, delimiter = chr(ASCII_UNIT_SEPARATOR))
    for sha1, parents, refnames in reader:
        edges = ['"%s"->"%s"' % (parent, sha1) for parent in parents.split()]

        label = None
        refnames = refnames.strip()
        if refnames:
            if refnames[0] == '(':
                refnames = refnames[1:]
            if refnames[-1] == ')':
                refnames = refnames[:-1]

            names = refnames.split(', ')
            if len(names) == 1:
                label = '/'.join(names[0].split('/')[2:])
            elif len(names) > 1:
                namesByKind = {}
                for name in names:
                    kind = name.split('/')[1]
                    realname = '/'.join(name.split('/')[2:])
                    namesByKind[kind] = realname
                keys = namesByKind.keys()
                for kind in ('tags', 'heads', 'remotes'):
                    if kind in keys:
                        label = namesByKind[kind]
                        break
        if not label:
            label = sha1
        line = '"%s" [label="%s"];%s;\n' % (sha1, label, ';'.join(edges))
        outstream.write(line)

    outstream.write("}\n")

if __name__ == '__main__':
    main(sys.argv)
