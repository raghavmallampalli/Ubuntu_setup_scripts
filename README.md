# Ubuntu_setup_scripts
These are the scripts I use to set up my Ubuntu. Some portions are untested.
These scripts are largely inspired by https://github.com/rsnk96/Ubuntu-Setup-Scripts. Some of the code is taken directly from there. Check out if you have interest in AI/ML.

## basic
Basic setup of Ubuntu. It installs some essential packages and their dependencies. Additionally it also installs a IDE of your choice (Sublime/Atom/VS Code). Finally it installs Python3, important libraries in Python3 and octave.

IMPORTANT: Bash shell is replaced by a zsh+zim configuration.

## gui_aesthetics
GUI programs I use frequently use. A number of repositories are added.
### Setting up SimpleScreenRecorder:
* Add to startup applications:  simplescreenrecorder --start-hidden
* ![Page 1 of setup] (config_files/ssr_1.png?raw=true "Screenshot 1")
* ![Page 2 of setup] (config_files/ssr_2.png?raw=true "Screenshot 2")


## command_line_utilities
Installs CLI programs and scripts that I find useful.

## wine_playonlinux_musicbee
Installs WINE, PlayOnLinux and attempts to correctly install MusicBee, a Windows music player. High failure rate.

For a list of useful commands and stuff, check out [help](Help.md)

## known bugs/failures/shortcomings:
* pip3 installation of jupyter-lab fails (end of basic.sh)
* more fonts to be added

### Ubuntu 20.04
* bat does not work
* ripgrep does not install for some reason
* vivaldi package not out
* inkspace not out
* ros out on 23rd May 2020
