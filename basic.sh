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
spatialPrint "Do not execute this file without reading it first."

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
execute sudo apt-get install vim-gui-common vim-runtime -y
execute sudo apt-get install htop -y
execute sudo apt-get install run-one xbindkeys xbindkeys-config wmctrl xdotool -y
cp ./config_files/vimrc ~/.vimrc

# zsh is a shell that's better than bash. zim is a framework/plugin management system for it.
# Checks if ZSH is partially or completely installed to remove the folders and reinstall it
rm -rf ~/.z*
zsh_folder=/opt/.zsh/
if [[ -d $zsh_folder ]];then
	sudo rm -r /opt/.zsh/*
fi

spatialPrint "Setting up zsh + zim now"
execute sudo apt-get install zsh -y
sudo mkdir -p /opt/.zsh/ && sudo chmod ugo+w /opt/.zsh/
git clone --recursive --quiet --branch zsh-5.2 https://github.com/zimfw/zimfw.git /opt/.zsh/zim
ln -s /opt/.zsh/zim/ ~/.zim
ln -s /opt/.zsh/zim/templates/zimrc ~/.zimrc
ln -s /opt/.zsh/zim/templates/zlogin ~/.zlogin
ln -s /opt/.zsh/zim/templates/zshrc ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions /opt/.zsh/zsh-autosuggestions
echo "source /opt/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
# Change default shell to zsh
command -v zsh | sudo tee -a /etc/shells
sudo chsh -s "$(command -v zsh)" "${USER}"
echo 'bindkey '^R' history-incremental-search-backward' >> ~/.zshrc #untested # Ctrl+R for history search
echo 'setopt nonomatch' >> ~/.zshrc # untested # Regex matching for locate, apt commmands. Use with caution.
echo 'setopt SHARE_HISTORY' >> ~/.zshrc #untested # share history between terminals
execute sudo apt-get install fonts-powerline -y
execute sudo apt-get install aria2 -y

# Create bash aliases and link bash and zsh aliases
cp ./config_files/bash_aliases /opt/.zsh/bash_aliases
ln -s /opt/.zsh/bash_aliases ~/.bash_aliases

{
    echo "if [ -f ~/.bash_aliases ]; then"
    echo "  source ~/.bash_aliases"
    echo "fi"

    echo "# Switching to 256-bit colour by default so that zsh-autosuggestion's suggestions are not suggested in white, but in grey instead"
    echo "export TERM=xterm-256color"

    echo "# Setting the default text editor to micro, a terminal text editor with shortcuts similar to what you'd encounter in an IDE"
    echo "export VISUAL=micro"
} >> ~/.zshrc


# Now download and install bat
if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -gt 19 ]]; then  
    execute sudo apt-get install bat -y # Ubuntu 19.10 and above have bat in universe repo
else
    spatialPrint "Installing bat, a handy replacement for cat"
    latest_bat_setup=$(curl --silent "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep "deb" | grep "browser_download_url" | head -n 1 | cut -d \" -f 4)
    aria2c --file-allocation=none -c -x 10 -s 10 --dir /tmp -o bat.deb $latest_bat_setup
    execute sudo dpkg -i /tmp/bat.deb
    execute sudo apt-get install -f
fi

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
    execute code --install-extension Shan.code-settings-sync # untested, extension that saves your installed extensions and settings to github
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

# untested: 
# installing python3, octave
execute sudo apt-get install python-pip -y
execute sudo apt-get install python3 python3-dev python3-pip python3-setuptools -y
execute pip3 install jupyter jupyter-lab notebook
execute pip3 install python-dateutil tabulate # basic libraries
execute pip3 install matplotlib numpy scipy pandas h5py # standard scientific libraries
execute pip3 install scikit-learn scikit-image # basic ML libraries
execute pip3 install keras tensorflow
execute sudo apt-get install octave -y # comment out if you have access to MATLAB. 
# Also consider sage if you have no access to Mathematica. https://doc.sagemath.org/html/en/installation/binary.html 

echo "Installation complete. Restart and install other three scripts. Read them first. They are not yet fully tested."