#! /bin/bash

#
# must be run as root
#

if [ $UID -ne 0 ]; then
   sudo $0 $BINDIR
   exit $?
fi

# Potentielle HDD aufsetzen

HDD=$(lsblk -do path,rota,hotplug,type | grep '1       0 disk' | cut -d' ' -f1)

ALREADY_MOUNTED=$(mount | grep "$HDD" || true)
if [ ! -z "$HDD" ] && [ -z "$ALREADY_MOUNTED" ]
then
  echo Creating HDD partition table >> /tmp/HDD.txt
  fdisk $HDD << FDISK_CMDS
g
n
1


w
FDISK_CMDS

  echo Formatting HDD >> /tmp/HDD.txt
  mkfs.ext4 $HDD'1'

  echo 'Creating mountpoint' >> /tmp/HDD.txt
  sudo mkdir -p /media/data

  echo 'Getting UUID' >> /tmp/HDD.txt
  UUIDvalue=$(sudo blkid $HDD'1' -s UUID -o value)
  echo $UUIDvalue

  echo 'Adding entry to fstab' >> /tmp/HDD.txt
  echo "UUID=$UUIDvalue	/media/data	ext4	rw,auto,users	0	2" | sudo tee -a /etc/fstab

  echo 'Mount new partition' >> /tmp/HDD.txt
  sudo mount -a

  echo 'fix permissions' >> /tmp/HDD.txt
  sudo chmod 777 /media/data

  zenity --text-info --filename /tmp/HDD.txt

fi
