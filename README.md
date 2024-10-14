# Mikrotik's Winbox4 for Linux setup
A simple helper script to install Mikrotik's Winbox 4 on Linux. Download the `winbox-setup.sh` to your computer and run it (see usage).

# Make sure you have curl and unzip.

## on Fedora, CentOS, AlmaLinux, RockyLinux, etc
`sudo dnf install curl unzip`

## on Debian, Ubuntu, etc
`sudo apt install curl unzip`

# Usage:
## Install:
`sudo ./winbox-setup.sh --install` or `sudo ./winbox-setup.sh -i`

## Update:
`sudo ./winbox-setup.sh --update` or `sudo ./winbox-setup.sh -u`

## Remove:
`sudo ./winbox-setup.sh --remove` or `sudo ./winbox-setup.sh -rm`