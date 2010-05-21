#!/usr/bin/env python

import gtk, glib, os, subprocess, signal, sys

DATA_DIRECTORY = os.path.join(os.path.dirname(__file__), 'data')

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
        icon = gtk.StatusIcon()
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
        renderer = Renderer.get_singleton()
        image = renderer.draw_with_counter(self.state.image_file,
                                           self.state.remaining)
        self.icon.set_from_pixbuf(image)

    def popup(self, icon, button, activate_time):
        self.menu.popup(None, None, gtk.status_icon_position_menu,
                        button, activate_time, icon)

    def quit(self, *args):
        gtk.main_quit()

class IndicatorState:
    def __init__(self, message, image_file, time):
        self.message = message
        self.image_file = image_file
        self.time = time
        self.remaining = self.time + 1
        self.next = None

def singleton(wrapped):
    @staticmethod
    def get_singleton():
        instance = wrapped()
        wrapped.get_singleton = staticmethod(lambda: instance)
        return instance
    wrapped.get_singleton = get_singleton
    return wrapped

@singleton
class Renderer(object):
    def __init__(self):
        self.image_root_path = DATA_DIRECTORY
        self.image_cache = {}

    def draw_with_counter(self, image_file, number):
        canvas = self.get_image(image_file).copy()
        if number <= 0:
            return canvas

        digits = [self.get_image('%s.png' % c) for c in str(number)]

        canvas_height = canvas.get_height()
        canvas_width = canvas.get_width()

        number_height = max(map(lambda x: x.get_height(), digits))
        number_width = sum(map(lambda x: x.get_width(), digits))
        h_scale = (2.0 * canvas_height) / (3.0 * number_height)
        w_scale = (2.0 * canvas_width) / (3.0 * number_width)
        scale = min(h_scale, w_scale)

        offset_x = (canvas_width - int(number_width * scale)) / 2
        offset_y = (canvas_height - int(number_height * scale)) / 2
        for digit in digits:
            digit.composite(canvas, 0, 0, canvas_width, canvas_height,
                            offset_x, offset_y, scale, scale,
                            gtk.gdk.INTERP_BILINEAR, 255)
            offset_x += digit.get_width() * scale
        return canvas

    def get_image(self, image_file):
        if not os.path.isabs(image_file):
            image_file = os.path.join(self.image_root_path, image_file)
        if image_file not in self.image_cache:
            image = gtk.gdk.pixbuf_new_from_file(image_file)
            self.image_cache[image_file] = image
        return self.image_cache[image_file]

def prompt(text):
    subprocess.Popen(['zenity', '--info', '--text', text]).wait()

if __name__ == '__main__':
    sys.exit(main(sys.argv))
