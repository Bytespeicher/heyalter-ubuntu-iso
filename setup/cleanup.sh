#!/bin/bash
#
# das große Aufräumen; nur wenn setup_done gesetzt ist.
#

if [ ! -f /opt/setup/setup_done ]
then
  zenity --warning --text "Erst setup.sh ausführen!" --width 512
  exit 2
fi
#
# Lösche die alten Desktop Einträge incl. trust
#
rm ~/.config/autostart/trust.desktop
rm ~/Schreibtisch/*.desktop

#
# setze die neuen Einträge
#
cp /opt/setup/heyalterhelp.desktop ~/Schreibtisch
gio set ~/Schreibtisch/heyalterhelp.desktop "metadata::trusted" true

# HEY-HILFE-Support-Handbuch.pdf is downloaded to /setup in build.sh
cp /opt/setup/HEY-HILFE-Support-Handbuch.pdf ~/Schreibtisch

#
# Screensaver und Lock-Screen reaktivieren
#
gsettings set org.gnome.desktop.screensaver lock-enabled 'true'
gsettings set org.gnome.desktop.lockdown disable-lock-screen 'false'
gsettings set org.gnome.desktop.session idle-delay 300

#
# zeige nach reboot bei erster verbindung die wilkommen-seite
#
systemctl enable --user heyalter.service

#
# Lösche Setup Verzeichnis
#
sudo rm -r /opt/setup

#
# WLAN Einstelllungen entfernen
#
sudo rm -f /etc/NetworkManager/system-connections/*

#
# AutoLogin wieder deaktivieren
#
sudo sed -i 's/AutomaticLogin/#AutomaticLogin/g' /etc/gdm3/custom.conf
