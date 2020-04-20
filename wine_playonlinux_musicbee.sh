#!/bin/bash

set -e

# To note: the execute() function doesn't handle pipes well
execute () {
	echo "$ $*"
	OUTPUT=$($@ 2>&1)
	if [ $? -ne 0 ]; then
        echo "$OUTPUT"
        echo ""
        echo "Failed to Execute $*" >&2
        exit 1
    fi
}

echo "Proceed if you have run all the other sh files and gone through this sh file. Ctrl+C and do so first if not. [ENTER] to continue."
read dump

# Anything involving wine involves a high failure rate. This may not (almost definitely will not) work out of the box.
# credits: https://getmusicbee.com/forum/index.php?topic=5338.30
execute sudo dpkg --add-architecture i386 
wget -nc https://dl.winehq.org/wine-builds/winehq.key -O- | sudo apt-key add -
sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' # for bionic. Not released for focal
sudo add-apt-repository ppa:cybermax-dexter/sdl2-backport # very poor solution, temporary. but it works.

wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -
sudo wget http://deb.playonlinux.com/playonlinux_bionic.list -O /etc/apt/sources.list.d/playonlinux.list # for bionic. Not released for focal
execute sudo apt-get update -y

# Dependencies installation
sudo apt-get install libgnutls30:i386 libldap-2.4-2:i386 libgpg-error0:i386 libxml2:i386 libasound2-plugins:i386 libsdl2-2.0-0:i386 libfreetype6:i386 libdbus-1-3:i386 libsqlite3-0:i386
echo "Allow mono and gecko to install at startup. Ensure one and only one MusicBeeSetup file is present in Downloads. [ENTER] to continue."
read dump
execute sudo apt-get install --install-recommends winehq-stable -y
execute sudo apt-get install winetricks coreutils -y
sh ./config_files/winefontssmoothing_en.sh
rm -r ~/.wine
WINEARCH=win32 WINEPREFIX=~/.wine wine wineboot
wine  ~/Downloads/MusicBeeSetup*
winetricks -q dotnet45 mfc42 xmllite gdiplus d3dx9 vcrun2008 wmp10

execute sudo apt-get install xterm playonlinux -y

# Setting up global hotkeys for MusicBee
echo "Run winecfg and change to Windows 10. Open MusicBee and change Player Output to DirectSound, Soundcard to Pulseaudio."
echo "If MusicBee does not play audio now Ctrl+C out of the script. [ENTER] to continue"
read dump
echo "[ENTER] to create global hotkeys for MusicBee. [q] to skip."; read tempvar;
if [[ $tempvar = 'q' ]]; then
    echo "Skipping"
else
    echo "Set up hotkeys in MusicBee preferences for play, next song and pause according to the shell scripts in ./config_files."
    execute cp ./config_files/musicbee_* ~/Documents/xdotool_scripts/
    execute python3 ./config_files/Shortcut_setter.py 'MusicBee Pause' "sh `realpath ~/Documents/xdotool_scripts/musicbee_pause.sh`" '<Control><Alt>o'
    execute python3 ./config_files/Shortcut_setter.py 'MusicBee Next' "sh `realpath ~/Documents/xdotool_scripts/musicbee_next.sh`" '<Control><Alt>p'
    execute python3 ./config_files/Shortcut_setter.py 'MusicBee Previous' "sh `realpath ~/Documents/xdotool_scripts/musicbee_prev.sh`" '<Control><Alt>i'
fi

echo "Installation completed. Also check out MiniLyrics"