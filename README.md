# <p align="center">Kiosk</p>
### <p align="center">xxxxxxxxxxxxxxxxxxxxxxxxx</p>

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

## Deployment:
* **This will bring up a local or web kiosk**
```
sudo groupadd docker && sudo usermod -aG docker $USER && newgrp docker
```
```
curl -fsSL https://raw.githubusercontent.com/suodrazah/kiosk/main/deploy.sh -o deploy.sh && sh deploy.sh
```
