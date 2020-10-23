# General
- Alt+F2: quick run a command in Ubuntu
- `ytsd search_string` searches for the string on YouTube and downloads the video/audio of your preference. Check `./config_files/yt-search-dl.sh` to see how it works.

# Programs and languages:
# Shell
```
COMMAND --help # pulls up help for the command
man COMMAND # pulls up man page for command
which COMMAND # pulls up location of command

chmod +x FILE_NAME # Gives highest read write execute permission to file

mkdir -p FOLDER_HEIRARCH/FOLDER_NAME # make folder 
rm FILE_NAME # check out available options for this

sudo rm -i /etc/apt/sources.list.d/PPA_Name.list # removes repository

df # file system information that does not require root access
sudo fdisk -l # file sys info that requires root access

tar xvzf file.tar.gz -C /path/to/somedirectory # extract, verbose, uncompress file to some path

# information about package
apt list --installed | grep STUFF
apt-cache search STUFF

# installation interrupted:
sudo dpkg --configure -a
sudo apt --fix-broken install

# useful man pages:
man hier
```
* Learning shell scripting: https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html
* Bash programs quick reference: https://github.com/Idnan/bash-guide 
* Debugging in bash:
    * -n - do not run commands and check for syntax errors only
    * -v - echo command before running them
    * -x - echo commands after command-line processing
```
bash -n scriptname
bash -v scriptname
bash -x scriptname
```
Majority of syntax used in bash carries forward to zsh. No problems should be encountered while switching.

