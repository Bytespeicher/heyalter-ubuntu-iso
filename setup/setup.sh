#!/bin/bash


# anzeigen der systemparameter

zenity --info --text "$(lshw -C memory)\n------------------------------------\nAnzahl Kerne: $(nproc)\n------------------------------------\n$(lshw -C cpu)" --width 1024

# Rechte der kopierten Dateien fixen
gnome-terminal --wait -- bash -c "/opt/setup/setuproot.sh"

# einstellen der favoriten
dconf write /org/gnome/shell/favorite-apps "['chromium_chromium.desktop', 'thunderbird.desktop', 'org.gnome.Nautilus.desktop', 'libreoffice-writer.desktop', 'libreoffice-calc.desktop', 'libreoffice-impress.desktop', 'org.gnome.Software.desktop']"


# zeige nach reboot bei erster verbindung die wilkommen-seite
systemctl enable --user heyalter.service

# richte das hintergrundbild ein
gsettings set org.gnome.desktop.background picture-uri 'file:///home/schule/Bilder/los_gehts.png'

cheese

eject

chromium

# optinale Skripte ausführen
for script in `ls /opt/setup/setup_extensions/*.sh`; do
   bash $script
done