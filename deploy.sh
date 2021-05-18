#!/bin/bash

export BRANCH=ubuntu_dev

clear
#Change default password
read -p "You should definitely change the default password, do this now? (Y/n): " CHANGEPWD
CHANGEPWD=${CHANGEPWD:-Y}

if [ $CHANGEPWD = "Y" ]; then
   passwd
fi

#ENABLE NO PASSWORD LOGIN - #TO DO - SEPARATE USERS
#export USER=$USER
#export TERM=$TERM
#sudo rm /etc/systemd/system/autologin@.service -f
#sudo bash -c 'echo "[Service]" >> /etc/systemd/system/autologin@.service'
#sudo bash -c 'echo "ExecStart=" >> /etc/systemd/system/autologin@.service'
#sudo bash --preserve-env bash -c 'echo "ExecStart=-/sbin/agetty --noissue --autologin $USER %I $TERM" >> /etc/systemd/system/autologin@.service'
#sudo bash -c 'echo "Type=idle" >> /etc/systemd/system/autologin@.service'
#sudo ln -s -f /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
#sudo systemctl daemon-reload
#sudo systemctl enable getty@tty1.service

read -p "auto login ok?" GBYJ

#Update
sudo apt update && sudo apt upgrade -y 

#Install required tools
sudo apt install net-tools curl -y

#Setup firewall
sudo apt install ufw && sudo ufw default deny incoming && sudo ufw default allow outgoing && sudo ufw allow 22/tcp && sudo ufw --force enable

#Get ZeroTier config ready
clear
read -p "Zerotier Network ID?: " ZEROTIER

#Join zerotier network
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join $ZEROTIER
sleep 2

clear

#Update Timezone
read -p "Timezone? (Australia/Hobart): " TIMEZONE
TIMEZONE=${TIMEZONE:-Australia/Hobart}
sudo timedatectl set-timezone Australia/Hobart
sleep 2

clear

#Choose deployment type
echo "Local or Web kiosk deployment (L/w)?"
echo "Local - Installs NGINX and FileBrowser, or Wordpress and DB. Binds Kiosk address to localhost."
echo "Web - Requests a URL to display in the kiosk."
echo "............."
read TYPE
TYPE=${TYPE:-L}
clear

if [ $TYPE = "L" ]; then

    echo "Wordpress or NGINX (W/n)?"
    echo "Wordpress - Installs Wordpress and DB."
    echo "NGINX - Installs NGINX and Filebrowser."
    echo "............."
    read LOCALTYPE
    TYPE=${LOCALTYPE:-W}
    clear
    
    if [ $LOCALTYPE = "W" ]; then

        #Set host
        export URL="http://localhost"
        
        #Configure firewall (you'll want local network access in lieu of ZeroTier for transferring videos)
        sudo ufw allow 80/tcp 
    
        #Install Docker and Compose
        curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
        curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

        #Get DB Password
        read -p "Wordpress DB Password?: " DBPWD
        export DBPWD=$DBPWD
        
        #Download relevant yaml
        rm docker-compose.yaml -f && rm docker-compose.yml -f
        clear
        curl -fsSL https://raw.githubusercontent.com/suodrazah/kiosk/$BRANCH/deploy/wordpress.yml -o docker-compose.yml

        #Deploy containers
        docker-compose up -d
        fi
    
     if [ $LOCALTYPE = "n" ]; then
    
        #Set host
        export URL="http://localhost:81"

        #Configure firewall (you'll want local network access in lieu of ZeroTier for transferring videos)
        sudo ufw allow 80/tcp && sudo ufw allow 81/tcp

        #Install Docker and Compose
        curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
        sudo curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

        #Download relevant yaml
        rm docker-compose.yaml -f && rm docker-compose.yml -f
        clear
        curl -fsSL https://raw.githubusercontent.com/suodrazah/kiosk/$BRANCH/deploy/nginx.yml -o docker-compose.yml
    
        #Deploy containers
        docker-compose up -d
        fi   
    
    fi

if [ $TYPE = "w" ]; then
    read -p "Kiosk URL? (e.g. http://192.168.1.254:8080, https://site.example.com): " URL
fi

#Install minimum GUI components
sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox -y

#Install Chromium
sudo apt-get install --no-install-recommends chromium-browser -y

#Configure Autostart
export URL=$URL
sudo bash -c 'rm /etc/xdg/openbox/autostart -f'
sudo bash -c 'echo "xset -dpms" >> /etc/xdg/openbox/autostart'
sudo bash -c 'echo "xset s noblank" >> /etc/xdg/openbox/autostart'
sudo bash -c 'echo "xset s off" >> /etc/xdg/openbox/autostart'
sudo --preserve-env bash -c 'echo "chromium-browser --incognito --disable-pinch --overscroll-history-navigation=0 --ignore-gpu-blocklist --disable-features="TouchpadOverscrollHistoryNavigation" --enable-accelerated-video-decode --enable-gpu-rasterization  --noerrdialogs --disable-infobars --check-for-update-interval=31536000 --kiosk $URL" >> /etc/xdg/openbox/autostart'

#Start GUI on boot
sudo echo "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- -nocursor" >> ~/.bash_profile
source ~/.bash_profile

clear

if [ $TYPE != "w" ]; then
    echo "Done!, rebooting in a few seconds."
    echo "Using another PC, browse to the kiosk LAN IP (locally or ZeroTier) to configure your content"
    hostname -I
    sleep 10
    sudo reboot
fi

if [ $TYPE = "n" ]; then
    echo "Default username:password for filebrowser is admin:admin, and there's a dark mode."
    echo "Drag and drop your static content, browse to IP:81 for a preview."
    hostname -I
    sleep 10
    sudo reboot
fi

echo "Done!, rebooting in a few seconds."

sleep 10
sudo reboot
