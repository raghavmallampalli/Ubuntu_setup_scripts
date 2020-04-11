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

echo "Proceed if you have run basic.sh and gone through this sh file. Ctrl+C and do so first if not. [ENTER] to continue."
read dump

execute sudo apt-get install pciutils -y
execute sudo apt-get install ranger -y # CLI file explorer
echo "Download and install Windscribe with binaries. https://windscribe.com/guides/linux#how-to Will be added to sh file when out of beta."

# dependencies for CLI OneDrive client
execute sudo apt-get install libcurl4-openssl-dev libsqlite3-dev libnotify-dev -y
echo "Visit and follow instructions in https://github.com/abraunegg/onedrive/blob/master/docs/INSTALL.md"
echo "Dependencies have been installed. Start from DMD installation"

# terminal command auto-correction.
execute sudo pip3 install thefuck
echo 'eval $(thefuck --alias f)' >> ~/.zshrc
echo 'eval $(thefuck --alias f)' >> ~/.bashrc

# ffmpeg
execute sudo apt-get install libhdf5-dev exiftool ffmpeg -y

# check out nvtop if you have a working nvidia GPU