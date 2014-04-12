#!/bin/sh -e

## 1. boot the BeagleBoard

## then check /var/log/syslog for the IP address of the device
## grep DHCPACK /var/log/syslog ...

bb_user="root"
## update as neccessary:
bb_ip="192.168.7.2"

local_fs=${PWD}

## 2. Get the board's kernel config info - /boot/config-$(uname -r)

BB_KVER="$(ssh ${bb_user}@${bb_ip} 'uname -r')"
echo ${BB_KVER} > kernel-version

## does not exist
# scp t ${bb_user}@${bb_ip}/boot/config-${BB_KVER} \
#         ${local_fs}/config-${BB_KVER}

## 3. Create and retrieve list of packages installed
##
## (dpkg not available on angstrom)
##
# ssh ${bb_user}@${bb_ip} "dpkg -l | grep ^i | awk '{print $2}'" \
#         > ${local_fs}/packages.list

## 4. Retrieve LSWH's userspace view of the hardware
##
## (aptitutde not aavailable on angstrom)
##
# ssh ${bb_user}@${bb_ip} "aptitude install lshw" &&
#         ssh ${bb_user}@${bb_ip} "sudo lshw -xml" \
#                 > ${local_fs}/lshw-beagleboard.xml

## 5. retrieve LSB distro information (if available)

ssh ${bb_user}@${bb_ip} "lsb_release -a" \
        > ${local_fs}/lsb_release.txt 2>&1
