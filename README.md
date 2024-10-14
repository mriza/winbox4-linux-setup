# Mikrotik's Winbox4 for Linux setup
A simple helper script to install Mikrotik's Winbox 4 on Linux

# Make sure you have curl and unzip.

## on Fedora, CentOS, AlmaLinux, RockyLinux, etc
`sudo dnf install curl unzip`

## on Debian, Ubuntu, etc
`sudo apt install curl unzip`

# Usage:
## Install:
`sudo ./install_winbox.sh --install` or `sudo ./install_winbox.sh -i`

## Update:
`sudo ./install_winbox.sh --update` or `sudo ./install_winbox.sh -u`

## Remove:
`sudo ./install_winbox.sh --remove` or `sudo ./install_winbox.sh -rm`