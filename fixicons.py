#!/usr/bin/env python

import seticon

import gobject
import subprocess
import sys

icons = {'xterm-256color':  'terminal',
         'screen-256color': 'terminal',
         'irssi':           'applications-chat',
         'rdesktop':        'gnome-remote-desktop'}

def main(argv):
    try:
        set_icons()
    except gobject.GError, e:
        sys.stderr.write('Could not load icon: %s\n' % e)
        return 2
    return 0

def set_icons():
    for name,icon in icons.items():
        wins = list(get_windows(name))
        print 'Setting "%s" as the icon for %d windows' % (icon,len(wins))
        seticon.set_window_icons(icon, wins)

def get_windows(name):
    for line in subprocess.check_output(['wmctrl', '-l']).splitlines():
        if name in line:
            yield line.split()[0]

if __name__ == '__main__':
    sys.exit(main(sys.argv))
