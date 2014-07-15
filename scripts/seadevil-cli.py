#!/usr/bin/python
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


import sys
import os

seadevil_libs_path = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                  '../')
sys.path.append(seadevil_libs_path)

import seadevil


if __name__ == '__main__':
    if len(sys.argv) != 3:
        # Prepare notification
        pre_title = "SeaDevil errors"
        pre_message = "SeaDevil launcher error"
        title = "SeaDevil launcher error"
        message = "Please delete this launcher"
        # Notify
        seadevil.dbus_notify(pre_title, pre_message, title, message)
    else:
        # Get message
        mac = sys.argv[1]
        name = sys.argv[2]
        # Prepare notification
        pre_title = "SeaDevil woke %s" % name
        pre_message = "Magic packet sent to %s" % name
        title = "SeaDevil woke %s" % name
        message = "Magic packet sent to %s" % name
        # Wake on lan
        seadevil.wake_on_lan(mac)
        # Notify
        seadevil.dbus_notify(name)
