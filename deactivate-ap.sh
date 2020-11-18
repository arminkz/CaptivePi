#!/bin/bash

wifidev="wlan0"

killHotspot()
{
    echo "Shutting Down Hotspot"
    ip link set dev "$wifidev" down
    systemctl stop hostapd
    systemctl stop dnsmasq
    ip addr flush dev "$wifidev"
    ip link set dev "$wifidev" up
    dhcpcd  -n "$wifidev" >/dev/null 2>&1
}

ndsctl stop >/dev/null 2>&1
if systemctl status hostapd | grep "(running)" >/dev/null 2>&1
then #hotspot running and ssid in range
	killHotspot
	echo "Hotspot Deactivated, Bringing Wifi Up"
	wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1
elif { wpa_cli -i "$wifidev" status | grep 'ip_address'; } >/dev/null 2>&1
then #Already connected
    echo "Wifi already connected to a network"
else #ssid exists and no hotspot running connect to wifi network
	echo "Connecting to the WiFi Network"
	wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1
fi