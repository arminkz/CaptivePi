#!/bin/sh
#Copyright (C) The Nodogsplash Contributors 2004-2020
#Copyright (C) BlueWave Projects and Services 2015-2020
#This software is released under the GNU GPL license.

# This is an example script for BinAuth
# It verifies a client username and password and sets the session length.
#
# If BinAuth is enabled, NDS will call this script as soon as it has received an authentication request
# from the web page served to the client's CPD (Captive Portal Detection) Browser by one of the following:
#
# 1. splash_sitewide.html
# 2. PreAuth
# 3. FAS
#
# The username and password entered by the clent user will be included in the query string sent to NDS via html GET
# For an example, see the file splash_sitewide.html


wifidev="wlan0"

killHotspot()
{
    ip link set dev "$wifidev" down
    systemctl stop hostapd
    systemctl stop dnsmasq
    ip addr flush dev "$wifidev"
    ip link set dev "$wifidev" up
    dhcpcd  -n "$wifidev" >/dev/null 2>&1
}

METHOD="$1"
CLIENTMAC="$2"

case "$METHOD" in
	auth_client)
		USERNAME="$3"
		PASSWORD="$4"
		REDIR="$5"
		USER_AGENT="$6"
		CLIENTIP="$7"

		#purge cuurrent networks
		sudo perl -i -0pe 's/network=\{.*\}//gs' /etc/wpa_supplicant/wpa_supplicant.conf

		#add config to wpa_supplicant
		sudo echo "network={\n\tssid=\"$USERNAME\"\n\tpsk=\"$PASSWORD\"\n\tkey_mgmt=WPA-PSK\n}" >> /etc/wpa_supplicant/wpa_supplicant.conf

		wpa_cli terminate >/dev/null 2>&1
		ip addr flush "$wifidev"
		ip link set dev "$wifidev" down
		rm -r /var/run/wpa_supplicant >/dev/null 2>&1

		killHotspot
		
		wpa_supplicant -B -i "$wifidev" -c /etc/wpa_supplicant/wpa_supplicant.conf >/dev/null 2>&1

		echo 0 0 0

		ndsctl stop

		;;
	client_auth|client_deauth|idle_deauth|timeout_deauth|ndsctl_auth|ndsctl_deauth|shutdown_deauth)
		INGOING_BYTES="$3"
		OUTGOING_BYTES="$4"
		SESSION_START="$5"
		SESSION_END="$6"
		# client_auth: Client authenticated via this script.
		# client_deauth: Client deauthenticated by the client via splash page.
		# idle_deauth: Client was deauthenticated because of inactivity.
		# timeout_deauth: Client was deauthenticated because the session timed out.
		# ndsctl_auth: Client was authenticated by the ndsctl tool.
		# ndsctl_deauth: Client was deauthenticated by the ndsctl tool.
		# shutdown_deauth: Client was deauthenticated by Nodogsplash terminating.
		;;
esac

