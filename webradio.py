#!/usr/bin/env python

import dbus, dbus.mainloop.qt
import signal
import sys
from PyQt4 import QtCore, QtGui, QtWebKit

def main(argv):
    # We want ctrl-c to kill qt
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    radio = Radio(argv)
    radio.choose_station()
    radio.window.show()

    configure_dbus(radio)

    return radio.exec_()

class Radio(QtGui.QApplication):
    def __init__(self, argv):
        QtGui.QApplication.__init__(self, argv)
        self.window = QtGui.QMainWindow()
        self.quitOnLastWindowClosed = True

        self.browser = QtWebKit.QWebView(
            titleChanged = self.window.setWindowTitle)
        self.window.setCentralWidget(self.browser)

        settings = self.browser.settings()
        settings.setAttribute(QtWebKit.QWebSettings.PluginsEnabled, True)

        QtGui.QShortcut("Ctrl+S", self.window, activated = self.choose_station)

        self.stations = {"pandora": "http://www.pandora.com",
                         "grooveshark": "http://grooveshark.com"}

    def choose_station(self):
        stations = self.stations.keys()
        station, ok = QtGui.QInputDialog.getItem(self.window,
                                                 "Choose a station",
                                                 "Station:",
                                                 stations,
                                                 editable = False)
        if ok:
            self.load_station(str(station))

    def load_station(self, station_name = None):
        station = self.stations[station_name]
        self.browser.load(QtCore.QUrl(station))

    def handle_media_key(self, source, event):
        # TODO: Can we do better than synthesizing key presses?
        if event == "Play":
            press_space = QtGui.QKeyEvent(QtCore.QEvent.KeyPress,
                                          QtCore.Qt.Key_Space,
                                          QtCore.Qt.NoModifier)
            self.postEvent(self.browser, press_space)
        # TODO: handle Previous, Next, Stop

def configure_dbus(radio):
    dbus.mainloop.qt.DBusQtMainLoop(set_as_default=True)

    bus = dbus.Bus(dbus.Bus.TYPE_SESSION)
    bus_object = bus.get_object('org.gnome.SettingsDaemon',
                                '/org/gnome/SettingsDaemon/MediaKeys')
    dbus_interface = 'org.gnome.SettingsDaemon.MediaKeys'
    bus_object.GrabMediaPlayerKeys("WebRadio", 0,
                                   dbus_interface = dbus_interface)
    bus_object.connect_to_signal('MediaPlayerKeyPressed',
                                 radio.handle_media_key)

if __name__ == "__main__":
    sys.exit(main(sys.argv))
