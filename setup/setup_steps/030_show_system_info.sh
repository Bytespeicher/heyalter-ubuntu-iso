#!/bin/bash

# anzeigen der systemparameter

CPU=$(cat /proc/cpuinfo | egrep "model name|MHz" | sort -u -r)
MEM=$(lsmem | tail -2 | head -1)

zenity --info --text "\nAnzahl Kerne\t: $(nproc)\n${CPU}\n------------------\n${MEM}\n"

