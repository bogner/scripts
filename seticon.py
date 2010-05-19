#!/usr/bin/env python

import Xlib.display, Xlib.error, gtk, sys
from array import array

def main(argv):
    if len(argv) < 3:
        sys.stderr.write('Usage: set-icon icon_file window [window ...]\n')
        return 1
    try:
        set_window_icons(argv[1], argv[2:])
    except:
        raise

def set_window_icons(icon_file, windows):
    icon = Icon(icon_file)
    painter = WindowPainter()
    for win_id in windows:
        painter.draw_icon(win_id, icon)

class Icon:
    def __init__(self, filename):
        self.pixbuf = gtk.gdk.pixbuf_new_from_file(filename)
        self.ensure_alpha()

    def scale(self, width, height):
        self.pixbuf = self.pixbuf.scale_simple(width, height,
                                               gtk.gdk.INTERP_BILINEAR)

    def ensure_alpha(self):
        if not self.pixbuf.get_has_alpha():
            self.pixbuf.add_alpha(False, 0, 0, 0)

    def get_raw_bitmap(self):
        bitmap = array("I")
        bitmap.extend([self.pixbuf.get_width(), self.pixbuf.get_height()])
        bitmap.fromstring(self.pixbuf.get_pixels())
        return bitmap

class WindowPainter:
    def __init__(self):
        self.display = Xlib.display.Display()
        self.icon_atom = self.display.get_atom('_NET_WM_ICON')

    def draw_icon(self, window_id, icon):
        if isinstance(window_id, basestring):
            window_id = int(window_id, 16)
        window = self.display.create_resource_object('window', window_id)
        bitmap = icon.get_raw_bitmap()
        window.change_property(self.icon_atom, Xlib.Xatom.CARDINAL, 32, bitmap)
        self.display.flush()

if __name__ == '__main__':
    sys.exit(main(sys.argv))
