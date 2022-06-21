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
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y default-jre geogebra gimp vlc mumble keepass2 audacity geany obs-studio openscad krita krita-l10n vim pwgen sl neovim curl youtube-dl gparted telegram-desktop inkscape guvcview ksnip

# Install packages that are missing despite the apt install step with check-language-support
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y hunspell-en-au hunspell-en-ca hunspell-en-gb hunspell-en-za hyphen-en-ca hyphen-en-gb libreoffice-help-en-gb libreoffice-l10n-en-gb libreoffice-l10n-en-za mythes-de-ch mythes-en-au hunspell-en-ca hunspell-en-gb hunspell-en-za hyphen-en-ca hyphen-en-gb libreoffice-help-en-gb libreoffice-l10n-en-gb libreoffice-l10n-en-za mythes-de-ch mythes-en-au
# Install russian base packages
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y gnome-user-docs-ru hunspell-ru hyphen-ru language-pack-gnome-ru language-pack-gnome-ru-base language-pack-ru language-pack-ru-base libreoffice-help-ru libreoffice-l10n-ru mythes-ru thunderbird-locale-ru
# Install ukrainian base packages
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y gnome-user-docs-uk hunspell-uk hyphen-uk language-pack-gnome-uk language-pack-gnome-uk-base language-pack-uk language-pack-uk-base
# Ask check-language-support to install packages not covered above
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y language-selector-common
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y $(fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" check-language-support --language=uk)
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y $(fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" check-language-support --language=ru)
fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" apt-get install -y $(fakechroot chroot "$SQUASHFS_EXTRACTED_DIR" check-language-support)
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
