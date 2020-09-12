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


# download and install bat, cat with syntax highlighting
if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -gt 19 ]]; then  
    # execute sudo apt-get install bat -y
    echo "Ubuntu 19.10 and above are supposed to have bat in universe repo. Does not work at the moment."
else
    echo "Installing bat, a handy replacement for cat"
    latest_bat_setup=$(curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep "deb" | grep "browser_download_url" | head -n 1 | cut -d \" -f 4)
    aria2c --file-allocation=none -c -x 10 -s 10 --dir /tmp -o bat.deb $latest_bat_setup
    execute sudo dpkg -i /tmp/bat.deb
    execute sudo apt-get install -f
fi

execute sudo apt-get install pciutils -y

# directory navigation tool - https://github.com/clvv/fasd
execute sudo apt-get install fasd -y
echo 'eval "$(fasd --init auto)"' >> ~/.zshrc
echo 'eval "$(fasd --init auto)"' >> ~/.zshrc
echo "zmodule wookayin/fzf-fasd" >> ~/.zimrc
echo "Run zimfw install, clean and compile on completion"

# ranger, CLI file explorer - https://github.com/ranger/ranger
execute sudo apt-get install bsdtar atool tar unrar unzip -y
execute pip3 install ranger-fm -y
# ranger configuration: untested
execute ranger --copy-config=all
rm ~/.config/ranger/rc.conf ~/.config/ranger/commands.py ~/.config/ranger/rifle.conf
cp ./config_files/rc.conf ~/.config/ranger/
cp ./config_files/commands.py ~/.config/ranger/
cp ./config_files/rifle.conf ~/.config/ranger/
mkdir ~/.config/ranger/plugins/
cp ./config_files/plugin_fasd_log.py ~/.config/ranger/plugins/
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons

echo "Download and install Windscribe with binaries. https://windscribe.com/guides/linux#how-to Will be added to sh file when out of beta."

# fuzzy finder and superior grep finders.
# https://github.com/junegunn/fzf
# https://github.com/BurntSushi/ripgrep
# https://github.com/ggreer/the_silver_searcher
# fzf<CR>, C-t, C-r, Alt-C
# fzf git installation. apt package available 19.10+
if [ -x "$(command -v fzf)"]; then
    execute git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    /bin/bash ~/.fzf/install
    
    # faster searcher than ack/grep. works well for fzf.
    if [[ ! -n $CIINSTALL ]]; then
        read -p "Silver searcher or ripgrep? Ag recommended for 18, Rg for 19+ [Silver/Rip/Quit: s/r/q]: " tempvar
    fi
    tempvar=${tempvar:-q}
    if [ "$tempvar" = "s" ]; then # Silver searcher installation
        execute sudo apt-get install silversearcher-ag -y
        cp ./config_files/globalgitignore ~/.gitignore
        echo "export FZF_DEFAULT_COMMAND='ag -p ~/.gitignore -g \"\"'" >> ~/.zshrc
        echo "export FZF_DEFAULT_COMMAND='ag -p ~/.gitignore -g \"\"'" >> ~/.bashrc
    elif [ "$tempvar" = "r" ]; then # Ripgrep installation
        if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -gt 18 ]]; then  
            execute sudo apt-get install ripgrep -y
        else
            curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb; sudo dpkg -i ripgrep_11.0.2_amd64.deb; rm ripgrep_11.0.2_amd64.deb # last check version. swap out with newest version if it works
        fi
        cp ./config_files/globalgitignore ~/.rgignore
        echo "export FZF_DEFAULT_COMMAND='rg --files --hidden'" >> ~/.zshrc
        echo "export FZF_DEFAULT_COMMAND='rg --files --hidden'" >> ~/.bashrc
    elif [ "$tempvar" = "q" ]; then
        echo "quitting"
    fi
    # hotkey and direct autocompletion is set, avoid using **tab. gitignore is not respected
    echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.zshrc
    echo 'export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' >> ~/.bashrc
fi

# cheat sheet - http://cheat.sh
mkdir -p ~/bin/ && curl https://cht.sh/:cht.sh > ~/bin/cht.sh && chmod +x ~/bin/cht.sh
# there may be lag on first two runs after boot. Should improve on consecutive runs.

# terminal command auto-correction - https://github.com/nvbn/thefuck
execute sudo pip3 install thefuck
echo 'eval $(thefuck --alias fu)' >> ~/.zshrc
echo 'eval $(thefuck --alias fu)' >> ~/.bashrc

# command line help - https://github.com/gleitz/howdoi 
execute sudo pip3 install howdoi

# ffmpeg
execute sudo apt-get install libhdf5-dev exiftool ffmpeg -y

# check out nvtop if you have a working nvidia GPU

# dependencies for CLI OneDrive client
execute sudo apt-get install libcurl4-openssl-dev libsqlite3-dev libnotify-dev -y
echo "Dependencies installed. Visit and follow instructions in https://github.com/abraunegg/onedrive/blob/master/docs/INSTALL.md"
echo "Installation completed."
