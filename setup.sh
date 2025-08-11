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

echo "[INFO] Starting dnsmasq..."
sudo pkill dnsmasq
sudo dnsmasq -C /etc/dnsmasq.conf -d &
sleep 2

echo "[INFO] Enabling IP forwarding..."
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

echo "[INFO] Setting up NAT..."
sudo iptables --flush
sudo iptables --table nat --flush
sudo iptables --delete-chain
sudo iptables --table nat --delete-chain

sudo iptables -P FORWARD ACCEPT
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i at0 -o wlan0 -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o at0 -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "[INFO] Done"
