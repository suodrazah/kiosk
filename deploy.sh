#!/bin/bash
# Copyright 2021 suo
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# <http://www.gnu.org/licenses/>.

export BRANCH="ubuntu_dev"

crontab -r

clear
#Change default password
read -p "You should definitely change the default password, do this now? (Y/n): " CHANGEPWD
CHANGEPWD=${CHANGEPWD:-Y}
if [ $CHANGEPWD = "Y" ]; then
   passwd
fi

clear
#ENABLE NO PASSWORD
export USER=$USER
{ echo "[Service]"; 
  echo "ExecStart=";
  echo "ExecStart=-/sbin/agetty --noissue --autologin $USER %I $TERM";
  echo "Type=idle"
  } >~/getty-override.conf
sudo env SYSTEMD_EDITOR="cp $HOME/getty-override.conf" systemctl edit getty@tty1.service

clear
#Update
sudo apt update && sudo apt upgrade -y 

clear
#Install required tools
sudo apt install net-tools curl -y

clear
#Setup firewall
sudo apt install ufw && sudo ufw default deny incoming && sudo ufw default allow outgoing && sudo ufw allow 22/tcp && sudo ufw --force enable

clear
#Setup WiFi
read -p "Setup WiFi? (N/y): " WIFI
WIFI=${WIFI:-N}
if [ $WIFI = "y" ]; then
   sudo apt install wpasupplicant -y
   read -p "SSID: " SSID
   read -p "PSK: " PSK
   WLAN="$(ls /sys/class/net | grep -m 1 wl*)"
   ETH="$(ls /sys/class/net | grep -m 1 'enp*\|eth*')"
   export WLAN=$WLAN
   export SSID=$SSID
   export PSK=$PSK
   export ETH=$ETH
   sudo rm /etc/netplan/* -rf
   sudo touch /etc/netplan/netplan.yaml
   sudo bash -c 'echo "network:" >> /etc/netplan/netplan.yaml'
   sudo bash -c 'echo "    ethernets:" >> /etc/netplan/netplan.yaml'
   sudo --preserve-env bash -c 'echo "        $ETH:" >> /etc/netplan/netplan.yaml'
   sudo bash -c 'echo "            dhcp4: true" >> /etc/netplan/netplan.yaml'
   sudo bash -c 'echo "            optional: true" >> /etc/netplan/netplan.yaml'
   sudo bash -c 'echo "    version: 2" >> /etc/netplan/netplan.yaml'
   sudo bash -c 'echo "    wifis:" >> /etc/netplan/netplan.yaml'
   sudo --preserve-env bash -c 'echo "        $WLAN:" >> /etc/netplan/netplan.yaml'
   sudo bash -c 'echo "            optional: true" >> /etc/netplan/netplan.yaml'
   sudo bash -c 'echo "            access-points:" >> /etc/netplan/netplan.yaml'
   sudo --preserve-env bash -c 'echo "                \"$SSID\":" >> /etc/netplan/netplan.yaml'
   sudo --preserve-env bash -c 'echo "                    password: \"$PSK\"" >> /etc/netplan/netplan.yaml'
   sudo bash -c 'echo "            dhcp4: true" >> /etc/netplan/netplan.yaml'
   sudo netplan apply
   echo "OK, WiFi should be coming online..."
   sleep 5
   echo "This should be your connection: "
   iwgetid
   sleep 3
   echo "Continuing..."
   sleep 2
fi

clear
#Get ZeroTier config ready
read -p "Zerotier Network ID? (Press enter to ignore): " ZEROTIER
ZEROTIER=${ZEROTIER:-X}
if [ $ZEROTIER != "X" ]; then
   #Join zerotier network
   curl -s https://install.zerotier.com | sudo bash
   clear
   sudo zerotier-cli join $ZEROTIER
   sleep 5
fi

clear
#Audio
sudo apt install libasound2 libasound2-plugins alsa-utils alsa-oss -y
sudo apt install pulseaudio pulseaudio-utils -y
sudo usermod -aG pulse,pulse-access $USER
pacmd set-sink-mute n 0
#sudo apt install python3.8 python3-pip -y
#pip install flask
#wget https://github.com/JiriSko/amixer-webui/releases/download/v1.0.0-rc/amixer-webui_1.0.0-rc_all.deb
#sudo dpkg -i amixer-webui_1.0.0-rc_all.deb
#sudo update-rc.d amixer-webui defaults
#sudo /etc/init.d/amixer-webui start
#sudo /etc/init.d/amixer-webui enable
#sudo ufw allow 8080/tcp

clear
#Update Timezone
read -p "Timezone? (Australia/Hobart): " TIMEZONE
TIMEZONE=${TIMEZONE:-Australia/Hobart}
sudo timedatectl set-timezone Australia/Hobart

clear
#Choose deployment type
echo "********************************************"
echo "Local or Web kiosk deployment (L/w)?"
echo "Local - Installs NGINX and FileBrowser, or Wordpress and DB. Binds Kiosk address to localhost."
echo "Web - Requests a URL to display in the kiosk."
echo "............."
read TYPE
TYPE=${TYPE:-L}
clear

if [ $TYPE = "L" ]; then

    echo "Wordpress or NGINX (w/N)?"
    echo "Wordpress - Installs Wordpress and DB."
    echo "NGINX - Installs NGINX and Filebrowser."
    echo "............."
    read LOCALTYPE
    TYPE=${LOCALTYPE:-N}
    clear
    
    if [ $LOCALTYPE = "w" ]; then

        #Set host
        export URL="http://localhost"

        #Configure firewall (you'll want local network access in lieu of ZeroTier for transferring videos)
        sudo ufw allow 80/tcp

        #Install Docker and Compose
        curl -fsSLk https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
        sudo curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

        #Download relevant yaml
        rm docker-compose.yaml -f && rm docker-compose.yml -f
        clear
        curl -fsSLk https://raw.githubusercontent.com/suodrazah/kiosk/$BRANCH/deploy/wordpress.yml -o docker-compose.yml

        #Deploy containers
        docker-compose up -d
        fi
    
     if [ $LOCALTYPE = "N" ]; then
    
        #Set host
        export URL="http://localhost:81"

        #Configure firewall (you'll want local network access in lieu of ZeroTier for transferring videos)
        sudo ufw allow 80/tcp && sudo ufw allow 81/tcp

        #Install Docker and Compose
        curl -fsSLk https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
        sudo curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

        #Download relevant yaml
        rm docker-compose.yaml -f && rm docker-compose.yml -f
        clear
        curl -fsSLk https://raw.githubusercontent.com/suodrazah/kiosk/$BRANCH/deploy/nginx.yml -o docker-compose.yml
    
        #Deploy containers
        docker-compose up -d
        fi   
    
    fi

if [ $TYPE = "w" ]; then
    read -p "Kiosk URL? (e.g. http://192.168.1.254:8080, https://site.example.com): " URL
fi

clear
#Install minimum GUI components
sudo apt install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox -y

clear
#Install Chromium
sudo apt install --no-install-recommends chromium-browser -y

clear
#Configure Autostart
export URL=$URL
sudo bash -c 'rm /etc/xdg/openbox/autostart -f'
sudo bash -c 'echo "xset -dpms" >> /etc/xdg/openbox/autostart'
sudo bash -c 'echo "xset s noblank" >> /etc/xdg/openbox/autostart'
sudo bash -c 'echo "xset s off" >> /etc/xdg/openbox/autostart'
sudo --preserve-env bash -c 'echo "chromium-browser --incognito --disable-pinch --overscroll-history-navigation=0 --ignore-gpu-blocklist --disable-features="TouchpadOverscrollHistoryNavigation" --enable-accelerated-video-decode --enable-gpu-rasterization  --noerrdialogs --disable-infobars --check-for-update-interval=31536000 --kiosk $URL" >> /etc/xdg/openbox/autostart'

clear
#Start GUI on boot
sudo echo "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- -nocursor" >> ~/.bash_profile
#sudo tee -a "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- -nocursor" ~/.bash_profile
#source ~/.bash_profile

clear
#Rotate screen - !!!TO DO - ROTATE/TRANSLATE TOUCH INPUT OF SCREEN!!!
read -p "Rotate Screen? (N/y): " ROTATE
ROTATE=${ROTATE:-N}
if [ $ROTATE = "y" ]; then
   read -p "Rotate degrees - '0', '90', '180' or '270'. (0): " ROTATION
   ROTATION=${ROTATION:-0}
   case $ROTATION in
   0)
    export ROTATION="normal"
    ;;
  90)
    export ROTATION="right"
    ;;
  180)
    export ROTATION="inverted"
    ;;
  270)
    export ROTATION="left"
    ;;
  *)
    export ROTATION="normal"
    ;;
   esac
   DISPLAY=:0 xrandr -o $ROTATION
   crontab -l > rotatecron
   echo "@reboot sleep 30 && DISPLAY=:0 xrandr -o $ROTATION >/dev/null 2>&1" >> rotatecron
   crontab rotatecron
   rm rotatecron
   clear
   echo "Rotation occurs 30 seconds after boot, so don't panic!"
   sleep 5
fi

clear
#Scheduled reboot
read -p "Schedule Reboot? (N/y): " REBOOT
REBOOT=${REBOOT:-N}
if [ $REBOOT = "y" ]; then
   read -p "Enter Cronjob - default is 0400 daily (0 4 * * *): " REBOOTCRON
   REBOOTCRON=${REBOOTCRON:-"0 4 * * *"}
   crontab -l > crontemp
   echo "$REBOOTCRON /sbin/shutdown -r >/dev/null 2>&1" >> crontemp
   crontab crontemp
   rm crontemp
fi

clear

if [ $TYPE != "w" ]; then
    echo "Done! (Probably)"
#    echo "Browse to IP:8080 for volume control."
    hostname -I
    read -p "Press enter to continue" FOO
    sudo reboot
fi

if [ $LOCALTYPE = "N" ]; then
    echo "Done! (Probably)"
    echo "Browse to kiosk IP using LAN or ZeroTier to configure your static content."
    echo "Default username:password for filebrowser is admin:admin, and there's a dark mode."
    echo "Drag and drop your static content, browse to IP:81 for a preview."
#    echo "Browse to IP:8080 for volume control."
    hostname -I
    read -p "Press enter to continue" FOO
    sudo reboot
fi

if [ $LOCALTYPE = "w" ]; then
    echo "Done! (Probably)"
    echo "Browse to kiosk IP using LAN or ZeroTier to configure your Wordpress content."
#    echo "Browse to IP:8080 for volume control."
    hostname -I
    read -p "Press enter to continue" FOO
    sudo reboot
fi

exit
