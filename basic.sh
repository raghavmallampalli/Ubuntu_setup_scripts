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
spatialPrint "Do not execute this file without reading it first and cd'ing to the parent folder of this script. If it exits without completing install run 'sudo apt --fix-broken install'. [ENTER] to continue."
read dump
# Speed up the process
# Env Var NUMJOBS overrides automatic detection
if [[ -n $NUMJOBS ]]; then
    MJOBS=$NUMJOBS
elif [[ -f /proc/cpuinfo ]]; then
    MJOBS=$(grep -c processor /proc/cpuinfo)
elif [[ "$OSTYPE" == "darwin"* ]]; then
	MJOBS=$(sysctl -n machdep.cpu.thread_count)
else
    MJOBS=4
fi

# Fixes time problems if Windows is installed on your PC alongside Ubuntu
execute timedatectl set-local-rtc 1 --adjust-system-clock
echo "Mount windows partitions at startup using 'sudo fdisk -l' and by editing /etc/fstab"


execute sudo apt-get update -y
execute sudo apt-get install build-essential curl g++ cmake cmake-curses-gui pkg-config checkinstall -y
execute sudo apt-get install libopenblas-dev liblapacke-dev libatlas-base-dev gfortran -y
execute sudo apt-get install git wget curl xclip -y
execute sudo apt-get install vim vim-gui-common -y # vim gnome adds system clipboard functionality
execute sudo apt-get install htop -y
execute sudo apt-get install run-one xbindkeys xbindkeys-config wmctrl xdotool -y
cp ./config_files/vimrc ~/.vimrc

# zsh is a shell that's better than bash. zim is a framework/plugin management system for it.
# a branched version of zim is being installed. read the branched version of the docs.
# Checks if zsh is partially or completely installed to remove the folders and reinstall it
spatialPrint "Setting up zsh + zim now"
zsh_folder=/opt/.zsh/
if [ -f ~/.zshrc ]; then
   cp -L ~/.zshrc ~/backup_zshrc
   echo ".zshrc backed up to ~/backup_zshrc. Deleting."
fi
if [[ -d $zsh_folder ]];then
	sudo rm -r /opt/.zsh/*
fi
rm -rf ~/.z*

execute sudo apt-get install zsh -y
sudo mkdir -p /opt/.zsh/ && sudo chmod ugo+w /opt/.zsh/
export ZIM_HOME=/opt/.zsh/zim
command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "${USER}"
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
echo "zmodule marzocchi/zsh-notify" >> ~/.zimrc
echo "run 'zimfw install' after reboot"
#git clone --recursive --quiet --branch zsh-5.2 https://github.com/zimfw/zimfw.git /opt/.zsh/zim
#ln -s /opt/.zsh/zim/ ~/.zim
#ln -s /opt/.zsh/zim/templates/zimrc ~/.zimrc
#ln -s /opt/.zsh/zim/templates/zlogin ~/.zlogin
#ln -s /opt/.zsh/zim/templates/zshrc ~/.zshrc
#git clone https://github.com/zsh-users/zsh-autosuggestions /opt/.zsh/zsh-autosuggestions
#echo "source /opt/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
# Change default shell to zsh

execute sudo apt-get install fonts-powerline aria2 -y

# Create bash aliases and link bash and zsh aliases
if [ -f ~/.bash_aliases ]; then
   cp -L ~/.bash_aliases ~/backup_bash_aliases
   echo "Bash aliases backed up to ~/backup_bash_aliases. Deleting."
fi
cp ./config_files/bash_aliases /opt/.zsh/bash_aliases
ln -s -f /opt/.zsh/bash_aliases ~/.bash_aliases

{
    echo "if [ -f ~/.bash_aliases ]; then"
    echo "  source ~/.bash_aliases"
    echo "fi"

    echo "# Switching to 256-bit colour by default so that zsh-autosuggestion's suggestions are not suggested in white, but in grey instead"
    echo "export TERM=xterm-256color"

    echo "# Setting the default text editor to code"
    echo "export VISUAL=/usr/bin/vim"
    echo "export EDITOR=/usr/bin/vim"

    echo "setopt nonomatch # allows name* matching in apt, ls etc. use with caution"
    echo "setopt SHARE_HISTORY"
} >> ~/.zshrc
echo "Edit .zshrc and change 'bindkey -e' to 'bindkey -v'"

# tmux set up.
execute sudo apt-get install tmux -y
git clone https://github.com/gpakosz/.tmux.git ~/.tmux
if [ -f ~/.tmux.conf ]; then
   cp -L ~/.tmux.conf ~/backup_tmux.conf
   echo ".tmux.conf backed up to ~/backup_tmux.conf. Deleting."
fi
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
if [ -f ~/.tmux.conf.local ]; then
   cp -L ~/.tmux.conf.local ~/backup_tmux.conf.local
   echo ".tmux.conf.local backed up to ~/backup_tmux.conf.local. Deleting."
fi
cp ./config_files/tmux.conf.local ~/.tmux.conf.local

# Install code editor of your choice
if [[ ! -n $CIINSTALL ]]; then
    read -p "Download and Install VS Code / Atom / Sublime. Press q to skip this. Default: Skip Editor installation [v/a/s/q]: " tempvar
fi
tempvar=${tempvar:-q}

if [ "$tempvar" = "v" ]; then
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    execute sudo apt-get install apt-transport-https -y
    execute sudo apt-get update -y
    execute sudo apt-get install code -y # or code-insiders
    execute rm microsoft.gpg
    execute code --install-extension Shan.code-settings-sync # extension that saves your installed extensions and settings to github
elif [ "$tempvar" = "a" ]; then
    execute sudo add-apt-repository ppa:webupd8team/atom
    execute sudo apt-get update -y; execute sudo apt-get install atom -y
elif [ "$tempvar" = "s" ]; then
    wget -q -O - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    execute sudo apt-get install apt-transport-https -y
    execute sudo apt-get update -y
    execute sudo apt-get install sublime-text -y
elif [ "$tempvar" = "q" ];then
    echo "Skipping this step"
fi

# installing octave, python3
execute sudo apt-get install octave -y # comment out if you have access to MATLAB. 

if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -lt 19 ]]; then  
    execute sudo apt-get install python-pip -y # 20.04 does not have python2 pip in repo.
fi

if [[ $(command -v conda) || (-n $CIINSTALL) ]]; then
    PIP="pip install"
else
    execute sudo apt-get install python3-dev python3-tk python3-setuptools -y
    if [[ ! -n $CIINSTALL ]]; then sudo apt-get install python3-pip; fi
    PIP="sudo pip3 install --upgrade" # add -H flag to sudo if this doesn't work
fi

execute $PIP jupyter notebook
execute $PIP jupyterlab # lab may not work, comment out if it doesn't
execute $PIP python-dateutil tabulate # basic libraries
execute $PIP matplotlib numpy scipy pandas h5py # standard scientific libraries
execute $PIP scikit-learn scikit-image # basic ML libraries
# execute $PIP keras tensorflow # ML libraries. Occupy large amounts of space.
# Also consider sage if you have no access to Mathematica. https://doc.sagemath.org/html/en/installation/binary.html 
echo "Remove backup files after copying required data into new files"
echo "Installation completed. Restart and install other scripts. Read them first. They are not yet fully tested."