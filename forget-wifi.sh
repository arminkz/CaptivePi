#!/bin/sh

sudo perl -i -0pe 's/network=\{.*\}//gs' /etc/wpa_supplicant/wpa_supplicant.conf