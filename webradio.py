#!/usr/bin/env python

import dbus, dbus.mainloop.qt
import signal
import sys
from PyQt4 import QtGui, QtCore, QtWebKit

def main(argv):
    # We want ctrl-c to kill qt
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    app = QtGui.QApplication(argv)
    radio = RadioWindow()
    radio.choose_station()
    radio.show()

    configure_dbus(radio)

    return app.exec_()

class RadioWindow(QtGui.QMainWindow):
    def __init__(self):
        QtGui.QMainWindow.__init__(self)
        self.browser = QtWebKit.QWebView(titleChanged = self.setWindowTitle)
        self.setCentralWidget(self.browser)

        settings = self.browser.settings()
        settings.setAttribute(QtWebKit.QWebSettings.PluginsEnabled, True)

        QtGui.QShortcut("Ctrl+S", self, activated = self.choose_station)

        self.stations = {"pandora": "http://www.pandora.com",
                         "grooveshark": "http://grooveshark.com"}

    def choose_station(self):
        stations = self.stations.keys()
        station, ok = QtGui.QInputDialog.getItem(
            self, "Choose a station", "Station:", stations, editable = False)
        if ok:
            self.load_station(str(station))

    def load_station(self, station_name = None):
        station = self.stations[station_name]
        self.browser.load(QtCore.QUrl(station))

    def handle_media_key(self, source, event):
        print "Media key: %s" % event

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
