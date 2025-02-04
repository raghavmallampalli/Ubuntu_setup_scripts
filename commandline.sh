#!/bin/bash

set -e

# 
spatialPrint() {
    echo ""
    echo ""
    echo "$1"
    echo "================================"
}

# To note: the execute() function doesn't handle pipes well
execute () {
    echo "$ $*"
    OUTPUT=$($@ &>>/tmp/installation.log)
    if [ $? -ne 0 ]; then
        echo "$OUTPUT"
        echo ""
        echo "Failed to Execute $*" >&2
        exit 1
    fi
}

# Backup the file to /tmp and delete it
backup_and_delete() {
  # check if the file exists and is a regular file
  if [ ! -e "$1" ]; then
    echo "$1 does not exist"
    return 0
  fi

  if [ ! -f "$1" ]; then
    echo "$1 is a symbolic link. Deleting."
    rm "$1"
    return 0
  fi

  # copy the file to /tmp with the same name
  cp -L "$1" "/tmp/$(basename $1)"

  # check if the copy was successful
  if [ $? -eq 0 ]; then
    echo "Copied $1 to /tmp/$(basename $1)"
  else
    echo "Failed to copy $1 to /tmp/$(basename $1)"
    return 3
  fi

  # delete the original file
  rm "$1"

  # check if the deletion was successful
  if [ $? -eq 0 ]; then
    echo "Deleted $1"
  else
    echo "Failed to delete $1"
    return 4
  fi
}

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
echo "Do not execute this file without reading it first and changing directory to the parent folder of this script."
echo "If it exits without completing install run 'sudo apt --fix-broken install'."
echo "DO NOT RUN AS ROOT. SCRIPT WILL FAIL. Continue?"
# echo "To achieve maximum usability of aliases do not remove or move the scripts after installation. If you want to move the folder, do so before starting installation. [ENTER] to continue."
read dump

echo "==================" >> /tmp/installation.log
date >> /tmp/installation.log
echo "Logging installation output to /tmp/installation.log" # TODO: does this work

read -p "Do you have sudo access? [y/n] " HAS_SUDO
read -p "Enter email ID: (used for git and ssh key generation) " email
read -p "Enter git username:" git_username
read -p "Configure global git username and email? [y/n] " CONFIG_GIT
read -p "Replace dotfiles? Read script to see which files will be replaced. [y/n] " REPLACE_DOTFILES

mkdir -p ~/.local/bin

if [ ! -w "$HOME/.local/bin" ]; then
    echo "Cannot write to ~/.local/bin"
    exit 1
fi

######################################### BASIC PROGRAMS ##########################################

# Fixes time problems if Windows is installed on your PC alongside Ubuntu
if grep -q '[Mm]icrosoft' /proc/version; then
    echo "Cannot access timedatectl on WSL."
else
    read -p "Set hardware clock to local time? [y/n] " SET_LOCAL_TIME
    if [[ $SET_LOCAL_TIME = y ]]; then
        execute timedatectl set-local-rtc 1 --adjust-system-clock
    fi
fi

if [[ $HAS_SUDO = y ]]; then
    execute sudo apt update -y
    execute sudo apt upgrade -y
    execute sudo apt-get install git wget curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    execute sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    execute sudo apt-get update -y
    execute sudo apt-get install build-essential g++ cmake cmake-curses-gui pkg-config checkinstall automake -y
    execute sudo apt-get install xclip jq -y
    execute sudo apt-get install htop -y
    # execute sudo apt-get install run-one xbindkeys xbindkeys-config wmctrl xdotool -y
    execute sudo apt-get install fonts-powerline aria2 -y
    execute sudo apt-get install moreutils -y
    execute sudo apt-get install gh -y
    echo
elif ! [ -x "$(command -v wget)"  ] && [ -x "$(command -v git)"  ]; then
    echo "Script requires wget and git to work. Exiting."
    exit 1
fi

if [[ $CONFIG_GIT = y ]]; then
    git config --global user.email $email
    git config --global user.username $git_username
fi

