#!/bin/bash

# Go to the scripts dir, no matter from which current location the script is called from
cd $(dirname "$0")
. env.sh


log "installing software inside chroot"
# fakechroot seems to copy/insert our /etc/passwd and /etc/group into the chroot, which messes package installation up, as it expects the geoclue user to exist
# Therefore we just do a hacky copy of the squashfs files to our system
cp "$SQUASHFS_EXTRACTED_DIR/etc/passwd" /etc/passwd
cp "$SQUASHFS_EXTRACTED_DIR/etc/group" /etc/group

fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" add-apt-repository -y universe
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" add-apt-repository -y multiverse
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" add-apt-repository -y restricted
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get update -y
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get remove -y cheese
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y default-jre geogebra gimp vlc mumble keepass2 audacity geany obs-studio openscad krita krita-l10n vim pwgen sl neovim curl youtube-dl gparted telegram-desktop inkscape guvcview ksnip nwipe nvme-cli smartmontools zenity
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y language-pack-gnome-uk hunspell-uk
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y language-pack-gnome-ru hunspell-ru
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get clean

log "Download ata-secure-erase.sh"
SECURE_ERASE_PATH=$SQUASHFS_EXTRACTED_DIR/usr/local/sbin/ata-secure-erase.sh
curl https://github.com/TigerOnVaseline/ata-secure-erase/raw/master/ata-secure-erase.sh --output "$SECURE_ERASE_PATH" --fail --location --max-time 60
chmod +x $SECURE_ERASE_PATH

log "Fixing broken symlinks"
FULL_SQFS_EXTRACTED_DIR=`realpath $SQUASHFS_EXTRACTED_DIR`
fixsymlinks() {
  for filename in ${FULL_SQFS_EXTRACTED_DIR}$1/*; do
    if  [[ `readlink $filename` =~ ^$FULL_SQFS_EXTRACTED_DIR ]] ;
    then
      echo $filename
      link=`readlink $filename`
      ln -sf ${link/$FULL_SQFS_EXTRACTED_DIR/} $filename
    fi
  done
}
fixsymlinks /usr/bin
fixsymlinks /etc/alternatives
