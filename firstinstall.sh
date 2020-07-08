#!/usr/bin/env bash

PPA_LUTRIS="ppa:lutris-team/lutris"
APT_APPS=(
  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  https://linux.dropbox.com/packages/ubuntu/dropbox_2020.03.04_amd64.deb
)
SNAP_APPS=(
 code
 spotify
 discord
 postman
 pulseaudio
)

##### REQUISITOS PARA RODAR O SCRIPT!

if ! ping -c 5 8.8.8.8 -q &> /dev/null; then
  echo "COMPUTADOR SEM CONEXÃO COM A INTERNET!"
  exit 1
fi

if [[ ! -x `which wget` ]]; then
  sudo apt install wget -y
else
  echo "WGET JÁ ESTÁ INSTALADO!"
fi

#####

#### REMOVENDO POSSIVEIS LOCKS, ADICIONANDO REPOSITORIOS E ARQ i386(32Bits)

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

####

#### INSTALAÇÃO DOS APP'S

install_apts () {
  for url in ${APT_APPS[@]}; do
    parser_url=$(echo ${url##*/} sed 's/-/_/g' | cut -d _ -f 1)
    if ! dpkg -l | grep -iq $parser_url; then
      wget -c "$url" -P $HOME/Downloads
      sudo dpkg -i $HOME/Downloads/${url##*/}
    else
      echo "PROGRAMA JÁ ESTÁ INSTALADO!"
    fi
    sudo apt -f install -y
  done
}

install_java_eclipse () {
  if ! dpkg -l | grep -q openjdk-11-jre-headless; then
    sudo apt install openjdk-11-jre-headless -y #version 11.0.7+10-2ubuntu2~19.10
  else
    echo "JAVA JÁ ESTÁ INSTALADO!"
  fi
  if ! snap list | grep -q eclipse; then
    sudo snap install --classic eclipse
  else
    echo "ECLIPSE JÁ ESTÁ INSTALADO!"
  fi
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

#####

#### UPDATE E LIMPEZA

upgrade_clear () {
  sudo apt update && sudo apt autoclean && sudo apt autoremove -y
  ##sudo apt update && sudo apt dist-upgrade -y // checar se tem att da distro!
}

####

cd ~
remove_locks
add_architecture
repository_lutris
install_apts
install_java_eclipse
install_snap_apps
upgrade_clear
