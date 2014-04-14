#!/bin/sh
#
# whichpkg.sh - determine which Debian package provides a shell command
#
# version 1.0
#
# dependencies:
#  deb:dpkg

exec dpkg-query -S $(which $1)
