# Ubuntu_setup_scripts
These are the scripts I use to set up my Ubuntu. They install tools for Web development, robotics and scientific computing and work with Ubuntu 18.04, 20.04 and WSL2 Ubuntu. Some portions are untested.
These scripts are largely inspired by https://github.com/rsnk96/Ubuntu-Setup-Scripts. Some of the code is taken directly from there. Check out if you have interest in AI/ML.

For a list of useful commands and tips, check out [help](Help.md)

## commandline
Basic setup of Ubuntu. It installs some essential packages and their dependencies. It also installs some command line utilites. Finally it installs miniconda3 (by choice) with python3.

IMPORTANT: Bash shell is replaced by a zsh+Oh-My-Zsh configuration.

## gui
GUI programs I use frequently use. A number of repositories are added. Installs a IDE of your choice (Sublime/Atom/VS Code).
### Setting up SimpleScreenRecorder:
* Add to startup applications:  simplescreenrecorder --start-hidden
* Configure SSR as below

 ![Page 1 of setup](config_files/ssr_1.png?raw=true "Screenshot 1")
 ![Page 2 of setup](config_files/ssr_2.png?raw=true "Screenshot 2")

## sci_comp_ds.sh
Installs scientific computing and basic data science libraries. Do not install large ML libraries in the base environment. Make a conda new environment for them, and once installation is complete, use a requirements.txt file to improve portability.

## wine_playonlinux_musicbee
Installs WINE, PlayOnLinux and attempts to correctly install MusicBee, a Windows music player. High failure rate.

## Known bugs/failures/shortcomings:
### Ubuntu 20.04
#### gui
* Not fully tested
#### robotics
* ROS noetic installation not configured
