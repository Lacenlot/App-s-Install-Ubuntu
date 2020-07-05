#!/bin/bash

PPA_LUTRIS="ppa:lutris-team/lutris"
GOOGLE_CHROME_LINK="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
DROPBOX_LINK="https://www.dropbox.com/download?plat=lnx.x86_64"

remove_locks () {
  sudo rm /var/lib/dpkg/lock/frontend
  sudo rm /var/cache/apt/archives/lock
}

repository_lutris () {
  sudo add-apt-repository "$PPA_LUTRIS" -y
}

add_architecture () {
  sudo dpkg --add-architecture i386
}

install_google () {
  wget "$GOOGLE_CHROME_LINK" -P $HOME/Downloads
  sudo dpkg -i $HOME/Downloads/*.deb
  sudo apt -f install -y
  #wget -O - "$DROPBOX_LINK" | tar xzf -
  #~/.dropbox-dist/dropboxd
}

install_java_eclipse () {
  sudo apt install openjdk-11-jre-headless #version 11.0.7+10-2ubuntu2~19.10
  sudo snap install --classic eclipse
}

install_snap_apps () {
  sudo snap install --classic code
  sudo snap install spotify
  sudo snap install discord
  sudo snap install pulseaudio
}

update_apt () {
  sudo apt update -y
}

upgrade_clear () {
  sudo apt update
  ##sudo apt update && sudo apt dist-upgrade -y
  sudo apt autoclean
  sudo apt autoremove -y
}

cd ~
remove_locks
repository_lutris
update_apt
install_google
install_java_eclipse
install_snap_apps
upgrade_clear

