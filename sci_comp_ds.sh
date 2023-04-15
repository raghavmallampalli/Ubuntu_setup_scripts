#!/bin/bash

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

echo "Proceed if you have run basic.sh and command_line_utlities.sh (and restarted shell), changed directory to the parent folder of this script and gone through it. Ctrl+C and do so first if not. [ENTER] to continue."
read dump

echo "JuliaLang installation"
if [ -d ~/julia-1.6.2 ]; then
    echo "JuliaLang 1.6.2 already installed in home directory (~/julia-1.6.2). Skipping."
else
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.2-linux-x86_64.tar.gz
    tar zxf julia-1.6.2-linux-x86_64.tar.gz -C ~/
    rm -rf julia-1.6.2-linux-x86_64.tar.gz
fi

read -p "Download and install R. [y/n]: " tempvar
tempvar=${tempvar:-n}
if [[ $tempvar = y ]]; then
    execute sudo apt-get install --no-install-recommends software-properties-common dirmngr -y
    execute sudo apt-get install libzmq3-dev libcurl4-openssl-dev libssl-dev jupyter-core jupyter-client -y
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc >> /dev/null
    sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" -y >> /dev/null
    execute sudo apt-get install --no-install-recommends r-base -y
    sudo add-apt-repository ppa:c2d4u.team/c2d4u4.0+ -y >> /dev/null
fi

read -p "Download and install GNU octave. [y/n]: " tempvar
tempvar=${tempvar:-n}
if [[ $tempvar = y ]]; then
    execute sudo apt-get install octave -y # comment out if you have access to MATLAB. 
fi

echo "Installing scientific computing and data science libraries for python"
if [[ $(command -v conda) ]]; then
    PIP="pip install"
else
    execute sudo apt-get install python3-dev python3-tk python3-setuptools -y
    execute sudo apt-get install python3-pip -y
    # 20.04 does not have python-pip in repo.
    if [[ $(cat /etc/os-release | grep "VERSION_ID" | grep -o -E '[0-9][0-9]' | head -n 1) -lt 19 ]]; then  
        execute sudo apt-get install python-pip -y 
    fi
    PIP="sudo pip3 install --upgrade" 
fi
execute $PIP jupyter notebook
execute $PIP jupyterlab
execute $PIP python-dateutil tabulate # basic libraries
execute $PIP matplotlib numpy scipy pandas h5py seaborn # standard scientific libraries
execute $PIP plotly kaleido ipywidgets pyforest
execute $PIP scikit-learn scikit-image # basic ML libraries
# execute $PIP keras tensorflow # ML libraries. Occupy large amounts of space.
echo "To use Julia with Jupyter Notebook https://github.com/JuliaLang/IJulia.jl#quick-start"

# Also consider sage if you have no access to Mathematica. https://doc.sagemath.org/html/en/installation/binary.html 

echo "Installation complete."
