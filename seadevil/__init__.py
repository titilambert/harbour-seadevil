#!/usr/bin/python3
__version__ = "0.7"
 

import socket
import struct
import sys
import os
import configparser

try:
    import pyotherside
except ImportError:
    import sys
    # Allow testing Python backend alone.
    print("PyOtherSide not found, continuing anyway!", file=sys.stderr)

    class pyotherside:
        def atexit(*args): pass
        def send(*args): pass
    sys.modules["pyotherside"] = pyotherside()


config_folder = "/home/nemo/.config/harbour-seadevil/"
config_file = os.path.join(config_folder, "config.ini")

# Create config folder
if not os.path.exists(config_folder):
    os.makedirs(config_folder)

if not os.path.isdir(config_folder):
    raise ("'%s' must be a folder" % config_folder)


config = configparser.ConfigParser()

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
        return
        raise ValueError('Incorrect MAC address format')

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
    except Exception(e):
        print(e.message)



def get_mac(name):
    try:
        config.read(config_file)
    except Exception(e):
        print(e.message)
        return ''

    if 'computers' not in config.sections():
        return ''

    return config['computers'][name]



def load_computers():
    try:
        config.read(config_file)
    except Exception(e):
        print(e.message)
        return []

    if 'computers' not in config.sections():
        return []

    computers = config['computers']
    ret = []
    for name, mac in computers.items():
        ret.append({'name': name, 'value': mac})
    return ret


def save_computer(name, macaddress):
    try:
        config.read(config_file)
    except Exception(e):
        print(e.message)
        return
    if not 'computers' in config:
        config['computers'] = {}

    if len(macaddress) == 12:
        macaddress = ":".join(map(lambda x,y: x + y,
                              macaddress[::2],
                              macaddress[1::2]))

    config['computers'][name] = macaddress
    with open(config_file, 'w') as config_f:
        config.write(config_f)

