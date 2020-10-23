# Ubuntu_setup_scripts
These are the scripts I use to set up my Ubuntu. They install tools for Web development, robotics and scientific computing and work with Ubuntu 18.04, 20.04 and WSL2 Ubuntu. Some portions are untested.
These scripts are largely inspired by https://github.com/rsnk96/Ubuntu-Setup-Scripts. Some of the code is taken directly from there. Check out if you have interest in AI/ML.

For a list of useful commands and tips, check out [help](Help.md)

## basic
Basic setup of Ubuntu. It installs some essential packages and their dependencies. Additionally it also installs a IDE of your choice (Sublime/Atom/VS Code). Finally it installs Python3, useful libraries in Python3 and octave.

IMPORTANT: Bash shell is replaced by a zsh+zim configuration.

## gui_aesthetics
GUI programs I use frequently use. A number of repositories are added.
### Setting up SimpleScreenRecorder:
* Add to startup applications:  simplescreenrecorder --start-hidden
* Configure SSR as below

 ![Page 1 of setup](config_files/ssr_1.png?raw=true "Screenshot 1")
 ![Page 2 of setup](config_files/ssr_2.png?raw=true "Screenshot 2")

## command_line_utilities
Installs CLI programs and scripts that I find useful. Clean the ~.bash_aliases file of unused aliases if you do not run this script.

## wine_playonlinux_musicbee
Installs WINE, PlayOnLinux and attempts to correctly install MusicBee, a Windows music player. High failure rate.

## Known bugs/failures/shortcomings:
### Ubuntu 20.04
#### CLI
* bat installation does not work
* ripgrep does not install
#### gui
* vivaldi package not out
* inkspace not out
#### robotics
* ROS noetic installation not configured
