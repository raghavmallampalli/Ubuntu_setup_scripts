#!/bin/bash

# Source functions.sh to import utility functions
source "$(dirname "$0")/functions.sh"

log "INFO"  "Proceed if you have run cli.sh (and restarted shell), changed directory to the parent folder of this script and gone through it. Ctrl+C and do so first if not. [ENTER] to continue."
read dump

# Gather all user input at the beginning
read -p "Install uv? [y/n] " install_uv
if [[ $install_uv != y ]]; then
    read -p "Install Miniconda? [y/n] " install_miniconda
fi
read -p "Install nvm? [y/n] " install_nvm
read -p "Install Julia? [y/n] " install_julia
read -p "Install R? [y/n]: " install_r
read -p "Install GNU octave? [y/n]: " install_octave
read -p "Create a workbench folder for scientific computing and data science? [y/n]: " create_workbench

# UV installation: https://docs.astral.sh/uv/getting-started/installation/#installation-methods
if [[ $install_uv = y ]]; then
    show_progress "Installing UV"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log "INFO" 'eval "$(uv generate-shell-completion zsh)"' >> "$HOME/.zshrc"
    finish_progress
fi

if [[ $install_miniconda = y ]]; then
    show_progress "Installing Miniconda"
    tempvar=${tempvar:-n}
    if [ -d "$HOME/miniconda3" ]; then
        read -p "miniconda3 installed in default location directory. delete/manually enter install location/quit [d/m/Ctrl+C]: " tempvar
        tempvar=${tempvar:-n}
        if [[ $tempvar = d ]]; then
            rm -rf "$HOME/miniconda3"
        elif [[ $tempvar = m ]]; then
            log "INFO" "Ensure that you enter a different location during installation."
        fi
    fi 
    wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
    chmod +x /tmp/miniconda.sh
    bash /tmp/miniconda.sh
    "$HOME/miniconda3/bin/conda" init zsh
    finish_progress
fi

# NVM (node version manager) installation
if [[ $install_nvm = y ]]; then
    show_progress "Installing NVM"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    finish_progress
fi



if [[ $install_julia = y ]]; then
    show_progress "Installing Julia"
    curl -fsSL https://install.julialang.org | sh
    log "INFO" "To use Julia with Jupyter Notebook https://github.com/JuliaLang/IJulia.jl#quick-start"
    finish_progress
fi

if [[ $install_r = y ]]; then
    show_progress "Installing R"
    run_command apt-get install --no-install-recommends software-properties-common dirmngr -y
    run_command apt-get install libzmq3-dev libcurl4-openssl-dev libssl-dev jupyter-core jupyter-client -y
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | run_command tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc >> /dev/null
    run_command add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" -y >> /dev/null
    run_command apt-get install --no-install-recommends r-base -y
    run_command add-apt-repository ppa:c2d4u.team/c2d4u4.0+ -y >> /dev/null
    show_progress "Installing RStudio"
    run_command apt-get install rstudio -y
    finish_progress
fi

if [[ $install_octave = y ]]; then
    run_command apt-get install octave -y
fi



log "INFO" "Installation complete."
