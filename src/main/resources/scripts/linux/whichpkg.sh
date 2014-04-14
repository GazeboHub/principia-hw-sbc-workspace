#!/bin/sh
#
# whichpkg.sh - determine which Debian package provides a shell command
#
# version 1.1
#
# dependencies:
#  deb:coreutils
#  deb:dpkg
#  deb:awk
#  deb:grep


do_query() {
        dpkg-query -S $1 2>/dev/null
}

print_pkg() {
        echo $1 | cut -d: -f1
}


P="$(which $1)"
PKG=$(do_query $P)

if [ -n "${PKG}" ]; then
    print_pkg "${PKG}"
    exit 0
else
    ## assume the command was installed cf. `update-alternatives`
    P_ACTUAL=$(update-alternatives --query "$1" |
                grep '^Value:' | awk '{print $2}')
    PKG_ACTUAL=$(do_query $P_ACTUAL)
    print_pkg "${PKG_ACTUAL}"
fi
