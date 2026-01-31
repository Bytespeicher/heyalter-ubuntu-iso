#!/bin/bash

set -x

check_num_disks () {
  local NUM_DISKS=$(echo "$DISKDEV_LIST" | wc -l)
  if [ $NUM_DISKS -ne 1 ]; then

    zenity --warning --no-wrap --text="Anzahl der installierten Disks = $NUM_DISKS
Es muss genau eine Disk verfügbar sein. Installierte Disks:
$(ls -ogv /dev/disk/by-id/)

Trotzdem fortfahren mit $BOOTDEV ?"

    exit 1
  fi
}

populate_device_list () {
  local USBDEV_LIST="$(mktemp)"
  list-devices usb-partition | sed "s/\(.*\)./\1/" > "$USBDEV_LIST"
  DISKDEV_LIST="$(list-devices disk | grep -vf "$USBDEV_LIST")"
  check_num_disks
  BOOTDEV="$(echo "$DISKDEV_LIST" | head -n 1)"
}

wipe_nvme () {
  OUTPUT=$(nvme format --ses=1 --force $BOOTDEV 2>&1)
  RC=$?
  if [ $RC -eq 0 ]; then
    return 0
  fi

  zenity --info --no-wrap --text="Secure Erase nicht durchgeführt: Eventuell Frozen Security State?
Laptop wird in Suspend versetzt. Bitte danach wieder aufwecken!

Fehler:
$OUTPUT"

  systemctl suspend -i

  OUTPUT=$(nvme format --ses=1 --force $BOOTDEV 2>&1)
  RC=$?
  if [ $RC -eq 0 ]; then
    return 0
  fi

  return $RC
}

wipe_ata () {
  OUTPUT=$(ata-secure-erase.sh -f $BOOTDEV 2>&1)
  RC=$?
  if [ $RC -eq 0 ]; then
    return 0
  fi

  if [[ $OUTPUT =~ "security state is frozen" ]]; then

    zenity --info --no-wrap --text="Secure Erase nicht durchgeführt: Frozen Security State!
Laptop wird in Suspend versetzt. Bitte danach wieder aufwecken!"

    systemctl suspend -i

    OUTPUT=$(ata-secure-erase.sh -f $BOOTDEV 2>&1)
    RC=$?
    if [ $RC -eq 0 ]; then
      return 0
    fi
  fi

  return $RC
}

wipe_nwipe () {
  zenity --warning --no-wrap --text="Secure Erase nicht durchgeführt!
Fehler:
$OUTPUT

Fallback auf nwipe -m random"
  
  OUTPUT=$(nwipe -m random --nogui --verify=off --autonuke $BOOTDEV 2>&1)

  if [ $? -ne 0 ]; then
    zenity --error --no-wrap --text="nwipe nicht durchgeführt!
Fehler:
$OUTPUT

Installation wird abgebrochen, wenn SSD nicht bereits leer ist"
  fi
}

check_all_zero () {
  OUTPUT=$(nwipe -m verify --nogui --autonuke $BOOTDEV 2>&1)

  if [ $? -ne 0 ]; then

    zenity --error --no-wrap --text="SSD ist nicht leer!
Fehler:
$OUTPUT

Installation wird abgebrochen"

    exit 1
  fi
}

configure_install () {
  debconf-set partman-auto/disk "$BOOTDEV"
  debconf-set grub-installer/bootdev "$BOOTDEV"
}

main () {
  populate_device_list

  case "$BOOTDEV" in 
    *nvme*)
      wipe_nvme;; 
    *)
      wipe_ata;;
  esac

  # fallback
  if [ $RC -ne 0 ]; then
    wipe_nwipe
  fi

  check_all_zero
  configure_install
}

main