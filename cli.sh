#!/bin/bash

set -e
set -u
set -o pipefail

source "$(dirname "$0")/common.sh"

# Set up error trap
trap 'handle_error ${LINENO} $?' ERR
trap cleanup EXIT

# Detect if running as root
if [ "$EUID" -eq 0 ]; then
    ROOT_MODE=true
    HOME="/root"
    log "INFO" "Running in root mode. Home directory set to /root"
else
    ROOT_MODE=false
fi

# Initialize
mkdir -p "$BACKUP_DIR"
log "INFO" "Starting installation"

# Speed up the process
# Initialize NUMJOBS if not set
NUMJOBS=${NUMJOBS:-}

# Env Var NUMJOBS overrides automatic detection
if [[ -n "${NUMJOBS:-}" ]]; then
    MJOBS=$NUMJOBS
elif [[ -f /proc/cpuinfo ]]; then
    MJOBS=$(grep -c processor /proc/cpuinfo)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    MJOBS=$(sysctl -n machdep.cpu.thread_count)
else
    MJOBS=4
fi

log "INFO" "Using $MJOBS parallel jobs for compilation"

log "INFO" "Do not execute this file without reading it first and changing directory to the parent folder of this script."
log "INFO" "If it exits without completing install run 'sudo apt --fix-broken install'."

# Backup existing configurations before starting
backup_configs

# Collect all user inputs at the start
if [ "$ROOT_MODE" = false ]; then
    read -p "Do you have sudo access? [y/n] " HAS_SUDO
else
    HAS_SUDO="y"
fi

read -p "Replace dotfiles? Read script to see which files will be replaced. [y/n] " REPLACE_DOTFILES
if [[ $REPLACE_DOTFILES = y ]]; then
    log "INFO" "Dotfiles can be copied if you do not intend to make further edits, or soft linked if you wish to keep them up to date."
    log "WARN" "If you soft link, moving or deleting this repo folder will break the links."
    read -p "Soft link dotfiles? [y/n] " SOFT_LINK_DOTFILES
    SOFT_LINK_DOTFILES=${SOFT_LINK_DOTFILES:-n}
fi

# Check if we can set local time (not WSL)
if ! is_wsl; then
    read -p "Set hardware clock to local time? [y/n] " SET_LOCAL_TIME
else
    SET_LOCAL_TIME="n"
fi

show_progress "Creating local bin directory"
mkdir -p "$HOME/.local/bin"
if [ ! -w "$HOME/.local/bin" ]; then
    log "ERROR" "Cannot write to $HOME/.local/bin"
    exit 1
fi
finish_progress

######################################### BASIC PROGRAMS ##########################################

# Fixes time problems if Windows is installed on your PC alongside Ubuntu
if is_wsl; then
    log "INFO" "Cannot access timedatectl on WSL."
else
    if [[ $SET_LOCAL_TIME = y ]]; then
        show_progress "Setting hardware clock"
        execute timedatectl set-local-rtc 1 --adjust-system-clock
        finish_progress
    fi
fi

if [[ $HAS_SUDO = y ]]; then
    show_progress "Updating system packages"
    run_command apt update -y
    run_command apt upgrade -y
    run_command apt-get install git wget curl -y
    finish_progress

    show_progress "Setting up GitHub CLI keyring"
    if [ "$ROOT_MODE" = true ]; then
        dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg < <(curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg)
        chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
    else
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        run_command chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    fi
    finish_progress

    show_progress "Installing development tools"
    run_command apt-get update -y
    run_command apt-get install build-essential g++ cmake cmake-curses-gui pkg-config checkinstall automake -y
    run_command apt-get install xclip jq -y
    run_command apt-get install htop nvtop -y
    run_command apt-get install fonts-powerline aria2 -y
    run_command apt-get install moreutils -y
    run_command apt-get install gh -y
    finish_progress

elif ! [ -x "$(command -v wget)"  ] && [ -x "$(command -v git)"  ]; then
    log "ERROR" "Script requires wget and git to work. Exiting."
    exit 1
fi

# SSH key generation and git setup
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    show_progress "Generating SSH key"
    mkdir -p "$HOME/.ssh"
    ssh-keygen -q -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    ssh-add -q "$HOME/.ssh/id_ed25519"
    finish_progress
