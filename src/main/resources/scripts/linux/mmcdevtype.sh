#!/bin/sh
#
# mmcdevtype.sh - determine type of storage media for mounted MMC devices
#
# version 1.0
#

for MMCBLKDEV in $(mount  | grep '^/dev/mmcblk' |
    awk '{print $1}' | cut -d/ -f3 ); do

    P="$(ls -d /sys/bus/mmc/devices/*/block/*0/$MMCBLKDEV 2>/dev/null)"

    if [ -n "$P" ]; then
        DEV="$(echo $P | cut -d/ -f6)";
        TYPE="$(cat /sys/bus/mmc/devices/$DEV/type)"
        echo $MMCBLKDEV $TYPE
    fi;
done
