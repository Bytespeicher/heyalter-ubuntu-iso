#!/bin/bash

## install needed software
log "installing software requirements"
apt-get update -y
apt-get install -yq apt-rdepends git curl snapd debootstrap gparted squashfs-tools genisoimage p7zip-full wget fakechroot syslinux-utils cargo xorriso fdisk