fi

if [ -x "$(command -v gh)" ]; then
    log "INFO" "Currently logged in GitHub accounts:"
    gh auth status
    read -p "Would you like to login to GitHub? [y/n] " GH_LOGIN
    if [[ $GH_LOGIN = y ]]; then
        gh auth login
    fi
else
    log "WARN" "Github CLI not installed. Manually add key in $HOME/.ssh/id_ed25519.pub to github.com"
    log "INFO" "See https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
fi

############################################ DOT FILES ############################################

if [[ $REPLACE_DOTFILES = y ]]; then
    show_progress "Installing dotfiles"
    local dotfiles=(
        ".aliases"
        ".env_vars"
        ".tmux.conf"
        ".vimrc"
        ".p10k.zsh"
    )
    
    for dotfile in "${dotfiles[@]}"; do
        install_dotfile "./dotfiles/$dotfile" "$HOME/$dotfile" "$SOFT_LINK_DOTFILES"
    done
    finish_progress
fi

########################################### ENVIRONMENT ###########################################
if [[ $HAS_SUDO = y ]]; then
    show_progress "Setting up ZSH environment"
    execute backup_and_delete "$HOME/.zshrc"
    rm -rf "$HOME/.z*"
    run_command apt-get install zsh -y
    finish_progress
fi

if [ -x "$(command -v zsh)"  ]; then
    show_progress "Configuring ZSH"
    execute backup_and_delete "$HOME/.zshrc"
    execute backup_and_delete "$HOME/.zshrc.common"
    cp "./dotfiles/.zshrc.common" "$HOME/.zshrc.common"

    log "INFO" "Setting up Oh-My-Zsh"
    log "INFO" "Fill in options according to preference and exit zsh once it loads."
    sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    echo "source \$HOME/.zshrc.common" | cat - "$HOME/.zshrc" > temp && mv temp "$HOME/.zshrc"
    log "INFO" "Installed Oh-My-Zsh."

    show_progress "Installing ZSH plugins"
    git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" > /dev/null
    git clone --quiet https://github.com/conda-incubator/conda-zsh-completion.git "${ZSH_CUSTOM:=$HOME/.oh-my-zsh/custom}/plugins/conda-zsh-completion" > /dev/null
    git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" > /dev/null
    sed -i "s|ZSH_THEME=.*|ZSH_THEME=\"powerlevel10k/powerlevel10k\"|" "$HOME/.zshrc"
    sed -i "s|plugins=.*|plugins=(git dotenv conda-zsh-completion zsh-autosuggestions zoxide)|" "$HOME/.zshrc"
    sed -i "s|source \$ZSH/oh-my-zsh.sh.*|source \$ZSH/oh-my-zsh.sh\; autoload -U compinit \&\& compinit|" "$HOME/.zshrc"
    finish_progress
else
    show_progress "Setting up Bash environment"
    execute backup_and_delete "$HOME/.bashrc.common"
    cp "./dotfiles/.bashrc.common" "$HOME/.bashrc.common"
    echo "source \$HOME/.env_vars" | cat - "$HOME/.bashrc" > temp && mv temp "$HOME/.bashrc"
    echo "source \$HOME/.bashrc.common" | cat - "$HOME/.bashrc" > temp && mv temp "$HOME/.bashrc"
    finish_progress
fi

if [[ $HAS_SUDO = y ]]; then
    show_progress "Installing Vim"
    run_command apt-get install vim -y
    finish_progress

    show_progress "Installing TMUX and dependencies"
    run_command apt-get install libevent-dev ncurses-dev build-essential bison pkg-config -y
    run_command apt-get install tmux -y
    rm -rf "$HOME/.tmux/plugins/tpm"
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    log "INFO" "Press Ctrl+A I (capital I) on first run of tmux to install plugins."
    finish_progress
fi

##################################### COMMAND LINE UTILITIES ######################################
log "INFO" "Installing command line utilities..."

# FZF: fuzzy finder - https://github.coym/junegunn/fzf
if ! [[ $(command -v fzf) ]]; then
    show_progress "Installing FZF"
    execute git clone --quiet --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    /bin/bash "$HOME/.fzf/install"
    wget https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -qO "$HOME/.fzf-git.sh"
    finish_progress
