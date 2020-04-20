```shell
COMMAND --help # pulls up help for the command
man COMMAND # pulls up man page for command
which COMMAND # pulls up location of command
chmod +x FILE_NAME # Gives highest read write execute permission to file
mkdir FILE_NAME
rm FILE_NAME # check out available options for this
sudo rm -i /etc/apt/sources.list.d/PPA_Name.list # Removes Repository

# installation interrupted:
sudo dpkg --configure -a
sudo apt --fix-broken install

```