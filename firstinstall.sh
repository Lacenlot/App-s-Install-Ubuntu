#!/usr/bin/env bash

PPA_LUTRIS="ppa:lutris-team/lutris"
APT_APPS=(
  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  https://linux.dropbox.com/packages/ubuntu/dropbox_2020.03.04_amd64.deb
)
SNAP_APPS=(
 spotify
 code
 postman
 vlc
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

install_java_intellij () {
  if ! dpkg -l | grep -q openjdk-11-jdk; then
    sudo apt install openjdk-11-jdk -y
  else
    echo "JAVA JÁ ESTÁ INSTALADO!"
  fi
  if ! snap list | grep -q intellij-idea-ultimate; then
    sudo snap install intellij-idea-ultimate --classic
  else
    echo "ECLIPSE JÁ ESTÁ INSTALADO!"
  fi
}

install_snap_apps () {
  for apps in ${SNAP_APPS[@]}; do
    if ! snap list | grep -q $apps; then
      [[ $apps == code ]] && sudo snap install code --classic
      [[ $apps != code ]] && sudo snap install $apps
    else
      echo "O SNAP JÁ ESTÁ INSTALADO - " $apps
    fi
  done
}

install_docker()  {
  if ! dpkg -l | grep -q docker-ce; then
  
    sudo apt-get update
  
    sudo apt-get install \
    	apt-transport-https \
    	ca-certificates \
    	curl \
    	gnupg \
    	lsb-release
 
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
    echo \
  	"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  	$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  else
    echo "DOCKER JÁ ESTÁ INSTALADO"
  fi
}

#### UPDATE E LIMPEZA

upgrade_clear () {
  sudo apt update && sudo apt autoclean && sudo apt autoremove -y
  sudo apt update && sudo apt dist-upgrade -y
}

cd ~
remove_locks
add_architecture
repository_lutris
install_apts
install_java_intellij
install_snap_apps
upgrade_clear
