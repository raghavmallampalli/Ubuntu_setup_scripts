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

echo "Proceed if you have run basic.sh, changed directory to the partent folder of this script and gone through it. Ctrl+C and do so first if not. [ENTER] to continue."
read dump

# neovim installation: fork of vim in active development
execute sudo add-apt-repository ppa:neovim-ppa/unstable -y
execute sudo apt-get install neovim -y
! [ -d ~/.vim/ ] && mkdir ~/.vim/
cp ./config_files/coc-settings.json ./config_files/coc-setup.vim ~/.vim/
! [ -d ~/.config/nvim ] && mkdir ~/.config/nvim/
touch ~/.config/nvim/init.vim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
# write lines to init.vim to use same config as vim
cat << EOF >> ~/.config/nvim/init.vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after 
let &packpath = &runtimepath 
source ~/.vimrc
EOF
execute pip3 install --user --upgrade pynvim

# clipboard support in neovim for WSL
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then 
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
    unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
    chmod +x /tmp/win32yank.exe
    mv /tmp/win32yank.exe ~/bin
fi

# download and install bat, cat with syntax highlighting
echo "Installing bat, a handy replacement for cat"
latest_bat_setup=$(curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep "deb" | grep "browser_download_url" | head -n 1 | cut -d \" -f 4)
aria2c --file-allocation=none -c -x 10 -s 10 --dir /tmp -o bat.deb $latest_bat_setup
execute sudo dpkg -i /tmp/bat.deb
execute sudo apt-get install -f -y

echo "Installing fd, a speedier replacement for find"
latest_fd_setup=$(curl --silent "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep "deb" | grep "browser_download_url" | head -n 1 | cut -d \" -f 4)
aria2c --file-allocation=none -c -x 10 -s 10 --dir /tmp -o fd.deb $latest_fd_setup
execute sudo dpkg -i /tmp/fd.deb
execute sudo apt-get install -f -y
execute sudo apt-get install pciutils -y

# directory navigation tool - https://github.com/clvv/fasd
execute sudo apt-get install fasd -y
echo 'eval "$(fasd --init auto)"' >> ~/.zshrc
echo 'eval "$(fasd --init auto)"' >> ~/.zshrc
echo "zmodule wookayin/fzf-fasd" >> ~/.zimrc
echo "zmodule romkatv/powerlevel10k" >> ~/.zimrc
echo "Run zimfw install, clean and compile on completion"

# nnn, a command line file explorer
sudo apt-get install pkg-config libncursesw5-dev libreadline-dev
git clone https://github.com/jarun/nnn.git
cd nnn
sudo make O_NERD=1 strip install
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh

echo "Download and install Windscribe with binaries. https://windscribe.com/guides/linux#how-to Will be added to sh file when out of beta."

# ripgrep: faster searcher than grep
# https://github.com/BurntSushi/ripgrep
wget -o /tmp/rg.deb https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb --quiet
execute sudo dpkg -i /tmp/rg.deb
execute sudo apt-get install -f
cp ./config_files/globalgitignore ~/.gitignore
ln -s -f ~/.gitignore ~/.rgignore

# fzf: fuzzy finder.
# https://github.com/junegunn/fzf
# fzf<CR>, C-t, C-r, Alt-C
# fzf git installation. apt package available 19.10+
if [[ $(command -v fzf) ]]; then
    execute git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    /bin/bash ~/.fzf/install
    echo "export FZF_DEFAULT_COMMAND='rg --files --hidden'" >> ~/.zshrc
    # hotkey and direct autocompletion is set, avoid using **tab. gitignore is not respected
    echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.zshrc
    echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.bashrc
fi

# ffmpeg
execute sudo apt-get install libhdf5-dev exiftool ffmpeg -y

# check out nvtop if you have a working nvidia GPU

# dependencies for CLI OneDrive client
execute sudo apt-get install libcurl4-openssl-dev libsqlite3-dev libnotify-dev -y
echo "Dependencies installed. Visit and follow instructions in https://github.com/abraunegg/onedrive/blob/master/docs/INSTALL.md"
echo "Installation completed."
