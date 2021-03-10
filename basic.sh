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
spatialPrint "Do not execute this file without reading it first and cd'ing to the parent folder of this script. If it exits without completing install run 'sudo apt --fix-broken install'."
echo "To achieve maximum usability of aliases do not remove or move the scripts after installation. If you want to move the folder, do so before starting installation. [ENTER] to continue."
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
execute sudo apt-get install git wget curl xclip jq -y
execute sudo apt-get install vim -y # vim gnome adds system clipboard functionality
execute sudo apt-get install htop -y
execute sudo apt-get install run-one xbindkeys xbindkeys-config wmctrl xdotool -y
execute sudo apt-get install ruby-full
execute sudo apt-get install fonts-powerline aria2 -y
execute gem install bundler
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
sudo chsh -s "$(command -v zsh)" "${USER}"
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
echo "zmodule softmoth/zsh-vim-mode" >> ~/.zimrc
echo "Execute 'zimfw install' after terminal restart"
# Create bash aliases and link bash and zsh aliases
if [ -f ~/.bash_aliases ]; then
    cp -L ~/.bash_aliases ~/backup_bash_aliases
    echo "Bash aliases backed up to ~/backup_bash_aliases. Deleting."
fi
cp ./config_files/bash_aliases ~/.bash_aliases
cp ./config_files/.zshrc.local ~/.zshrc.local
echo "source ~/.zshrc.local" >> ~/.zshrc
cp ./config_files/Dracula.dircolors ~/

# tmux set up. TEST
if [ -f ~/.tmux.conf ]; then
    cp -L ~/.tmux.conf ~/backup_tmux.conf
    echo ".tmux.conf backed up to ~/backup_tmux.conf. Deleting."
fi
# build dependencies
execute sudo apt-get install libevent-dev ncurses-dev build-essential bison pkg-config -y
git clone https://github.com/tmux/tmux.git ~/tmux
cd ~/tmux
sh autogen.sh
sh configure && make
cd -
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
elif [[ $tempvar = q ]];then
    echo "Skipping this step"
fi

# NodeJS installation
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
execute sudo apt-get install -y nodejs

# installing octave, python3
execute sudo apt-get install octave -y # comment out if you have access to MATLAB. 

if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -lt 19 ]]; then  
    execute sudo apt-get install python-pip -y # 20.04 does not have python-pip in repo.
fi

if [[ $(command -v conda) ]]; then
    PIP="pip install"
else
    execute sudo apt-get install python3-dev python3-tk python3-setuptools -y
    execute sudo apt-get install python3-pip
    PIP="sudo pip3 install --upgrade" # add -H flag to sudo if this doesn't work
fi

execute $PIP jupyter notebook
execute $PIP jupyterlab
execute $PIP python-dateutil tabulate # basic libraries
execute $PIP matplotlib numpy scipy pandas h5py seaborn # standard scientific libraries
execute $PIP plotly kaleido ipywidgets
execute $PIP scikit-learn scikit-image # basic ML libraries
# execute $PIP keras tensorflow # ML libraries. Occupy large amounts of space.
# Also consider sage if you have no access to Mathematica. https://doc.sagemath.org/html/en/installation/binary.html 
sudo jupyter labextension install @karosc/jupyterlab_dracula
sudo jupyter labextension install jupyterlab-plotly

# JuliaLang installation
wget https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.1-linux-x86_64.tar.gz -P ~/
tar zxvf ~/julia-1.5.1-linux-x86_64.tar.gz -C ~/
echo "export PATH=\"\$PATH:\$HOME/julia-1.5.1/bin\"" >> ~/.zshrc
echo "To use Julia with Jupyter Notebook https://github.com/JuliaLang/IJulia.jl#quick-start"

echo "Remove backup files after copying required data into new files"

echo "GitHub and GitLab SSH Key addition: Follow instructions in https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent"
echo "https://github.com/settings/keys for GitHub"
echo "https://gitlab.com/profile/keys for GitLab"
echo "Do not enter a passphrase for your GitHub ssh key."
echo "Check the .bash_aliases and .zshrc files and remove any aliases/sources you do not need."
echo "Installation completed. Restart and install other scripts. Read them first. They are not yet fully tested."