## vim
* Programmable editor. Steep learning curve, worth it.
* NOTE: C-S-A-p=Ctrl+Shift+Alt+p. Case matters in most CLI program shortcuts.
* [Vim cheatsheet](https://camo.githubusercontent.com/7df123c8b1367c8cc47769f8f1f1d148df58a1ef/687474703a2f2f692e696d6775722e636f6d2f50515172642e706e67):![vim cheatsheet](config_files/vim_cheatsheet.png)
* [Keyboard cheatsheet](https://camo.githubusercontent.com/bf50f0478b239e1ed99acd5248c247112b82f08f/687474703a2f2f692e696d6775722e636f6d2f68503637542e706e67)
* [Searchable cheatsheet](https://devhints.io/vim)
* See vimrc for syntax of keybindings and changing settings
* zR and zM are particularly useful
* Display custom keybindings - run :map
* fzf.vim and ranger.vim bindings - see vimrc
* read up on vim registers and marks
* :%s/search/replace/gc - search and replace full file (g) with prompt for each match (c).
    * In my .vimrc it is mapped to C-h in Normal mode
* :h [keyword] - help for that keyword
* :tabp, :tabn - are for Window navigation (avoid using windows)
* C-w and arrow keys to navigate splits. C-w,w to go to opposite split.
* C-g - file details
* jj/kk - escape insert mode
* [vim in VS Code:]( https://marketplace.visualstudio.com/items?itemName=vscodevim.vim )
    * af - in visual mode
    * ,m and ,b - bookmarks
    * ; - C-S-p
    * gh - equivalent of mouse hover

## Git
Uploading existing repository to Github: Create repo on GH, copy the "Code" URL and use below lines:
```
git remote add origin remoteRepositoryURL
# or
git remote set-url origin remoteRepositoryURL
# and
git push -f origin master
# to start ignoring a file which was previously committed you need to remove it from cache first:
git rm --cached FILENAME
```
## Docker
Docker makes and attaches containers with all dependencies baked into them. The details of these containers can be saved into an image which can be transferred and used elsewhere.

`docker run image` is used to create and start a container from an image, and then execute a command defined in the image. `docker run -it` attaches an interactive terminal. If you exit the container it can be started again using `docker start`. If you are detached from the container (-d flag) you can run `docker attach` to attach it.

C-p C-q when entered at the attached container terminal detaches you from it. C-d stops the container.

If you build a docker image it is saved along with the images and can be manipulated the same way as the other images.
```bash
# Not attached unless -i or -a are used.
# -t Prints as tty
# -d starts but does not attach
docker run -dit imageName command
# Stop a started container
docker stop containerName
# You can also stop detached containers this way
# Start and attach stopped container
docker start -a containerName

# List all images on system
docker images -a
# List all containers on system
docker ps -a
# Output ports used by container
docker port containerName

# Delete stopped containers
docker container prune
# Delete unused/dangling images (~= autoremove)
docker image prune
# Remove specific image
docker image rm imageName
# Build image from Dockerfile andfiles in a specified directory or URL
docker build dirPath
# Push onto a repository in DockerHub
docker push userName/imageName
# make sure you have run "docker login" first
```
Many of these commands have been aliased. Check bash_aliases file. Refer [here](https://docker-curriculum.com) for a more thorough tutorial on Docker.
## VSCode
* C-S-p: quick commands
* Enter Help: Welcome quick commands menu for quick start
  * Check out the Interactive playground in said Welcome page. Keyboard cheatsheet also is useful.
* Any option can be accessed from quick commands menu
* Regularly sync settings

## Julia
Julia is a new programming language for scientific computing.

## tmux
* Terminal multiplexer. Open multiple instances side by side
* Does not stop running programs when tab is closed/ssh is disconnected.
* [tmux cheatsheet](https://gist.github.com/MohamedAlaa/2961058)
* Some default configurations have been added in .bash_aliases. Check them out.
* See tmux.conf.local for syntax of keybindings and changing settings
* basic.sh installs [gpakosz/.tmux](https://github.com/gpakosz/.tmux) alongside tmux.
* Most shortcuts must be used after prefix. Either C-b or C-a can be used
* [List of shortcuts added by tmux](https://github.com/gpakosz/.tmux#bindings)
* More intuitive splits shortcuts: [prefix]|,-
* Kill session with C-k. Comment out if it conflicts with existing shortcuts
* [prefix]? opens list of keybindings

## fzf
* `fzf # CLI command`
*  C-t, C-r, C-y, Alt-C, 

## ranger
* To launch ranger on Windows+E unset Launch Explorer, make new shortcut with command as `gnome-terminal -x zsh -c "source /home/raghav/.zshrc; ranger"`
* Opens gnome-terminal, sources zshrc and runs ranger
* `rn` to launch ranger
* cd works
* zh - display hidden files
* a - rename
* c - search with different options, rename from scratch
* d - cut and delete options
* f - find and jump to file
* m - make bookmark of current directory
* ` - go to bookmark
* o - sort options
* s - shell command
* v - mark all
* [SPC] - mark file/folder for copy or delete, etc
* ?m - open manpage. Search for KEY BINDINGS to see full list.
* rest vim keybindings
* cw - opens file with file names. edit and save/quit without saving
* :flat n - flatten. use to understand

## Python
* [Colab cheatsheet](https://colab.research.google.com/drive/19Mm2EowaFgj17AqbwlJPriye5A5vmFW3?usp=sharing)
* [Anaconda](https://www.anaconda.com/products/individual) is generally regarded as a good package framework for Scientific python. I do not use it. Follow Download instructions there if you wish to use it.

## Octave/MATLAB
- semicolon suppresses output
- max
- 2^4
- graphing:
    - figure
    - plot
    - subplot
    - clf
    - colorbar
    - colormap
    - contour
    - imagesc
- magic
- if statement
    - if %condition, %stuff, elseif %condition, %stuff, else, %stuff
- for loops:
    - for i=m:n, %stuff, end;
- while loops:
    - while %condition, %stuff, %increment condition optional %, end;
- functions: save as .m file
    - function %output = %name(%parameters) \n %stuff
- This code is useful in setting plot properties
```MATLAB
function plotPropsSetter(currentAxis,xLim,yLim,xLabel,yLabel,plotTitle) %PLOTPROPSSETTER Set plot properties according to guide
%currentAxis=gca
%xlim = [lowerLimit upperLimit]
% remaining parameters must be strings
set(currentAxis,'FontName','Arial');
set(currentAxis,'FontSize',24);
xlim(xLim);
ylim(yLim);
title(plotTitle);
xlabel(xLabel);
ylabel(yLabel);
end
```

[MATLAB cheatsheet](./config_files/Matlab%20Style%20Guidelines%20Cheat%20Sheet.pdf)
## Sage/Mathematica