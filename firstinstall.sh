#!/bin/bash

PPA_LUTRIS="ppa:lutris-team/lutris"
GOOGLE_CHROME_LINK="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
DROPBOX_LINK="https://www.dropbox.com/download?plat=lnx.x86_64"
SNAP_APPS=(
 code
 spotify
 discord
 postman
 pulseaudio
)

if ! ping -c 5 8.8.8.8 -q &> /dev/null; then
  echo "COMPUTADOR SEM CONEXÃO COM A INTERNET!"
  exit 1
fi

if [[ ! -x `which wget` ]]; then
  sudo apt install wget -y
else
  echo "WGET JÁ ESTÁ INSTALADO!"
fi

remove_locks () {
  sudo rm /var/lib/dpkg/lock/frontend
  sudo rm /var/cache/apt/archives/lock
}

repository_lutris () {
  sudo add-apt-repository "$PPA_LUTRIS" -y
}

add_architecture () {
  sudo dpkg --add-architecture i386
  sudo apt update -y
}

install_google_chrome () {
  parser_url=$(echo ${GOOGLE_CHROME_LINK##*/} sed 's/-/_/g' | cut -d _ -f 1)
  if ! dpkg -l | grep -iq $parser_url; then
    wget -c "$GOOGLE_CHROME_LINK" -P $HOME/Downloads
    sudo dpkg -i $HOME/Downloads/${GOOGLE_CHROME_LINK##*/}
  else
    echo "GOOGLE CHROME JÁ ESTÁ INSTALADO!"
  fi
  sudo apt -f install -y
}

#wget -O - "$DROPBOX_LINK" | tar xzf -
#~/.dropbox-dist/dropboxd

install_java_eclipse () {
  if ! dpkg -l | grep -q openjdk-11-jre-headless; then
    sudo apt install openjdk-11-jre-headless -y #version 11.0.7+10-2ubuntu2~19.10
  else
    echo "JAVA JÁ ESTÁ INSTALADO!"
  fi
  sudo snap install --classic eclipse
}

install_snap_apps () {
  for apps in ${SNAP_APPS[@]}; do
    if ! snap list | grep -q $apps; then
      [[ $apps == code ]] && sudo snap install --classic code
      [[ $apps != code ]] && sudo snap install $apps
    else
      echo "O SNAP JÁ ESTÁ INSTALADO - " $apps
    fi
  done
}

upgrade_clear () {
  sudo apt update && sudo apt autoclean && sudo apt autoremove -y
  ##sudo apt update && sudo apt dist-upgrade -y // checar se tem att da distro!
}

cd ~
remove_locks
add_architecture
repository_lutris
install_google_chrome
install_java_eclipse
install_snap_apps
upgrade_clear
