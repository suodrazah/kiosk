# <p align="center">Kiosk</p>
### <p align="center">Local or Web Kiosk Deployment Script</p>

## tl;dr
```
sudo groupadd docker && sudo usermod -aG docker $USER && newgrp docker
```
```
curl -fsSLk https://raw.githubusercontent.com/suodrazah/kiosk/ubuntu_dev/deploy.sh -o deploy.sh && sh deploy.sh
```

## Prerequisites:
* **Tested on**
  * AMD64
    * [Ubuntu Server 20.04 LTS](https://ubuntu.com/download/server/)
* **SSH Access**
* **[Zerotier network account](https://www.zerotier.com/)**
  * Used for remote management

## Notes:
* **Designed to be executed on a fresh platform**
* **All updates are handled**
* **This will restrict the user to a single fullscreen browser instance.**
  * This still means that if you provide a page with access to the wider web, shenanigans could be had.
  * The local deployment includes wordpress or nginx and is useful for deploying your own kiosk.
* **Join the configured ZeroTier network and remotely manage internet connected kiosks.**

## Deployment:
* **This will bring up a local or web kiosk**
```
sudo groupadd docker && sudo usermod -aG docker $USER && newgrp docker
```
```
curl -fsSLk https://raw.githubusercontent.com/suodrazah/kiosk/dev_ubuntu/deploy.sh -o deploy.sh && sh deploy.sh
```

## To Be Added:
* **Touchscreen input orientation (sync with screen orientation**
* **Automatic installation of useful chrome extensions - restricted touch keyboard, auto idle refresh, ublock origins, disable tabs and popups, auto crash refresh, etc**
* **Alsamixer/volume WebUI**
* **Realtime unidirectional delta sync tmpfs for a more responsive user experience e,g, wp-content/cache and nginx/www**