fi

# ZOXIDE: directory navigation tool - https://github.com/ajeetdsouza/zoxide
show_progress "Installing Zoxide"
if [[ $HAS_SUDO = y ]]; then
    run_command apt-get install zoxide -y
else
    wget https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.6/zoxide_0.9.6-1_amd64.deb -O /tmp/zoxide.deb && dpkg -i /tmp/zoxide.deb
fi
finish_progress

# BAT: better cat - https://github.com/sharkdp/bat
show_progress "Installing BAT"
if [[ $HAS_SUDO = y ]]; then
    run_command apt-get install bat -y
    mkdir -p "$HOME/.local/bin"
    ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
else
    url=$(wget "https://api.github.com/repos/sharkdp/bat/releases/latest" -qO-| grep browser_download_url | grep "gnu" | grep "x86_64" | grep "linux" | head -n 1 | cut -d \" -f 4)
    wget "$url" -qO- | tar -xz -C /tmp/
    mv /tmp/bat*/bat "$HOME/.local/bin/"
fi
finish_progress

# FD: simple find clone - https://github.com/sharkdp/fd
show_progress "Installing FD"
if [[ $HAS_SUDO = y ]]; then
    run_command apt-get install fd-find -y
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
else
    url=$(wget "https://api.github.com/repos/sharkdp/fd/releases/latest" -qO-|grep browser_download_url | grep "gnu" | grep "x86_64" | grep "linux" | head -n 1 | cut -d \" -f 4)
    wget "$url" -qO- | tar -xz -C /tmp
    mv /tmp/fd*/fd "$HOME/.local/bin/"
fi
finish_progress

# RIPGREP: faster grep - https://github.com/BurntSushi/ripgrep
show_progress "Installing Ripgrep"
if [[ $HAS_SUDO = y ]]; then
    url=$(wget "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" -qO-| grep browser_download_url | grep "deb" | head -n 1 | cut -d \" -f 4)
    wget "$url" -qO /tmp/rg.deb
    run_command dpkg -i /tmp/rg.deb
    run_command apt-get install -f
else
    url=$(wget "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" -qO-| grep browser_download_url | grep "x86_64" | grep "linux" | head -n 1 | cut -d \" -f 4)
    wget "$url" -qO- | tar -xz -C /tmp/
    mv /tmp/ripgrep*/rg "$HOME/.local/bin/"
fi
cp "./dotfiles/globalgitignore" "$HOME/.rgignore"
finish_progress

# LF: command line file navigation - https://github.com/gokcehan/lf
show_progress "Installing LF"
url=$(wget "https://api.github.com/repos/gokcehan/lf/releases/latest" -qO- | grep browser_download_url | grep "amd64" | grep "linux" | head -n 1 | cut -d \" -f 4)
wget "$url" -qO- | tar -xz -C "$HOME/.local/bin"
mkdir -p "$HOME/.config/lf"
cp "./dotfiles/lfrc" "$HOME/.config/lf/lfrc"
wget https://raw.githubusercontent.com/gokcehan/lf/master/etc/colors.example -qO "$HOME/.config/lf/colors"
wget https://raw.githubusercontent.com/gokcehan/lf/master/etc/icons.example -qO "$HOME/.config/lf/icons"
finish_progress

# DUF: disk usage finder - https://github.com/muesli/duf
if [[ $HAS_SUDO = y ]]; then
    show_progress "Installing DUF"
    run_command apt-get install duf -y
    finish_progress
fi

# FFMPEG
if [[ $HAS_SUDO = y ]]; then
    show_progress "Installing FFMPEG and related tools"
    run_command apt-get install libhdf5-dev exiftool ffmpeg -y
    finish_progress
fi

# WSLVIEW: wsl utilities - https://github.com/wslutilities/wslu
if is_wsl; then
    show_progress "Installing WSLU"
    run_command apt-get install wslu -y
    finish_progress
fi

#####################################################################################

if ! is_wsl; then
    log "INFO" "Mount windows partitions at startup using 'sudo fdisk -l' and by editing /etc/fstab"
fi

log "INFO" "Installation completed. Restart and install other scripts."
