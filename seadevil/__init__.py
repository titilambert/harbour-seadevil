#!/usr/bin/python3
# -*- coding: utf-8 -*-
# Copyright (C) 2014 Thibault Cohen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
Python file for SeaDevil
"""

__version__ = "0.9"


import socket
import struct
import sys
import os
try:
    import configparser
    CONFIG = configparser.ConfigParser()
except Exception as exp:
    pass

try:
    import dbus
except Exception as exp:
    pass

try:
    import pyotherside
except ImportError:
    # Allow testing Python backend alone.
    # print("PyOtherSide not found, continuing anyway!")

    class pyotherside:
        """ Fake class """

        def __init__(self):
            """ Fake function """
            pass

        def atexit(*args):
            """ Fake function """
            pass

        def send(*args):
            """ Fake function """
            pass

    sys.modules["pyotherside"] = pyotherside()

# SeaDevil config folder
CONFIG_FOLDER = os.path.join(os.environ.get('HOME'),
                             ".config/harbour-seadevil/")
# SeaDevil config file path
CONFIG_FILE = os.path.join(CONFIG_FOLDER, "config.ini")

# Create config folder
if not os.path.exists(CONFIG_FOLDER):
    os.makedirs(CONFIG_FOLDER)

if not os.path.isdir(CONFIG_FOLDER):
    raise Exception("'%s' must be a folder" % CONFIG_FOLDER)


def read_configuration():
    """ Read configuration """
    try:
        CONFIG.read(CONFIG_FILE)
    except Exception as exp:
        print(exp)
        return False
    return True


def transform_mac(macaddress):
    """ clean macaddress """
    if len(macaddress) == 12:
        macaddress = ":".join(map(lambda x, y: x + y,
                                  macaddress[::2],
                                  macaddress[1::2]))
    return macaddress


def dbus_notify(pre_title, pre_message, title, message):
    """ Notify using python2 Dbus """
    bus = dbus.SessionBus()
    dbus_object = bus.get_object('org.freedesktop.Notifications',
                                 '/org/freedesktop/Notifications')
    interface = dbus.Interface(dbus_object,
                               'org.freedesktop.Notifications')

    # The next line print dbus capabilities
    # print(interface.GetCapabilities())

    interface.Notify("SeaDevil",
                     0,
                     "harbour-seadevil",
                     title,
                     message,
                     dbus.Array(["default", ""]),
                     dbus.Dictionary({"x-nemo-preview-body": pre_message,
                                      "x-nemo-preview-summary": pre_title},
                                     signature='sv'),
                     0)


def wake_on_lan(macaddress):
    """ Switches on remote computers using WOL.
        # Use macaddresses with any seperators.
        wake_on_lan('0F:0F:DF:0F:BF:EF')
        wake_on_lan('0F-0F-DF-0F-BF-EF')
        # or without any seperators.
        wake_on_lan('0F0FDF0FBFEF')
    """
    # Check macaddress format and try to compensate.
    if len(macaddress) == 12:
        pass
    elif len(macaddress) == 12 + 5:
        sep = macaddress[2]
        macaddress = macaddress.replace(sep, '')
    else:
        return False, 'Incorrect MAC address format'

    # Pad the synchronization stream.
    data = b'FFFFFFFFFFFF' + (macaddress * 20).encode()
    send_data = b''

    # Split up the hex values and pack.
    for i in range(0, len(data), 2):
        send_data += struct.pack('B', int(data[i: i + 2], 16))

    # Broadcast it to the LAN.
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    try:
        sock.sendto(send_data, ('<broadcast>', 7))
    except Exception as exp:
        print(exp)
        return False, str(exp)
    # Save mac address as last used
    save_last_mac(macaddress)

    return True, 'OK'


def save_last_mac(macaddress):
    """ Save last macaddress used """
    # Read configuration
    if not read_configuration():
        return

    if not 'general' in CONFIG:
        CONFIG['general'] = {}

    CONFIG['general']['last'] = macaddress
    with open(CONFIG_FILE, 'w') as config_f:
        CONFIG.write(config_f)


def get_last_mac():
    """ Get last macaddress used """
    # Read configuration
    if not read_configuration():
        return ''

    if 'general' not in CONFIG.sections():
        return ''

    mac = CONFIG['general'].get('last', '')
    return (transform_mac(mac), get_name(mac))


def get_mac(name):
    """ Get mac address from name """
    # Read configuration
    if not read_configuration():
        return ''

    if 'computers' not in CONFIG.sections():
        return ''

    return CONFIG['computers'].get(name, '')


def get_name(macaddress):
    """ Get name from mac address """
    # Read configuration
    if not read_configuration():
        return ''

    if 'computers' not in CONFIG.sections():
        return ''

    # Clean mac address
    macaddress = transform_mac(macaddress)

    # Get name
    names = [name for name, mac in CONFIG['computers'].items()
             if mac == macaddress]

    if len(names) == 0:
        # Name not found
        return ''
    else:
        # Name found
        return names[0]


def load_computers(first_name=None):
    """ Load save computer list
        If first_name is set
        it will be the first of the list
    """
    # Read configuration
    if not read_configuration():
        return []

    if 'computers' not in CONFIG.sections():
        return []

    # Prepare the computer list
    computers = CONFIG['computers']
    ret = []

    # Prepare the first element of the combobox
    if first_name is not None and first_name in computers.keys():
        ret.append({'name': first_name,
                    'value': computers.get(first_name),})

    # Complete the combobox
    for name, mac in computers.items():
        if first_name != name:
            ret.append({'name': name, 'value': mac})

    return ret


def save_computer(name, macaddress):
    """ Save computer name and mac in config file """
    # Read configuration
    if not read_configuration():
        return

    if not 'computers' in CONFIG:
        CONFIG['computers'] = {}

    macaddress = transform_mac(macaddress)

    CONFIG['computers'][name] = macaddress
    with open(CONFIG_FILE, 'w') as config_f:
        CONFIG.write(config_f)

    save_last_mac(macaddress)


def set_cover(name, side):
    """ Save a computer name as cover right or left """
    # Read configuration
    if not read_configuration():
        return

    if not 'covers' in CONFIG:
        CONFIG['covers'] = {}

    # delete if is the same
    if side in CONFIG['covers'] and CONFIG['covers'][side] == name:
        del CONFIG['covers'][side]
    else:
        CONFIG['covers'][side] = name

    with open(CONFIG_FILE, 'w') as config_f:
        CONFIG.write(config_f)


def delete_computer(name):
    """ Delete computer from config file """
    # Read configuration
    if not read_configuration():
        return False

    if not 'computers' in CONFIG:
        return False

    if not name in CONFIG['computers']:
        return False

    del CONFIG['computers'][name]

    with open(CONFIG_FILE, 'w') as config_f:
        CONFIG.write(config_f)

    # Get desktop file path
    desktop_file_name = get_desktop_file_name(name)
    desktop_file_path = os.path.join(os.getenv("HOME"),
                                     ".local/share/applications/",
                                     desktop_file_name)
    if has_desktop_file(name):
        os.remove(desktop_file_path)

    return True


def get_cover(side):
    """ Get COVER mac address from config file """
    # Read configuration
    if not read_configuration():
        return False

    if not 'covers' in CONFIG:
        return False

    if not side in CONFIG['covers']:
        return False

    mac = get_mac(CONFIG['covers'][side])
    if mac != '':
        # return mac address
        return mac

    return False


def wol_from_cover(side):
    """ Wake up from a cover """
    mac = get_cover(side)
    if mac is not False:
        wake_on_lan(mac)


def get_desktop_file_name(name):
    """ Determine desktop file name """
    return "seafile-" + name + ".desktop"


def set_desktop_file(name):
    """ Create or delete a desktop file """
    # Prepare file content
    data = {}
    data['name'] = name
    data['mac'] = get_mac(name)
    data['icon'] = "harbour-seadevil"
    data['exec'] = ("""python /usr/share/harbour-seadevil/scripts/"""
                    """seadevil-cli.py "%(mac)s" "%(name)s" """ % data)
    data['comment'] = ("""Seafile shortcut desktop file for """
                       """%(name)s/%(mac)s""" % data)

    # Get desktop file path
    desktop_file_name = get_desktop_file_name(name)
    desktop_file_path = os.path.join(os.getenv("HOME"),
                                     ".local/share/applications/",
                                     desktop_file_name)

    if not has_desktop_file(name):
        # Write file
        content = ("[Desktop Entry]\n"
                   "Type=Application\n"
                   "Name=%(name)s\n"
                   "Icon=%(icon)s\n"
                   "Exec=%(exec)s\n"
                   "Comment=%(comment)s\n" % data)
        desktop_fh = open(desktop_file_path, "w")
        desktop_fh.write(content)
        desktop_fh.close()
    else:
        # Delete file
        os.remove(desktop_file_path)


def has_desktop_file(name):
    """ Check if a desktop file existe """
    desktop_file_name = get_desktop_file_name(name)
    desktop_file_path = os.path.join(os.getenv("HOME"),
                                     ".local/share/applications/",
                                     desktop_file_name)
    return os.path.exists(desktop_file_path)
