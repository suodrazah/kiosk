#!/bin/bash
clear

#Update and install required tools
sudo apt update && sudo apt upgrade -y && sudo apt install net-tools curl -y

#Setup firewall
sudo ufw default deny incoming && sudo ufw default allow outgoing && sudo ufw allow 22/tcp && sudo ufw --force enable

#Get ZeroTier config ready
clear
read -p "Zerotier Network ID?: " ZEROTIER

#Join zerotier network
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join $ZEROTIER
sleep 2

clear

#Configure Raspberry Pi OS
echo "Launching Rapsberry Pi Config Tool in 10 seconds"
echo "Please set System Options -> Boot/Autologin -> Console Autologin"
sleep 10
sudo raspi-config
clear
sudo raspi-config nonint do_overscan 0

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
    echo "Wordpress - Installs Wordpress and DB. Binds Kiosk address to localhost."
    echo "NGINX - Installs NGINX and Filebrowser. Binds Kiosk to localhost."
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
        sudo curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
    
        #Copy docker-compose.yaml contents
        rm docker-compose.yaml -f
        
        read -p "Wordpress DB Password?: " DBPWD
        clear
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
    
     if [ $LOCALTYPE = "n" ]; then
    
        #Set host
        export URL="http://localhost:81"

        #Configure firewall (you'll want local network access in lieu of ZeroTier for transferring videos)
        sudo ufw allow 80/tcp && sudo ufw allow 81/tcp

        #Install Docker and Compose
        curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
        sudo curl -L --fail https://raw.githubusercontent.com/linuxserver/docker-docker-compose/master/run.sh -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose

        #Copy docker-compose.yaml contents
        rm docker-compose.yaml -f
        clear
        echo "version: '3.3'" >> docker-compose.yaml
        echo "services:" >> docker-compose.yaml
        echo "  nginx:" >> docker-compose.yaml
        echo "    image: nginx" >> docker-compose.yaml
        echo "    volumes:" >> docker-compose.yaml
        echo "      - nginx-data:/etc/nginx" >> docker-compose.yaml
        echo "      - web-data:/usr/share/nginx/html" >> docker-compose.yaml
        echo "    networks:" >> docker-compose.yaml
        echo "      - internal-network" >> docker-compose.yaml
        echo "    ports:" >> docker-compose.yaml
        echo "      - 81:80" >> docker-compose.yaml
        echo "  filebrowser:" >> docker-compose.yaml
        echo "    image: hurlenko/filebrowser" >> docker-compose.yaml
        echo "    restart: always" >> docker-compose.yaml
        echo "    networks:" >> docker-compose.yaml
        echo "      - internal-network" >> docker-compose.yaml
        echo "    ports:" >> docker-compose.yaml
        echo "      - 80:8080" >> docker-compose.yaml
        echo "    environment:" >> docker-compose.yaml
        echo "      - TZ=Australia/Hobart" >> docker-compose.yaml
        echo "    volumes:" >> docker-compose.yaml
        echo "      - filebrowser-data:/config" >> docker-compose.yaml
        echo "      - web-data:/data" >> docker-compose.yaml
        echo "networks:" >> docker-compose.yaml
        echo "  internal-network:" >> docker-compose.yaml
        echo "volumes:" >> docker-compose.yaml
        echo "  nginx-data:" >> docker-compose.yaml
        echo "  filebrowser-data:" >> docker-compose.yaml
        echo "  web-data:" >> docker-compose.yaml
    
        #Deploy containers
        docker-compose up -d
        fi   
    
    fi

if [ $TYPE = "w" ]; then
    read -p "Kiosk URL? (e.g. http://192.168.1.254:8080, https://site.example.com): " URL
fi

clear

#DEPLOY FRONT END#

clear

if [ $TYPE != "w" ]; then
    echo "Done!, rebooting in a few seconds. Browse to the kiosk LAN IP (locally or ZeroTier) to configure your content"
    hostname -I
    sleep 10
    sudo reboot
fi

echo "Done!, rebooting in a few seconds."

sleep 10
sudo reboot
