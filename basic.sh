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
    echo "full_scripts_path=$PWD"
    echo "if [ -f ~/.bash_aliases ]; then"
    echo "  source ~/.bash_aliases"
    echo "fi"

    echo "# Switching to 256-bit colour by default so that zsh-autosuggestion's suggestions are not suggested in white, but in grey instead"
    echo "export TERM=xterm-256color"

    echo "# Setting the default text editor to vim"
    echo "export VISUAL=/usr/bin/vim"
    echo "export EDITOR=/usr/bin/vim"

    echo "setopt nonomatch # allows name* matching in apt, ls etc. use with caution"
    echo "[[ -a "/etc/zsh_command_not_found" ]] && . /etc/zsh_command_not_found"
    echo "setopt SHARE_HISTORY"

    echo "bindkey -v"
    echo "bindkey 'jj' vi-cmd-mode"
    echo "bindkey 'jk' vi-cmd-mode"
    echo "bindkey 'kk' vi-cmd-mode"
    echo "autoload edit-command-line; zle -N edit-command-line"
    echo "bindkey -M vicmd V edit-command-line"
    echo "# Check these lines if Ctrl+Arrow does not work on your terminal."
    echo "# To find which key binding will work, execture cat >/dev/null"
    echo "# and press the key combination you want."
    echo "bindkey \"^[[1;5C\" forward-word"
    echo "bindkey \"^[[1;5D\" backward-word"

    echo "export USER_COLOR=183"
    echo "export HOST_COLOR=222"
    echo "export PWD_COLOR=120"
    echo "export BRANCH_COLOR=159"
    echo "export UNINDEXED_COLOR=229"
    echo "export INDEXED_COLOR=120"
    echo "export UNTRACKED_COLOR=210"
    echo "export STASHED_IND=\$UNINDEXED_IND"
    echo "export STASHED_COLOR=231"

    echo "############################################"
    echo "# Following section must be at the bottom of the zshrc file. Move it to the end before restarting."
    echo "# adds an indicator for vi mode at terminal"
    echo "PS1+='\${VIMODE}' "
    echo "# 'I' for normal insert mode"
    echo "# 'N' for command mode"
    echo "function zle-line-init zle-keymap-select {"
    echo "    GIANT_N='%B%F{green}N%f%b '"
    echo "    GIANT_I='%BI%f%b '"
    echo "    VIMODE=\"\${\${KEYMAP/vicmd/\$GIANT_N}/(main|viins)/\$GIANT_I}\""
    echo "    zle reset-prompt"
    echo "}"
    echo "zle -N zle-line-init"
    echo "zle -N zle-keymap-select"
    echo "# automatically attaches 'General' if it exists and is not attached. Creates if it does not."
    echo "# If you do not wish to attach tmux in some programs find what env variable is set in terminals run within that program"
    echo "# and append that to first if block. eg. TERM_PROGRAM is set to vscode by VS Code"
    echo "if [ -z \${TERM_PROGRAM} -a -z \${TMUX} ]; then"
    echo "	tmux ls 2>/dev/null | grep 'General' >/dev/null"
    echo "	if [ \$? -eq 0 ]; then"
    echo "		tmux ls | grep 'General' | grep 'attached' >/dev/null"
    echo "		if [ \$? -eq 1 ]; then"
    echo "			tmux -u attach -t 'General'"
    echo "		fi"
    echo "	else"
    echo "		tgex"
    echo "	fi"
    echo "fi"
    echo "############################################"

} >> ~/.zshrc
echo "For vim bindings edit .zshrc and change 'bindkey -e' to 'bindkey -v'. Open .profile and copy the PATH changing commands to .zshrc"

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
    execute sudo apt-get install code-insiders -y # or code-insiders
    execute rm microsoft.gpg
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

echo "GitHub and GitLab SSH Key addition: Follow instructions in https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent"
echo "https://github.com/settings/keys for GitHub"
echo "https://gitlab.com/profile/keys for GitLab"
echo "Do not enter a passphrase for your GitHub ssh key."
echo "Check the .bash_aliases and .zshrc files and remove any aliases/sources you do not need."
echo "Installation completed. Restart and install other scripts. Read them first. They are not yet fully tested."

