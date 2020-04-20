# Ubuntu_setup_scripts
These are the scripts I use to set up my Ubuntu. Some portions are untested.
These scripts are largely inspired by https://github.com/rsnk96/Ubuntu-Setup-Scripts. Some of the code is taken directly from there. Check out if you have interest in AI/ML.

## basic.sh:
Basic setup of Ubuntu. It installs some essential packages and their dependencies. Additionally it also installs a IDE of your choice (Sublime/Atom/VS Code). Finally it installs Python3, important libraries in Python3 and octave.

IMPORTANT: Bash shell is replaced by a zsh+zim configuration.

## gui_aesthetics.sh
GUI programs I use frequently use. A number of repositories are added.
### Setting up SimpleScreenRecorder:
* Add to startup applications:  simplescreenrecorder --start-hidden
* ![Page 1 of setup] (./config_files/ssr_1.png)
* ![Page 2 of setup] (./config_files/ssr_2.png)


## command_line_utilities.sh
Installs CLI programs and scripts that I find useful.

## wine_playonlinux_musicbee.sh
Installs WINE, PlayOnLinux and attempts to correctly install MusicBee, a Windows music player. High failure rate.

For a list of useful commands and stuff, check out [Help.md](./Help.md)

## vim useful shortcuts

:%s/search/replace/gc is search and replace with prompt for each match
:h opt is help
:difft, :diffo!
fzf.vim and ranger.vim bindings (see vimrc)
:tabp, :tabn (avoid using windows)
Ctrl-W and arrow keys to navigate splits
read up on vim registers
