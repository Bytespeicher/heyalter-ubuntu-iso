#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# We should be in the scripts dir, so go to the base repo dir
cd ..

# define variables
if [[ ! -v CI_COMMIT_SHORT_SHA ]]; then
	export CI_COMMIT_SHORT_SHA="$(git rev-parse --short HEAD)"
fi
if [[ ! -v CI_COMMIT_REF_NAME ]]; then
	export CI_COMMIT_REF_NAME="$(git branch --show-current)"
fi
if [[ ! -v CI_PIPELINE_IID ]]; then
	export CI_PIPELINE_IID=localbuild
fi
DOWNLOAD_URL="https://releases.ubuntu.com/22.04/ubuntu-22.04.4-desktop-amd64.iso"
BUILD_DIR="$(pwd)/build"
ISO_EXTRACTED_DIR="$BUILD_DIR/extracted-iso"
ISO_MOUNT_DIR="$BUILD_DIR/extracted-iso"
SQUASHFS_EXTRACTED_DIR="$BUILD_DIR/squashfs"
TODAY="$(date +'%Y%m%d')"
ISO_FILENAME="ubuntu-22.04.iso"
ISO_VOLUME_ID="heyalter-$TODAY-$CI_PIPELINE_IID"
IMAGE_NAME="heyalter-$CI_COMMIT_REF_NAME-$TODAY-b$CI_PIPELINE_IID-$CI_COMMIT_SHORT_SHA.iso"
IMAGE_META_NAME="${IMAGE_NAME/\.iso/.release.txt}"
ARTIFACTS_DIR="$(pwd)/artifacts"
BUILDINFO_LOG="$ARTIFACTS_DIR/buildinfo.log"

export DEBIAN_FRONTEND="noninteractive"
export TZ="Europe/Berlin"

log () {
  delimiter="##########"
  printf "\n\n${delimiter} $1 ${delimiter}\n"
}
