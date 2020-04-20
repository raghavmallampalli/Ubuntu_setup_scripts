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


# download and install bat, cat with syntax highlighting
if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -gt 19 ]]; then  
    execute sudo apt-get install bat -y # Ubuntu 19.10 and above have bat in universe repo
else
    spatialPrint "Installing bat, a handy replacement for cat"
    latest_bat_setup=$(curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep "deb" | grep "browser_download_url" | head -n 1 | cut -d \" -f 4)
    aria2c --file-allocation=none -c -x 10 -s 10 --dir /tmp -o bat.deb $latest_bat_setup
    execute sudo dpkg -i /tmp/bat.deb
    execute sudo apt-get install -f
fi

execute sudo apt-get install pciutils -y

execute sudo apt-get install ranger -y # CLI file explorer. zh, dD, <SPC>, rest vim keybindings
# ranger configuration:
echo "Download and install Windscribe with binaries. https://windscribe.com/guides/linux#how-to Will be added to sh file when out of beta."

# fuzzy finder and superior grep finders. https://github.com/junegunn/fzf 
# fzf<CR>, C-t, C-r, Alt-C
# fzf git installation. apt package available 19.10+
execute git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
execute shell ~/.fzf/install
# faster searcher than ack/grep. works well for fzf.
echo "Silver searcher or ripgrep? Ag recommended for 18, Rg for 19+ Silver/Rip/Quit: s/r/q"
read temp
if [[ $temp='s' ]]; then; # Silver searcher installation
    execute sudo apt-get install silversearcher-ag -y
    execute cp ./config_files/globalgitignore ~/.gitignore
    echo "export FZF_DEFAULT_COMMAND='ag -p ~/.gitignore -g \"\"'" >> ~/.zshrc
    echo "export FZF_DEFAULT_COMMAND='ag -p ~/.gitignore -g \"\"'" >> ~/.bashrc
elif [[ $temp='r' ]]; then; # Ripgrep installation
    if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -gt 18 ]]; then  
        execute sudo apt-get install ripgrep -y
    else;
        curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb; sudo dpkg -i ripgrep_11.0.2_amd64.deb; rm ripgrep_11.0.2_amd64.deb # last check version. swap out with newest version if it works
    fi
    execute cp ./config_files/globalgitignore ~/.rgignore
    echo "export FZF_DEFAULT_COMMAND='rg --files --hidden'" >> ~/.zshrc
    echo "export FZF_DEFAULT_COMMAND='rg --files --hidden'" >> ~/.bashrc
else;
    echo "quitting"
fi
# hotkey and direct autocompletion is set, avoid using **tab. gitignore is not respected
echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.zshrc
echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.bashrc

# terminal command auto-correction.
execute sudo pip3 install thefuck
echo 'eval $(thefuck --alias f)' >> ~/.zshrc
echo 'eval $(thefuck --alias f)' >> ~/.bashrc

# ffmpeg
execute sudo apt-get install libhdf5-dev exiftool ffmpeg -y

# check out nvtop if you have a working nvidia GPU

# dependencies for CLI OneDrive client
execute sudo apt-get install libcurl4-openssl-dev libsqlite3-dev libnotify-dev -y
curl -fsS https://dlang.org/install.sh | bash -s dmd
echo "Visit and follow instructions in https://github.com/abraunegg/onedrive/blob/master/docs/INSTALL.md#compilation--installation"