# shell
```
COMMAND --help # pulls up help for the command
man COMMAND # pulls up man page for command
which COMMAND # pulls up location of command
chmod +x FILE_NAME # Gives highest read write execute permission to file
mkdir FILE_NAME
rm FILE_NAME # check out available options for this
sudo rm -i /etc/apt/sources.list.d/PPA_Name.list # removes repository
df # file system information that does not require root access
sudo fdisk -l # file sys info that requires root access
```
# installation interrupted:
```
sudo dpkg --configure -a
sudo apt --fix-broken install
```
# individual packages:
* fzf: fzf[CR], C-t, C-r, Alt-C
* ranger: rn, zh, dD, [SPC], rest vim keybindings
# VSCode
* Ctrl+Shift+P: quick commands
* Enter Help: Welcome quick commands menu for quick start
* Any option can be accessed from quick commands menu
* Regularly sync settings
# vim
* [Vim cheatsheet](https://camo.githubusercontent.com/7df123c8b1367c8cc47769f8f1f1d148df58a1ef/687474703a2f2f692e696d6775722e636f6d2f50515172642e706e67)
* Custom keybindings: run :map
* for fzf.vim and ranger.vim bindings see vimrc
* read up on vim registers and marks
* :%s/search/replace/gc is search and replace with prompt for each match.
* In my .vimrc it is mapped to Ctrl+H in Normal mode
* :h [keyword] is help for that keyword
* :tabp, :tabn are for Window navigation (avoid using windows)
* Ctrl-W and arrow keys to navigate splits
# Python
* [Colab cheatsheet](https://colab.research.google.com/drive/19Mm2EowaFgj17AqbwlJPriye5A5vmFW3?usp=sharing)
* [Anaconda](https://www.anaconda.com/products/individual) is generally regarded as a good package framework for Scientific python. I do not use it. Follow Download instructions there if you wish to use it.
