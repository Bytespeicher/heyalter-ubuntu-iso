#!/bin/bash

# Rechte der kopierten Dateien fixen
gnome-terminal --wait -- bash -c "sudo /opt/setup/setuproot.sh 2>&1 | tee -a /tmp/hey_alter_setup.log"