#!/bin/bash

set -e

spatialPrint() {
    echo ""
    echo ""
    echo "$1"
	echo "================================"
}

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

echo "Proceed if you have run basic.sh and gone through this sh file. Also make sure you know how to delete added repositories. Ctrl+C and do so first if not. [ENTER] to continue."
read dump

curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add - # check if the file remains post installation
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo add-apt-repository multiverse
sudo add-apt-repository ppa:hluk/copyq
wget -qO- http://repo.vivaldi.com/stable/linux_signing_key.pub | sudo apt-key add - # check if the file remains post installation
execute sudo add-apt-repository "deb [arch=i386,amd64] http://repo.vivaldi.com/stable/deb/ stable main"
sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable
sudo add-apt-repository ppa:papirus/papirus
execute sudo apt-get update -y

spatialPrint "Tweaks, fonts, themes and extensions"

execute sudo apt-get install gnome-tweaks gnome-shell-extensions chrome-gnome-shell -y # Works for Mozilla, Chromium based, Opera 
echo "GNOME extensions: install GNOME shell extensions browser extension. Alt+F2, r, enter to restart gnome-shell after installing extensions."
echo "Check out Alternate-tab, Caffeine, CPU Power Manager, Steal My Focus"

execute sudo apt-get install libreoffice -y
execute sudo cp ./config_files/images_numix.zip /usr/lib/libreoffice/share/config/ # change theme from libreoffice settings
execute sudo apt-get install numix-gtk-theme papirus-icon-theme -y
gsettings set org.gnome.desktop.interface gtk-theme "Numix"
gsettings set org.gnome.desktop.interface icon-theme "Papirus" # modify .desktop files if you don't like icons

execute mkdir /usr/share/fonts/
execute sudo cp -r ./config_files/fonts /usr/share/fonts/
execute fc-cache - f -v #untested

spatialPrint "GUI programs"

execute sudo apt-get install vivaldi-stable -y # Chromium based browser. Buggy but feature intensive.
execute sudo apt-get install speedcrunch -y # Superior calculator
execute sudo apt-get install gimp inkspace -y # Photo editor, Vector image editor
execute sudo apt-get install hexchat -y # IRC client
execute sudo apt-get install spotify-client audacity -y
execute sudo apt-get install steam -y
execute sudo apt-get install copyq -y # Clipboard logger. Super useful.
echo "Change launch shortcut, add frequently typed stuff as pinned items. "
execute sudo apt-get install simplescreenrecorder -y
echo "Refer README to complete simplescreenrecorder setup. Cannot be done from terminal."
# check if latex installs automatically with below command
execute sudo apt-get install texmaker -y # GUI LaTex client
execute sudo apt-get install qbittorrent -y # The best torrent client

# IMPORTANT: VLC is a snap utility. Uncomment if you wish to install.
# Go to their site pages for deb package if you do not wish to use snap
# Also check out vlsub and subsync if you install vlc
# execute sudo snap install vlc -y

echo "Visit and install: "
echo "Master PDF Editor: https://code-industry.net/free-pdf-editor/" # NOT open source
echo "AutomaThemely: https://github.com/C2N14/AutomaThemely" # Change themes automatically at night

echo "Run calibreupdate after restarting. Install monstre icon theme, count pages, find duplicates, goodreads and goodreads sync plugins. Set up."
echo "MusicBee is the best offline music player created by man. It is only available for Windows. Try the wine...sh file next to install it."