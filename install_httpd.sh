#!/bin/bash

sudo apt update -y
sudo apt install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
