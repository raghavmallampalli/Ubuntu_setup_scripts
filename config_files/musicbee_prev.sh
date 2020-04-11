#!/bin/bash
xdotool key --window $( xdotool search --limit 1 --all --pid $( pgrep MusicBee ) --name Musicbee ) ctrl+alt+i


