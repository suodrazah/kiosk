# <p align="center">Kiosk</p>
### <p align="center">Local or Web Kiosk Deployment Script</p>

## tl;dr
```
sudo groupadd docker && sudo usermod -aG docker $USER && newgrp docker
```
```
curl -fsSL https://raw.githubusercontent.com/suodrazah/kiosk/main/deploy.sh -o deploy.sh && sh deploy.sh
```

## Prerequisites:
* **Tested on**
  * AMD64
    * [Ubuntu Server 20.04 LTS 64-bit & 32-bit](https://ubuntu.com/download/server/)
* **SSH Access**
* **[Zerotier network account](https://www.zerotier.com/)**
  * Used for remote management

## Notes:
* **Designed to be executed on a fresh platform**
* **All updates are handled**
* **This will restrict the user to a single fullscreen browser instance.**
  * This still means that if you provide a page with access to the wider web, shenanigans could be had.
  * The local deployment includes wordpress or nginx and is useful for deploying your own kiosk.
* **Join the configured ZeroTier network and remtoely managed internet connected machine.**

## Deployment:
* **This will bring up a local or web kiosk**
```
sudo groupadd docker && sudo usermod -aG docker $USER && newgrp docker
```
```
curl -fsSL https://raw.githubusercontent.com/suodrazah/kiosk/main/deploy.sh -o deploy.sh && sh deploy.sh
```

## To Be Added:
* **Screen orientation function**
* **Reboot scheduler tool**
* **Automatic disabling of system keys and a hotkeys for keyboard + mouse option**
