#!/usr/bin/env python
# -*- coding: utf-8 -*-


import socket
import struct

def wake_on_lan(macaddress):
    """ Switches on remote computers using WOL. """

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
    sock.sendto(send_data, ('<broadcast>', 7))
    

if __name__ == '__main__':
    # Use macaddresses with any seperators.
    wake_on_lan('0F:0F:DF:0F:BF:EF')
    wake_on_lan('0F-0F-DF-0F-BF-EF')
    # or without any seperators.
    wake_on_lan('0F0FDF0FBFEF')
