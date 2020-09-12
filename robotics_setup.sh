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
spatialPrint "Proceed if you have run basic.sh and changed directory to the parent folder of this script. [ENTER] to continue"
read dump

if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -ge 18 ]]; then  
    elif [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -eq 20 ]]; then
        echo "Noetic installation not supported. [ENTER] to install Melodic. Ctrl+C to exit installation."
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -
    execute sudo apt-get update -y
    sudo apt-get install ros-melodic-desktop-full -y # allowing output to be visible to understand what's going on.
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
    echo "source /opt/ros/melodic/setup.zsh" >> ~/.zshrc
    execute sudo apt-get install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential -y
    execute sudo apt-get install python-rosdep -y
    sudo rosdep init
    execute rosdep update
fi

echo "Visit https://www.arduino.cc/en/Main/Software and download Arduino IDE"

echo "Installation completed."