#!/usr/bin/env python

import gtk, glib, subprocess, signal, sys
from egg import trayicon

def main(argv):
    indicator = Indicator('pomodoro')
    try:
        gtk.main()
    except KeyboardInterrupt:
        return 1
    return 0

class Indicator:
    def __init__(self, name):
        icon = trayicon.TrayIcon(name)
        self.label = gtk.Label(' %s ' % name)
        icon.add(self.label)
        icon.show_all()

        self.remaining = 0
        self.doing = 'Rest'

        self.next_state()

    def quit(self, *args):
        print 'foo'

    def next_state(self):
        print "changing state"
        self.remaining -= 1
        if self.remaining <= 0:
            if self.doing == 'Work':
                prompt('Take a short break')
                self.doing = 'rest'
                self.remaining = 5
            else:
                prompt('Work for 25 minutes.')
                self.doing = 'Work'
                self.remaining = 25
        self.update_text(' %s: %dm ' % (self.doing, self.remaining))
        glib.timeout_add(60 * 1000, self.next_state)

    def update_text(self, text):
        self.label.set_text(text)

def prompt(text):
    subprocess.Popen(['zenity', '--info', '--text', text]).wait()

if __name__ == '__main__':
    sys.exit(main(sys.argv))
