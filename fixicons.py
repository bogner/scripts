#!/usr/bin/env python

import seticon

import gobject
import subprocess
import sys

icons = (('(xterm-256color)',  'terminal'),
         ('(screen-256color)', 'terminal'),
         ('(st-256color)',     'terminal'),
         ('irssi.',            'applications-chat'),
         ('TightVNC',          'gnome-remote-desktop'),
         ('rdesktop',          'gnome-remote-desktop'))

def main(argv):
    try:
        set_icons()
    except gobject.GError, e:
        sys.stderr.write('Could not load icon: %s\n' % e)
        return 2
    return 0

def set_icons():
    for name,icon in icons:
        wins = list(get_windows(name))
        print 'Setting "%s" as the icon for %d windows' % (icon,len(wins))
        seticon.set_window_icons(icon, wins)

def get_windows(name):
    proc = subprocess.Popen(['xdotool', 'search', '--name', name],
                            stdout=subprocess.PIPE)
    out, _ = proc.communicate()
    return [line.strip() for line in out.splitlines()]

if __name__ == '__main__':
    sys.exit(main(sys.argv))
