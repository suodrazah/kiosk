# <p align="center">Kiosk</p>
### <p align="center">Web Kiosk Deployment Script</p>

## tl;dr
```
sudo groupadd docker && sudo usermod -aG docker $USER && newgrp docker
```
```
curl -fsSL https://raw.githubusercontent.com/suodrazah/kiosk/main/deploy.sh -o deploy.sh && sh deploy.sh
```

## Prerequisites:
* **_Tested on_ Ubuntu Core and Raspberry Pi OS running on RPi 4 4GB**
* **SSH Access**
* **Zerotier network account**
  * Used for remote management

## Notes:
* **Designed to be executed on a fresh platform**
* **All updates are handled**
* **This will restrict the user to a single fullscreen browser instance with absolutely no access to anything.
* * This means that if you provide a page with access to the wider web, shenanigans could be had. The local deployment includes a wordpress backend and is useful for deploying your own kiosk.

## Deployment:
* **This will bring up a local or web kiosk**
```
sudo groupadd docker && sudo usermod -aG docker $USER && newgrp docker
```
```
curl -fsSL https://raw.githubusercontent.com/suodrazah/kiosk/main/deploy.sh -o deploy.sh && sh deploy.sh
```
