#!/bin/bash

# FirstBoot Script zum Aufruf der setup.sh wieder löschen
rm -f /home/schule/.config/autostart/firstboot.desktop

#
# Stop Update Service
#
sudo systemctl stop unattended-upgrades.service
