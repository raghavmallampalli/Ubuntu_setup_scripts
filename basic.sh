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
spatialPrint "Do not execute this file without reading it first and changing directory to the parent folder of this script. If it exits without completing install run 'sudo apt --fix-broken install'."
echo "DO NOT RUN AS ROOT. SCRIPT WILL FAIL"
echo "To achieve maximum usability of aliases do not remove or move the scripts after installation. If you want to move the folder, do so before starting installation. [ENTER] to continue."
read dump
echo "Logging installation output to /tmp/installation.log"
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
if grep -q '[Mm]icrosoft' /proc/version; then
    echo "Cannot access timedatectl on WSL."
else
    execute timedatectl set-local-rtc 1 --adjust-system-clock
fi
echo "Mount windows partitions at startup using 'sudo fdisk -l' and by editing /etc/fstab"

execute sudo apt-get update -y
execute sudo apt-get install build-essential curl g++ cmake cmake-curses-gui pkg-config checkinstall automake -y
execute sudo apt-get install libopenblas-dev liblapacke-dev libatlas-base-dev gfortran -y
execute sudo apt-get install git wget curl xclip jq -y
execute sudo apt-get install vim -y # vim gnome adds system clipboard functionality
execute sudo apt-get install htop -y
execute sudo apt-get install run-one xbindkeys xbindkeys-config wmctrl xdotool -y
execute sudo apt-get install ruby-full -y
execute sudo apt-get install fonts-powerline aria2 -y
execute sudo gem install bundler
cp ./config_files/vimrc ~/.vimrc

# zsh is a shell that's better than bash. zim is a framework/plugin management system for it.
# a branched version of zim is being installed. read the branched version of the docs.
# Checks if zsh is partially or completely installed to remove the folders and reinstall it
spatialPrint "Setting up zsh + zim now"
if [ -f ~/.zshrc ]; then
    cp -L ~/.zshrc ~/backup_zshrc
    echo ".zshrc backed up to ~/backup_zshrc. Deleting."
fi
rm -rf ~/.z*
execute sudo apt-get install zsh -y
command -v zsh | sudo tee -a /etc/shells
# Install Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Create bash aliases and link bash and zsh aliases
if [ -f ~/.bash_aliases ]; then
    cp -L ~/.bash_aliases ~/backup_bash_aliases
    echo "Bash aliases backed up to ~/backup_bash_aliases. Deleting."
fi
# echo "Changing shell:"
# sudo chsh -s "$(command -v zsh)" "${USER}"
cp ./config_files/bash_aliases ~/.bash_aliases
[ -f ./config_files/zshrc.local ] && cp ./config_files/zshrc.local ~/.zshrc.local
cp ./config_files/zshrc.common ~/.zshrc.common
[ -f ./config_files/zshrc.local ] && echo "source ~/.zshrc.local" >> ~/.zshrc
echo "source ~/.zshrc.common" >> ~/.zshrc
cp ./config_files/Dracula.dircolors ~/

# tmux set up.
if [ -f ~/.tmux.conf ]; then
    cp -L ~/.tmux.conf ~/backup_tmux.conf
    echo ".tmux.conf backed up to ~/backup_tmux.conf. Deleting."
fi
# build dependencies
execute sudo apt-get install libevent-dev ncurses-dev build-essential bison pkg-config -y
rm -rf ~/tmux
# execute git clone https://github.com/tmux/tmux.git ~/tmux
# cd ~/tmux
spatialPrint "Installing tmux..."
execute sudo apt-get install tmux -y
# sh autogen.sh >> /tmp/installation.log
# sh configure  >> /tmp/installation.log && make >> /tmp/installation.log
# cd -
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp ./config_files/tmux.conf ~/.tmux.conf
echo "Press Ctrl+A I (capital I) on first run of tmux to install plugins."

# Install code editor of your choice
read -p "Download and Install VS Code Insiders / Atom / Sublime. Press q to skip this. Default: Skip Editor installation [v/a/s/q]: " tempvar
tempvar=${tempvar:-q}
if [[ $tempvar = v ]]; then
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    execute sudo apt-get install apt-transport-https -y
    execute sudo apt-get update -y
    execute sudo apt-get install code-insiders -y # or code
    execute rm microsoft.gpg
elif [[ $tempvar = a ]]; then
    execute sudo add-apt-repository ppa:webupd8team/atom
    execute sudo apt-get update -y; execute sudo apt-get install atom -y
elif [[ $tempvar = s ]]; then
    wget -q -O - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    execute sudo apt-get install apt-transport-https -y
    execute sudo apt-get update -y
    execute sudo apt-get install sublime-text -y
elif [[ $tempvar = q ]]; then
    echo "Skipping this step"
fi

# NodeJS installation
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
execute sudo apt-get install -y nodejs

# installing python 
read -p "Install miniconda? [y/n] " tempvar
if [[ $tempvar = y ]]; then
    tempvar=${tempvar:-n}
    if [ -d ~/miniconda3 ]; then
        read -p "miniconda3 installed in default location directory. delete/manually enter install location/quit [d/m/Ctrl+C]: " tempvar
        tempvar=${tempvar:-n}
        if [[ $tempvar = d ]]; then
            rm -rf ~/miniconda3
        elif [[ $tempvar = m ]]; then
            echo "Ensure that you enter a different location during installation."
        fi
    fi 
    wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod +x Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh
    ~/miniconda3/bin/conda init zsh
    rm Miniconda3-latest-Linux-x86_64.sh
fi

echo "GitHub and GitLab SSH Key addition: Follow instructions in https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent"
echo "https://github.com/settings/keys for GitHub"
echo "https://gitlab.com/profile/keys for GitLab"
echo "Do not enter a passphrase for your GitHub ssh key."

echo "Check the .bash_aliases and .zshrc files and remove any aliases/sources you do not need."
echo "Installation completed. Restart and install other scripts."
