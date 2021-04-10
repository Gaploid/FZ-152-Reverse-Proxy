#!/bin/bash

# Installing lets encrypt bot and configure SSL
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python3-certbot-nginx

sudo certbot --nginx