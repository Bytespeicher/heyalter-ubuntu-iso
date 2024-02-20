# Changelog

All notable changes to this project will be documented in this file.

## 2024-02-20
### Change
- All console output will be writen to a log file (/tmp/hey_alter_setup.log)

## 2023-10-28
### Change
- Changed the background image to a more accessible one designed by Andreas Karnath

## 2023-08-20
### Change
- Updated the base image to Ubuntu 22.04.3
- A missing Webcam now doesn't abort the Setup script, but instead shows a warning
- A missing WLAN card now shows a warning
- Cut down the width of the CPU info text box

## 2023-02-06
### Change
- Splitted setup.sh to separate scripts
- Removed directory `setup_extensions` as custom scripts could be placed in the directory `setup_steps`

## 2022-06-03
### Add
- Added language pack for ukraine
- Added language pack for russia

## 2022-05-13
### Changed
- The heyalter service is now enabled in the Cleanup script instead of the Setup script
- The Safe Graphics boot entry now also does an autoinstall
- Removed the default password `schule`
- Improved the build documentation

### Added
- `ksnip` Package added
- Manual partitioning boot option

## 2022-05-02
### Changed
- ISO now uses Ubuntu 22.04 as a base
- Refactored the build process for faster debugging during the ISO development and removed obsolete stuff

### Added
- `guvcview` to test the webcam as a replacement for `cheese`
- Setup and Cleanup now have icons, as they needed to be converted to desktop files instead of bash scripts (see #34)

### Removed
- `cheese`, as it is currently bugged (see #39)
- `zoom-client`, as the snap doesn't work with Wayland and the problem is still unfixed since Ubuntu 21.10 (see #40)
  - The deb file from the official Zoom page works fine (but cannot be included, due to update problems)
- The 5.4 Kernel downgrade, as it is not possible anymore in Ubuntu 22.04 (and maybe not necessary anymore, see #36)

### Known Bugs
- Ubuntu 22.04 doesn't use ISOLINUX anymore and replaced it with grub
  - This may result in being unable to boot the ISO on a few devices
  - One solution may be to install the disk on another computer and then swap it back to the problematic computer

## 2022-02-22
### Changed
- Skip checkdisk (does not work on every machine)
- Call `setup.sh` after first boot automatically

## 2021-06-16
### Add
- Allowed sudo without password for initial setup
- Enabled AutoLogin for initial setup

## 2021-06-06
### Changed
- Added directory `setup_extensions` for custom scripts that are executed at the end of the `setup.sh`

## 2021-05-25
### Added
- Added curl,gparted,youtube-dl packets and HEY-HILFE-Support-Handbuch.pdf (moved from /opt/setup to Desktop with cleanup.sh)

## 2021-03-10
### Added
- Added teams-for-linux app because it should work better for some kids (login issues)

## 2021-02-26
### Changed
- The UEFI boot now also supports automatic installation
### Added
- After the cleanup script a HeyAlter Help icon should be created on the desktop

## 2021-02-22
### Changed
- Removed the password query in `setup.sh` and `changeTo54KernelOffline.sh`. Sudo is not required anymore
- Slightly different look of `setup.sh` and `cleanup.sh`, as these are now only symlinks

## 2021-02-17
### Fixed
- Krita in german language
- Geogebra fixed to start
