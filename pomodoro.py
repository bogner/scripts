#!/usr/bin/env python

import gtk, gtkextra, glib, os, subprocess, sys

def main(argv):
    indicator = Indicator('pomodoro')
    indicator.run()
    try:
        gtk.main()
    except KeyboardInterrupt:
        return 1
    return 0

class Indicator:
    def __init__(self, name):
        self.icon = self.make_icon()
        self.menu = self.make_menu()
        self.state = self.make_fsm()

    def make_icon(self):
        icon = gtkextra.StatusIcon()
        icon.connect("popup-menu", self.popup)
        return icon

    def make_menu(self):
        menu = gtk.Menu()
        items = [("Quit", self.quit)]
        for label, method in items:
            item = gtk.MenuItem(label)
            item.connect("activate", method)
            item.show()
            menu.append(item)
        return menu

    def make_fsm(self):
        work = IndicatorState('Work for 25 minutes', 'pomodoro.png', time = 25)
        rest = IndicatorState('Take a short break', 'sleep.png', time = 5)
        work.next = rest
        rest.next = work
        return work

    def run(self):
        self.transition()
        self.update_gui()
        glib.timeout_add(60 * 1000, self.run)

    def transition(self):
        self.state.remaining -= 1
        if self.state.remaining <= 0:
            self.state = self.state.next
            if not self.state:
                self.quit()
            prompt(self.state.message)
            self.state.remaining = self.state.time

    def update_gui(self):
        self.icon.set_from_file_with_counter(self.state.image_file,
                                             self.state.remaining)

    def popup(self, icon, button, activate_time):
        self.menu.popup(None, None, gtk.status_icon_position_menu,
                        button, activate_time, icon)

    def quit(self, *args):
        gtk.main_quit()

class IndicatorState:
    def __init__(self, message, image_file, time):
        self.message = message
        self.image_file = self.get_data_file(image_file)
        self.time = time
        self.remaining = self.time + 1
        self.next = None

    def get_data_file(self, file_name):
        if os.path.isabs(file_name):
            return file_name
        data_dir = os.path.join(os.path.dirname(__file__), 'data')
        return os.path.join(data_dir, file_name)

def prompt(text):
    subprocess.Popen(['zenity', '--info', '--text', text]).wait()

if __name__ == '__main__':
    sys.exit(main(sys.argv))
