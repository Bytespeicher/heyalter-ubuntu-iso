#!/bin/bash

#
# Abfrage Systemtyp; die Zeile die mit " " beginnt enthält die Information
#                          system                  Surface Laptop 2 (Surface_.... )
#                          system                  Surface Laptop (Surface_.... )
#

MODELL="$(sudo lshw -class system -short -quiet | grep '^ ' | sed -e 's,^[ ]*system[ ]*,,' | cut -f1-2 -d' ')"

case "${MODELL}" in 

# --------------------------------------------------------------------------
	"LIFEBOOK E559")
  cat << EOD > /home/schule/block_intel_vbtn.conf
#
# This modules interferes with the keyboard causing it to be unaccessible after shutdown & startup
# Do not load
#
blacklist intel_vbtn
EOD
  sudo mv /home/schule/block_intel_vbtn.conf  /etc/modprobe.d/
  ;;
# --------------------------------------------------------------------------
   "Surface Laptop")

#
# Anderer Bildschirmhintergrund
#

  gsettings set  org.gnome.desktop.background picture-uri file:///opt/heyalter/surface_los_gehts.png
  gsettings set  org.gnome.desktop.background picture-uri-dark file:///opt/heyalter/surface_los_gehts.png

  zenity --info --text "Microsoft Surface erkannt. Mit rechter Maustaste auf den Bildschirmhintergrund klicken, [Anzeigeeinstellungen] wählen und Skalieren auf 100% ändern"

# set fractional scaling & passende Cursor Größe
#
# gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
# gsettings set  org.gnome.desktop.interface cursor-size 32
# zenity --info --text "Microsoft Surface erkannt und fraktionale Skalierung gesetzt. Mit rechter Maustaste auf den Bildschirmhintergrund klicken und  [Anzeigeeinstellungen] wählen und Skalieren auf 150% ändern"

# set text scaling factor & passende Cursor Größe

  gsettings set  org.gnome.desktop.interface text-scaling-factor 1.50
  gsettings set  org.gnome.desktop.interface cursor-size 48

#
# Da die Surface Pakete nicht via HeyAlter Setup erreichbar sind wird die Verbindung unterbrochen und Freifunk genutzt
#
  NETZ="$(nmcli -g NAME c show --active)"

  if [ "$NETZ" == "HeyAlter Setup" ]; then
     
     nmcli c delete "$NETZ"

     sleep 2

     nmcli dev wifi connect 'Freifunk'

  fi 

#
# Aufruf der Paketinstallation für den Surface Kernel
#
  
  gnome-terminal --wait -- /opt/setup/setup_steps/surface_kernel.install

  ;;

esac
