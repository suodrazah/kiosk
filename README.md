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
* **Tested on**
  * [Raspberry Pi 4](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/)
    * [Raspberry Pi OS 64-Bit](https://www.raspberrypi.org/software/)
* **SSH Access**
* **[Zerotier network account](https://www.zerotier.com/)**
  * Used for remote management

## Notes:
* **Designed to be executed on a fresh platform**
* **All updates are handled**
* **This will restrict the user to a single fullscreen browser instance with absolutely no access to anything.**
  * This still means that if you provide a page with access to the wider web, shenanigans could be had.
  * The local deployment includes wordpress and is useful for deploying your own kiosk.
* **Join the configured ZeroTier network and remtoely managed internet connected machine.**

## Deployment:
* **This will bring up a local or web kiosk**
```
sudo groupadd docker && sudo usermod -aG docker $USER && newgrp docker
```
```
curl -fsSL https://raw.githubusercontent.com/suodrazah/kiosk/main/deploy.sh -o deploy.sh && sh deploy.sh
```
