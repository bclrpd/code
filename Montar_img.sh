#!/bin/sh                                          

# montar y desmontar memoria sd directamente
# sudo mount -t ext4 /dev/sda2 /media/usb
# sudo umount /media/usb

OPTION=$1
IMG_FILE=$2

CWD=`pwd`
MOUNT_POINT=$CWD/img

IMG_DIR=$(basename "$IMG_FILE")
IMG_DIR="${IMG_DIR%.*}"

if [[ ( "$#" -lt 2 ) || ( "$1" != "m" && "$1" != "u" && "$1" != "f"  ) ]]
  then
    echo "Please use script as follow:"
    echo ""
    echo '> $0 m|u <disk_img_file>'
    echo "     m - mount"
    echo "     u - umount"
    echo "     f - fdisk it"
    exit 1
fi

if [[ ("$1" == "m" || "$1" == "f") ]]
  then
    #SECTOR_OFFSET=$(sudo /sbin/fdisk -lu $IMG_FILE | awk '$6 == "Linux" { print $2 }')
    SECTOR_OFFSET=$(sudo /sbin/fdisk -lu $IMG_FILE | grep "Linux" | awk '{ print $2 }')
    BYTE_OFFSET=$(expr 512 \* $SECTOR_OFFSET)
    #SECTOR_OFFSET_BOOT=$(sudo /sbin/fdisk -lu $IMG_FILE | awk '$6 == "W95" { print $2 }')
    SECTOR_OFFSET_BOOT=$(sudo /sbin/fdisk -lu $IMG_FILE | grep "W95" | awk '{ print $2 }')
    BYTE_OFFSET_BOOT=$(expr 512 \* $SECTOR_OFFSET_BOOT)

    echo Mounting image / at $MOUNT_POINT/$IMG_DIR
    echo Sector offset $SECTOR_OFFSET - Byte offset $BYTE_OFFSET

    if [[ "$1" == "m" ]];then
        sudo mkdir -p $MOUNT_POINT/$IMG_DIR
        sudo mount -t ext4 -o loop,offset=$BYTE_OFFSET $IMG_FILE $MOUNT_POINT/$IMG_DIR

        echo Sector offset $SECTOR_OFFSET_BOOT - Byte offset $BYTE_OFFSET_BOOT
        echo Mounting image /boot at $MOUNT_POINT/${IMG_DIR}_boot

        sudo mkdir -p $MOUNT_POINT/${IMG_DIR}_boot
        sudo mount -t vfat -o loop,offset=$BYTE_OFFSET_BOOT $IMG_FILE $MOUNT_POINT/${IMG_DIR}_boot
    else

        sudo losetup -o $BYTE_OFFSET /dev/loop999 $IMG_FILE
        sudo fsck -t ext4 /dev/loop999
        sudo losetup -d /dev/loop999
    fi
    
fi

if [[ "$1" == "u" ]]
  then

    echo Unmounting image / at $MOUNT_POINT/$IMG_DIR
    sudo umount $MOUNT_POINT/$IMG_DIR
    sudo rmdir $MOUNT_POINT/$IMG_DIR

    echo Unmounting image /boot at $MOUNT_POINT/${IMG_DIR}_boot
    sudo umount $MOUNT_POINT/${IMG_DIR}_boot
    sudo rmdir $MOUNT_POINT/${IMG_DIR}_boot

fi

