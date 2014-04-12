#!/bin/sh

## original file:
## http://beagleboard.org/static/Drivers/Linux/FTDI/mkudevrule.sh
##
## see also:
## http://beagleboard.org/Getting+Started

UDEV_F=73-beaglebone.rules
UDEV_D=/etc/udev/rules.d/

sudo install -C -b -g root -m "u=rw,g=r,o=r" "${UDEV_F}" "${UDEV_D}"
sudo udevadm control --reload-rules
