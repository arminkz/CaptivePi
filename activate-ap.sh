#!/bin/bash

wifidev="wlan0"

createHotspot()
{
    ip link set dev "$wifidev" down
    ip a add 192.168.220.1/24 brd + dev "$wifidev"
    ip link set dev "$wifidev" up
    dhcpcd -k "$wifidev" >/dev/null 2>&1
    systemctl start dnsmasq
    systemctl start hostapd
    nodogsplash
}

if systemctl status hostapd | grep "(running)" >/dev/null 2>&1
then
    echo "Hostspot already active"
elif { wpa_cli status | grep "$wifidev"; } >/dev/null 2>&1
then
	echo "Cleaning wifi files and Activating Hotspot..."
	wpa_cli terminate >/dev/null 2>&1
	ip addr flush "$wifidev"
	ip link set dev "$wifidev" down
	rm -r /var/run/wpa_supplicant >/dev/null 2>&1
	createHotspot
else #"No SSID, activating Hotspot"
	echo "Activating Hotspot..."
    createHotspot
fi