# SSH key generation and git setup
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -q -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""
    eval "$(ssh-agent -s)" >/tmp/installation.log
    ssh-add -q ~/.ssh/id_ed25519 >/tmp/installation.log
fi

if [ -x "$(command -v gh)" ]; then
    echo "Currently logged in GitHub accounts:"
    gh auth status
    read -p "Would you like to login to GitHub? [y/n] " GH_LOGIN
    if [[ $GH_LOGIN = y ]]; then
        gh auth login
    fi
    echo ""
else
    echo "Github CLI not installed. Manually add key in ~/.ssh/id_ed25519.pub to github.com"
    echo "See https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
fi

############################################ DOT FILES ############################################

if [[ $REPLACE_DOTFILES = y ]]; then

    execute backup_and_delete ~/.aliases
    execute backup_and_delete ~/.env_vars
    execute backup_and_delete ~/.tmux.conf
    execute backup_and_delete ~/.vimrc
    cp ./dotfiles/.aliases ~/.aliases
    cp ./dotfiles/.env_vars ~/.env_vars
    cp ./dotfiles/.tmux.conf ~/.tmux.conf
    cp ./dotfiles/.vimrc ~/.vimrc
    cp ./dotfiles/.p10k.zsh ~/.p10k.zsh
fi

########################################### ENVIRONMENT ###########################################
if [[ $HAS_SUDO = y ]]; then
    execute backup_and_delete ~/.zshrc

    # ZSH installation
    rm -rf ~/.z*
    execute sudo apt-get install zsh -y
fi

if [ -x "$(command -v zsh)"  ]; then
    execute backup_and_delete ~/.zshrc
    execute backup_and_delete ~/.zshrc.common
    cp ./dotfiles/.zshrc.common ~/.zshrc.common

    spatialPrint "Setting up Oh-My-Zsh"
    echo "Fill in options according to preference and exit zsh once it loads."
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    echo 'source ~/.zshrc.common' | cat - ~/.zshrc > temp && mv temp ~/.zshrc
    echo "Installed Oh-My-Zsh."

    # ZSH PLUGINS
    git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k > /tmp/installation.log
    git clone --quiet https://github.com/conda-incubator/conda-zsh-completion.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/conda-zsh-completion > /tmp/installation.log
    git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /tmp/installation.log
    sed -i 's|ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
    sed -i 's|plugins=.*|plugins=(git dotenv conda-zsh-completion zsh-autosuggestions zoxide)|' ~/.zshrc
    sed -i 's|source $ZSH/oh-my-zsh.sh.*|source $ZSH/oh-my-zsh.sh\; autoload -U compinit \&\& compinit|' ~/.zshrc
else
    execute backup_and_delete ~/.bashrc.common
    cp ./dotfiles/.bashrc.common ~/.bashrc.common

    echo 'source ~/.env_vars' | cat - ~/.bashrc > temp && mv temp ~/.bashrc
    echo 'source ~/.bashrc.common' | cat - ~/.bashrc > temp && mv temp ~/.bashrc

fi

if [[ $HAS_SUDO = y ]]; then

    # vim installation
    execute sudo apt-get install vim -y # vim gnome adds system clipboard functionality

    # TMUX set up.
    # build dependencies
    execute sudo apt-get install libevent-dev ncurses-dev build-essential bison pkg-config -y
    spatialPrint "Installing tmux..."
    execute sudo apt-get install tmux -y
    rm -rf ~/.tmux/plugins/tpm
    mkdir -p ~/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "Press Ctrl+A I (capital I) on first run of tmux to install plugins."
fi

##################################### COMMAND LINE UTILITIES ######################################
spatialPrint "Installing command line utilities..."

# FZF: fuzzy finder - https://github.coym/junegunn/fzf
if ! [[ $(command -v fzf) ]]; then
    execute git clone --quiet --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    /bin/bash ~/.fzf/install
fi
wget https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -qO ~/.fzf-git.sh
echo "Installed fzf."

# Zoxide: directory navigation tool - https://github.com/ajeetdsouza/zoxide
if [[ $HAS_SUDO = y ]]; then
    execute sudo apt-get install zoxide -y
