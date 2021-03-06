#!/bin/sh
#
# imgflash_dd.sh - safely install active SD device contents to on-board MMC
#
# version 1.0
#
# dependencies:
#  sh:./mmcdevtype.sh
#  deb:mount
#  deb:grep
#  deb:awk
#  deb:sudo
#
# procedure:
#  1. scp *.sh debian@${B3_IP}
#  2. ssh debian@${B3_IP} "sh imgflash_dd.sh"
#  3. refer to "Next proceures," at end of script

BLKSZ=${1:-512}

THIS=$0

msg() {
    echo "$THIS: $@"
}

msg_err() {
        echo "$THIS: $@" 1>&2
}

err_fatal() {
    ECODE=$1
    shift
    msg_err "$@"
    exit $ECODE
}

checkmount() {
    mount | grep "^/dev/${1}" > /dev/null
}

DEV_MMC_SD=$(sh ./mmcdevtype.sh | grep 'SD$' | awk '{print $1}')

DEV_MMC_MMC=$(sh ./mmcdevtype.sh | grep 'MMC$' | awk '{print $1}')

if [ -z "${DEV_MMC_SD}" ]; then
        err_fatal 1 "no SD media mounted"
fi


for MMC in ${DEV_MMC_MMC}; do
        if checkmount $MMC; then
            msg "unmounting MMC medium ${MMC}"
            sudo umount "/dev/${MMC}"
        fi
done

for SD in ${DEV_MMC_SD}; do
        if checkmount $SD; then
            msg "remounting SD medium ${SD} as read-only"
            sudo mount -o remount,ro "/dev/${SD}"
        fi
done


SDDEV=""
MMCDEV=""

for DEVPATH in /sys/bus/mmc/devices/* ; do
        DEV=$(echo $DEVPATH | cut -d/ -f6)
        DEVTYPE=$(cat $DEVPATH/type)

        if [ "$DEVTYPE" = "SD" ]; then
                if [ -n "${SDDEV}" ]; then
                    ## "Unsupported hardware"
                    ## FIXME: Permit a command line arg to specify the SD device
                    err_fatal 1 "Found more than one SD device ${DEV} ${SDDEV}"
                else
                    ## fixme: assuming only one block device per DEV
                    SDDEV=$(ls -d /sys/bus/mmc/devices/${DEV}/block/* |
                                cut -d/ -f8)
                    msg "Using SD device ${SDDEV}"
                fi
        elif [ "$DEVTYPE" = "MMC" ]; then
                if [ -n "${MMCDEV}" ]; then
                    ## "Unsupported hardware"
                    ## FIXME: Permit a command line arg to specify the MMC device
                    err_fatal 1 "Found more than one MMC device ${DEV} ${MMCDEV}"
                else
                    MMCDEV=$(ls -d /sys/bus/mmc/devices/${DEV}/block/* |
                                cut -d/ -f8)
                    msg "Using MMC device ${MMCDEV}"
                fi
        else
                msg_err "unknown device type ${DEVTYPE}"
        fi
done


msg beginning DD operation
msg using: if=/dev/${SDDEV} of=/dev/${MMCDEV} bs=${BLKSZ}
dd if=/dev/${SDDEV} of=/dev/${MMCDEV} bs=${BLKSZ}

msg DD operation complete
msg Next procedures:
msg 1. Shutdown device main board
msg 2. Remove microSD
msg 3. Power up device main board
msg 4. Install parted
msg 5. resize mmcblk1p2
msg 6. Study rootfs

## NB: parted is not installed on the default rootfs image
