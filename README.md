# heyalter-ubuntu-iso

The (hopefully soon) official release of the heyalter ubuntu

## Contents

- Ubuntu LTS 20.04.1 (ubuntu-20.04.1-desktop-amd64)
- Chromium snap-revision: 1411 timestamp: 2020-11-18T12:17:04.182003Z
- Additional software: gimp vlc mumble enigmail keepass2
- addtional setting: MUST BE TESTED
    - ubuntu.seed:
    - Low Level Format
    - d-i s390-dasd/auto-format boolean true
    - d-i s390-dasd/force-format boolean true



## Local build scripts

To build the iso image locally you can use the commands below:

```bash
# run the build in a docker container
docker run -it --rm -v ${PWD}:/heyalter -w "/heyalter" --name heyalter-iso ubuntu:focal ./build-local.sh

# setup everything and get a shell in a container
docker run -it --rm -v ${PWD}:/heyalter -w "/heyalter" --name heyalter-iso ubuntu:focal
```

## USB Stick for plain Ubuntu Installations
- burn heyalter_post_install_plain_ubuntu.iso to an usb stick
- plug it to a fresh installed plain ubuntu box
- open the "heyalter" volume
- right click: "In Terminal öffnen"
- type "./setup-lokal.sh"
- accept pop-up terminal with root password (schule)