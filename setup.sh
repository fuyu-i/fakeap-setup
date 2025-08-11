#!/bin/bash

echo "[INFO] Configuring at0..."
sudo ifconfig at0 up 10.0.0.1 netmask 255.255.255.0

echo "[INFO] Backing up original dnsmasq.conf..."
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup

echo "[INFO] Writing new dnsmasq config..."
cat << EOL | sudo tee /etc/dnsmasq.conf
interface=at0
dhcp-range=10.0.0.10,10.0.0.50,12h
dhcp-option=3,10.0.0.1
dhcp-option=6,10.0.0.1
server=8.8.8.8
log-queries
log-dhcp
EOL
