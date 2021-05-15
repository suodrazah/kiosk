#!/bin/bash

#OS - Raspberry Pi OS or Ubuntu Core. SSH Access to run this script.

#Prerequisites
#sudo groupadd docker && sudo usermod -aG docker $USER && newgrp docker
#SSH Access to kiosk

#Update
sudo apt update && sudo apt upgrade -y && sudo apt install net-tools -y

#Install snap
sudo apt install snapd -y

#Install curl
sudo apt install curl -y

#Setup firewall
sudo ufw default deny incoming && sudo ufw default allow outgoing && sudo ufw allow 80/tcp && sudo ufw allow 22/tcp && sudo ufw --force enable

#Get ZeroTier config ready
clear
read -p "Zerotier Network ID?: " ZEROTIER

#Join zerotier network
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join $ZEROTIER

#Update Timezone
read -p "Timezone? (Australia/Hobart): " TIMEZONE
TIMEZONE=${TIMEZONE:-Australia/Hobart}
sudo timedatectl set-timezone Australia/Hobart

#Choose deployment type
echo "Local or Web kiosk deployment (L/w)?"
echo "Local - Installs Wordpress and DB, binds Kiosk address to localhost."
echo "Web - Enter a URL to display in the kiosk."
echo "............."
read TYPE
TYPE=${TYPE:-L}
clear

if [ $TYPE = "L" ]; then

    #Set host
    export URL="http://localhost"

    #Install Docker and Compose
    curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
    sudo curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

    #Copy docker-compose.yaml contents
    rm docker-compose.yaml -f
    
    read -p "Wordpress DB Password?: " DBPWD

    echo "version: '3'" >> docker-compose.yaml
    echo "services:" >> docker-compose.yaml
    echo "  wp:" >> docker-compose.yaml
    echo "    image:  wordpress" >> docker-compose.yaml
    echo "    volumes:" >> docker-compose.yaml
    echo "      - wp-data:/var/www/html" >> docker-compose.yaml
    echo "    networks:" >> docker-compose.yaml
    echo "      - internal-network" >> docker-compose.yaml
    echo "    ports:" >> docker-compose.yaml
    echo "      - 80:80" >> docker-compose.yaml
    echo "    environment:" >> docker-compose.yaml
    echo "      - WORDPRESS_DB_HOST=db" >> docker-compose.yaml
    echo "      - WORDPRESS_DB_USER=db" >> docker-compose.yaml
    echo "      - WORDPRESS_DB_PASSWORD=$DBPWD" >> docker-compose.yaml
    echo "      - WORDPRESS_DB_NAME=db" >> docker-compose.yaml
    echo "  db:" >> docker-compose.yaml
    echo "    image:  mariadb" >> docker-compose.yaml
    echo "    volumes:" >> docker-compose.yaml
    echo "      - db_config:/config" >> docker-compose.yaml
    echo "      - db:/var/lib/mysql" >> docker-compose.yaml
    echo "    networks:" >> docker-compose.yaml
    echo "      - internal-network" >> docker-compose.yaml
    echo "    environment:" >> docker-compose.yaml
    echo "      - MYSQL_DATABASE=db" >> docker-compose.yaml
    echo "      - MYSQL_USER=db" >> docker-compose.yaml
    echo "      - MYSQL_PASSWORD=$DBPWD" >> docker-compose.yaml
    echo "      - MYSQL_RANDOM_ROOT_PASSWORD='1'" >> docker-compose.yaml
    echo "volumes:" >> docker-compose.yaml
    echo "  wp-data:" >> docker-compose.yaml
    echo "  db_config:" >> docker-compose.yaml
    echo "  db:" >> docker-compose.yaml
    echo "networks:" >> docker-compose.yaml
    echo "  internal-network:" >> docker-compose.yaml

    #Deploy containers
    docker-compose up -d

    fi


if [ $TYPE = "w" ]; then
    read -p "Kiosk URL? (e.g. http://localhost, https://site.example.com): " URL
fi

#Force RPi HDMI active
echo hdmi_drive=2 >>  /boot/uboot/config.txt

#Configure Kiosk snap
sudo snap install mir-kiosk
sudo snap set mir-kiosk cursor=none
sudo snap set mir-kiosk daemon=true
sudo snap restart mir-kiosk

#Configure webkit snap
sudo snap install wpe-webkit-mir-kiosk
sudo snap set wpe-webkit-mir-kiosk url=$URL

##To Do
#echo "Orientation"
#echo "Screen is rotated 90° CW"
#echo "Screen is rotated 90° CCW"
#echo "Screen is rotated 180°"
#echo "Screen is mirrored"

clear
echo "Done!, rebooting in a few seconds"
sleep 5
sudo reboot
