#!/bin/bash


arecord|aplay &
PID=$!

zenity --info --text "Audio Test ist gestartet. Du solltest ein Echo hören. OK klicken um Audio-Test zu beenden"

kill $PID
