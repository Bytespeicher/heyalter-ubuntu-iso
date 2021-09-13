#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# define variables
DOWNLOAD_URL="https://releases.ubuntu.com/20.04/ubuntu-20.04.3-desktop-amd64.iso"
BUILD_DIR="build"
ISO_EXTRACTED_DIR="${BUILD_DIR}/extracted-iso"
ISO_MOUNT_DIR="${BUILD_DIR}/extracted-iso"
SQUASHFS_EXTRACTED_DIR="${BUILD_DIR}/squashfs"
TODAY="$(date +'%Y%m%d')"
ISO_FILENAME="${BUILD_DIR}/ubuntu-20.04.3.iso"
ISO_VOLUME_ID="heyalter-${TODAY}-${CI_PIPELINE_IID}"
IMAGE_NAME="heyalter-${CI_COMMIT_REF_NAME}-${TODAY}-b${CI_PIPELINE_IID}-${CI_COMMIT_SHORT_SHA}.iso"
IMAGE_META_NAME="${IMAGE_NAME/\.iso/.release.txt}"
BUILDINFO_LOG="artifacts/buildinfo.log"
ARTIFACTS_DIR="$(pwd)/artifacts"

export DEBIAN_FRONTEND="noninteractive"
export TZ="Europe/Berlin"

log () {
  delimiter="##########"
  printf "\n\n${delimiter} $1 ${delimiter}\n"
}

log "prepare env"
for directory in $BUILD_DIR $ISO_EXTRACTED_DIR $ISO_MOUNT_DIR $ARTIFACTS_DIR
do
  if [ ! -e "$directory" ]
  then
    echo creating $directory
    mkdir $directory
  fi
done

# write heyalter-release file
tee $ARTIFACTS_DIR/${IMAGE_META_NAME} << EOF
BUILD_DATE=$TODAY
BASE_IMAGE_URL=$DOWNLOAD_URL
IMAGE_NAME=$IMAGE_NAME
EOF
env | grep -e CI_PIPELINE_IID \
           -e CI_COMMIT_REF_NAME \
           -e CI_COMMIT_SHORT_SHA \
           -e CI_JOB_URL \
           | tee -a $ARTIFACTS_DIR/${IMAGE_META_NAME}