else
    wget https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.6/zoxide_0.9.6-1_amd64.deb -O /tmp/zoxide.deb && dpkg -i /tmp/zoxide.deb
fi
echo "Installed zoxide."

# BAT: better cat - https://github.com/sharkdp/bat
if [[ $HAS_SUDO = y ]]; then
    execute sudo apt-get install bat -y
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat
else
    url=$(wget "https://api.github.com/repos/sharkdp/bat/releases/latest" -qO-| grep browser_download_url | grep "gnu" | grep "x86_64" | grep "linux" | head -n 1 | cut -d \" -f 4)
    wget $url -qO- | tar -xz -C /tmp/
    mv /tmp/bat*/bat ~/.local/bin/
fi
echo "Installed bat."

# FD: simple find clone - https://github.com/sharkdp/fd
if [[ $HAS_SUDO = y ]]; then
    execute sudo apt-get install fd-find -y
    ln -sf $(which fdfind) ~/.local/bin/fd
else
    url=$(wget "https://api.github.com/repos/sharkdp/fd/releases/latest" -qO-|grep browser_download_url | grep "gnu" | grep "x86_64" | grep "linux" | head -n 1 | cut -d \" -f 4)
    wget $url -qO- | tar -xz -C /tmp
    mv /tmp/fd*/fd ~/.local/bin/
fi
echo "Installed fd."

# RIPGREP: faster grep - https://github.com/BurntSushi/ripgrep
if [[ $HAS_SUDO = y ]]; then
    url=$(wget "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" -qO-| grep browser_download_url | grep "deb" | head -n 1 | cut -d \" -f 4)
    wget $url -qO /tmp/rg.deb
    execute sudo dpkg -i /tmp/rg.deb
    execute sudo apt-get install -f
else
    url=$(wget "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" -qO-| grep browser_download_url | grep "x86_64" | grep "linux" | head -n 1 | cut -d \" -f 4)
    wget $url -qO- | tar -xz -C /tmp/
    mv /tmp/ripgrep*/rg ~/.local/bin/
fi
cp ./dotfiles/globalgitignore ~/.rgignore
echo "Installed ripgrep."

# LF: command line file navigation - https://github.com/gokcehan/lf
url=$(wget "https://api.github.com/repos/gokcehan/lf/releases/latest" -qO- | grep browser_download_url | grep "amd64" | grep "linux" | head -n 1 | cut -d \" -f 4)
wget $url -qO- | tar -xz -C ~/.local/bin
mkdir -p ~/.config/lf
cp ./dotfiles/lfrc ~/.config/lf/lfrc
wget https://raw.githubusercontent.com/gokcehan/lf/master/etc/colors.example -qO ~/.config/lf/colors
wget https://raw.githubusercontent.com/gokcehan/lf/master/etc/icons.example -qO ~/.config/lf/icons
echo "Installed lf."

# DUF: disk usage finder - https://github.com/muesli/duf
if [[ $HAS_SUDO = y ]]; then
    execute sudo apt-get install duf -y
fi
echo "Installed duf."

# FFMPEG
if [[ $HAS_SUDO = y ]]; then
    execute sudo apt-get install libhdf5-dev exiftool ffmpeg -y
    echo "Installed ffmpeg."
fi

##################################### PROGRAMMING LANGUAGES #######################################

# nvm (node version manager) installation
read -p "Install nvm? [y/n] " install_nvm
if [[ $install_nvm = y ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# ANACONDA installation 
read -p "Install miniconda? [y/n] " install_miniconda
if [[ $install_miniconda = y ]]; then
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
    wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
    chmod +x /tmp/miniconda.sh
    bash /tmp/miniconda.sh
    ~/miniconda3/bin/conda init zsh
fi

# UV installation: https://docs.astral.sh/uv/getting-started/installation/#installation-methods
read -p "Install uv? [y/n] " install_uv
if [[ $install_uv = y ]]; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
fi
###################################################################################################

echo "Mount windows partitions at startup using 'sudo fdisk -l' and by editing /etc/fstab"
echo "Installation completed. Restart and install other scripts."
