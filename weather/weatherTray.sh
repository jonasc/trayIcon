#!/bin/bash

DIR=`dirname $0`

tempDir=`mktemp -d`
mkfifo $tempDir/condition
mkfifo $tempDir/temperature

# We work with fds in order not to close the pipes
exec 4<>$tempDir/condition
~/src/trayIcon/trayIcon < $tempDir/condition &
pidCond=$!
exec 5<>$tempDir/temperature
~/src/trayIcon/trayIcon < $tempDir/temperature &
pidTemp=$!

function rmTempDir() {
    echo "Killing tray icons"
    kill $pidTemp $pidCond
    echo "Removing $tempDir"
    rm -rf $tempDir
    exit
}

trap "rmTempDir" 2

while true; do
    IFS="	" read temperature condition icon < <(python2 $DIR/weathercli.py 10245) 
    condition=$(echo $condition | tr -d '"')
    normCondition=$(echo $condition | tr ' ' '_')
    condition=$(echo $condition | sed -r 's/(.)/\u\1/')

    # Condition icon
    condIcon=$DIR/icons/${normCondition}.png
    if [ -f $condIcon ]; then
        echo icon $condIcon
    else
        echo icon $DIR/icons/unknown.png
        echo $condIcon >> $DIR/missingIcons
    fi 1>&4
    echo tooltip $condition, $temperature° 1>&4

    # Temperature icon
    tempIcon=$DIR/temperature.png
    convert -size 16x16 -background none \
        -font /usr/share/texmf-dist/fonts/truetype/public/dejavu/DejaVuSerif.ttf \
        -fill white -pointsize 10 -gravity center label:"$temperature°" $tempIcon
    echo icon $tempIcon 1>&5
    echo tooltip $condition, $temperature° 1>&5

    sleep $((30*60))
done