# start subshell with ( ) grouping and write output to buildinfo.log
(
  # create buildinfo file
  log "build env"
  env

  ## install needed software
  log "installing software requirements"
  apt update -y && apt-get install -yq apt-rdepends git curl snapd debootstrap gparted squashfs-tools genisoimage p7zip-full wget fakeroot fakechroot syslinux-utils cargo xorriso

  ## download iso
  if [ ! -f "${ISO_FILENAME}" ]
  then
    log "Downloading ISO from $DOWNLOAD_URL"
    wget --quiet $DOWNLOAD_URL -O ${ISO_FILENAME}
  fi

  ## extract iso
  log "Extract iso to $ISO_EXTRACTED_DIR"
  7z x -o$ISO_EXTRACTED_DIR ${ISO_FILENAME}

  log "unsquash squashfs"
  fakeroot unsquashfs -d ${SQUASHFS_EXTRACTED_DIR} ${ISO_EXTRACTED_DIR}/casper/filesystem.squashfs
  #
  # rm -rf ${SQUASHFS_EXTRACTED_DIR}/{run,dev,proc,sys}
  #
  # echo "prepare bind mounts for chroot env"
  # ln -s /run/ ${SQUASHFS_EXTRACTED_DIR}/
  # ln -s /dev/ ${SQUASHFS_EXTRACTED_DIR}/
  #
  # ln -s /proc ${SQUASHFS_EXTRACTED_DIR}/
  # ln -s /sys ${SQUASHFS_EXTRACTED_DIR}/
  # #ln -s /dev/pts ${SQUASHFS_EXTRACTED_DIR}/dev/
  #

  log "installing software inside chroot"
  fakeroot fakechroot chroot ${SQUASHFS_EXTRACTED_DIR} add-apt-repository -y universe
  fakeroot fakechroot chroot ${SQUASHFS_EXTRACTED_DIR} add-apt-repository -y multiverse
  fakeroot fakechroot chroot ${SQUASHFS_EXTRACTED_DIR} add-apt-repository -y restricted
  fakeroot fakechroot chroot ${SQUASHFS_EXTRACTED_DIR} apt update -y
  fakeroot fakechroot chroot ${SQUASHFS_EXTRACTED_DIR} apt install -y default-jre geogebra gimp vlc mumble enigmail keepass2 audacity geany obs-studio openscad krita krita-l10n # gawk mawk  #
  fakeroot fakechroot chroot ${SQUASHFS_EXTRACTED_DIR} apt install -y vim pwgen sl neovim curl youtube-dl gparted # gawk mawk
  fakeroot fakechroot chroot ${SQUASHFS_EXTRACTED_DIR} apt clean

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

  log "Add our own Grub configuration"
  cp files/grubdefault ${SQUASHFS_EXTRACTED_DIR}/etc/default/grub

  log "Copying our files to the ISO"
  cp files/preseed/* ${ISO_EXTRACTED_DIR}/preseed/
  cp files/isolinux.cfg ${ISO_EXTRACTED_DIR}/isolinux/isolinux.cfg
  rm -f ${ISO_EXTRACTED_DIR}/boot/grub/grub.cfg
  cp files/grub.cfg ${ISO_EXTRACTED_DIR}/boot/grub/grub.cfg


  log "Homedir"
  cp -R files/homeschule ${SQUASHFS_EXTRACTED_DIR}/home/schule
  chown -R 1000:1000 ${SQUASHFS_EXTRACTED_DIR}/home/schule
  chmod -R 755 ${SQUASHFS_EXTRACTED_DIR}/home/schule/.config/

  log "Hey Alter release information"
  cp $ARTIFACTS_DIR/${IMAGE_META_NAME} ${SQUASHFS_EXTRACTED_DIR}/etc/heyalter-release

  log "Setup scripts"
  cp -R setup ${ISO_EXTRACTED_DIR}/
  ./tools/bashwrapper/convert.sh ${ISO_EXTRACTED_DIR}/setup/setuproot.sh
  ./tools/bashwrapper/convert.sh ${ISO_EXTRACTED_DIR}/setup/cleanuproot.sh
  ./tools/bashwrapper/convert.sh ${ISO_EXTRACTED_DIR}/setup/54KernelDebs/changeTo54KernelOffline.sh
  git clone https://gitli.stratum0.org/heyalter/desktop-mainline-kernel.git ${ISO_EXTRACTED_DIR}/setup/desktop-mainline-kernel
  rm -fR ${ISO_EXTRACTED_DIR}/setup/desktop-mainline-kernel/.git

  log "Persistent HA directory"
  cp -R heyalter ${ISO_EXTRACTED_DIR}/

  #
  #
  #
  # echo "cleanup needed before creating the squashfs"
  # fakeroot fakechroot chroot ${SQUASHFS_EXTRACTED_DIR} apt clean
  # rm -rf ${SQUASHFS_EXTRACTED_DIR}/tmp/* ${SQUASHFS_EXTRACTED_DIR}/root/.bash_history
  # rm -rf ${SQUASHFS_EXTRACTED_DIR}/{run,dev,proc,sys}
  # mkdir ${SQUASHFS_EXTRACTED_DIR}/{run,dev,proc,sys}

  log "After Install Script"
  cp -R files/homeschule ${ISO_EXTRACTED_DIR}/

  cp usb_after_install/* ${ISO_EXTRACTED_DIR}
  chown 1000:1000 ${ISO_EXTRACTED_DIR}/setup_lokal.sh


  log "Download Snaps"
  ./_download_snaps.sh ${ISO_EXTRACTED_DIR}/setup/snaps

  log "Download HEY-HILFE-Support-Handbuch.pdf"
  curl https://heyalter.com/wp-content/uploads/2021/02/HEY-HILFE-Support-Handbuch.pdf --output ${ISO_EXTRACTED_DIR}/setup/HEY-HILFE-Support-Handbuch.pdf --fail --location --max-time 60

  log " Download 5.4 Kernel"
  pushd ${ISO_EXTRACTED_DIR}/setup/54KernelDebs
  apt-get download $(apt-rdepends linux-image-generic | grep -v "^ " | sed 's/debconf-2.0/debconf/g')
  popd
) | tee -a $BUILDINFO_LOG

log "copy buildinfo.log to heyalter persistence dir"
cp $BUILDINFO_LOG ${ISO_EXTRACTED_DIR}/heyalter/

log "create squashfs"
chmod +w ${ISO_EXTRACTED_DIR}/casper/filesystem.manifest
fakeroot fakechroot chroot ${SQUASHFS_EXTRACTED_DIR} dpkg-query -W --showformat='${Package} ${Version}\n' > ${ISO_EXTRACTED_DIR}/casper/filesystem.manifest
cp ${ISO_EXTRACTED_DIR}/casper/filesystem.manifest ${ISO_EXTRACTED_DIR}/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' ${ISO_EXTRACTED_DIR}/casper/filesystem.manifest-desktop
sed -i '/casper/d' ${ISO_EXTRACTED_DIR}/casper/filesystem.manifest-desktop
sed -i '/gparted/d' ${ISO_EXTRACTED_DIR}/casper/filesystem.manifest-remove
rm ${ISO_EXTRACTED_DIR}/casper/filesystem.squashfs
mksquashfs ${SQUASHFS_EXTRACTED_DIR} ${ISO_EXTRACTED_DIR}/casper/filesystem.squashfs
printf $(du -sx --block-size=1 ${SQUASHFS_EXTRACTED_DIR} | cut -f1) > ${ISO_EXTRACTED_DIR}/casper/filesystem.size

log "prepare mbr"
dd if="$ISO_FILENAME" bs=1 count=446 of="$BUILD_DIR/mbr.bin"

log "prepare checksums"
pushd ${ISO_EXTRACTED_DIR}
rm -rf md5sum.txt
find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee md5sum.txt

log "mkisofs"
chmod -R a+rx,a-w .
find . -type l -delete
xorriso -as mkisofs -r -V "HeyAlter-$CI_COMMIT_SHORT_SHA" -cache-inodes -J -l -isohybrid-mbr "../mbr.bin" -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -o ${ARTIFACTS_DIR}/${IMAGE_NAME} .
