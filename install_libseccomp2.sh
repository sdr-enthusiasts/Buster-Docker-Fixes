#!/bin/bash

mkdir -p /etc/s6-overlay/s6-rc.d/libseccomp2
mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d
mkdir -p /etc/s6-overlay/scripts

curl -sSL https://raw.githubusercontent.com/sdr-enthusiasts/Buster-Docker-Fixes/main/etc/s6-overlay/s6-rc.d/libseccomp2/type -o /etc/s6-overlay/s6-rc.d/libseccomp2/type
curl -sSL https://raw.githubusercontent.com/sdr-enthusiasts/Buster-Docker-Fixes/main/etc/s6-overlay/s6-rc.d/libseccomp2/up -o /etc/s6-overlay/s6-rc.d/libseccomp2/up
curl -sSL https://raw.githubusercontent.com/sdr-enthusiasts/Buster-Docker-Fixes/main/etc/s6-overlay/s6-rc.d/user/contents.d/libseccomp2 -o /etc/s6-overlay/s6-rc.d/user/contents.d/libseccomp2
curl -sSL https://raw.githubusercontent.com/sdr-enthusiasts/Buster-Docker-Fixes/main/etc/s6-overlay/scripts/libseccomp2_check.sh -o /etc/s6-overlay/scripts/libseccomp2_check.sh