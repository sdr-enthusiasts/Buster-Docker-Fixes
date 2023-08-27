#!/command/with-contenv bash
# shellcheck shell=bash

if ! sleep 0 >/dev/null 2>&1; then
	echo "########################################################################"
	echo "######### YOU NEED TO UPDATE YOUR SYSTEM TO RUN THIS CONTAINER #########"
	echo "Please visit: https://github.com/sdr-enthusiasts/Buster-Docker-Fixes"
	echo "########################################################################"

	exit 1
fi

exit 0