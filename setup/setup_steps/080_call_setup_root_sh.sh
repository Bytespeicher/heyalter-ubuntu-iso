#!/bin/bash
#
BINDIR="/opt/setup"
#
# Update usw. soll in Terminal laufen mit root-Rechten
#

gnome-terminal --wait -- $BINDIR/setup_steps/update.installation $BINDIR
