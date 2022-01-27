#!/bin/bash
#
# This script updates a BUSTER Debian distribution so it will have the latest version of libseccomp2.
# The upgrade is necessary to run Bullseye-based Docker containers on a Buster host system.
# For more information about this issue, please see https://docs.linuxserver.io/faq#option-2 and https://github.com/linuxserver/docker-jellyfin/issues/71#issuecomment-733621693
#
# MIT License
# Copyright (c) 2021, Fred Clausen, Ramon F. Kolb (kx1t), and others
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Welcome message:
echo "Welcome to the libseccomp2 upgrade script for Buster. This script is meant to be run on Raspberry Pi Buster-based systems that have Docker containers"
echo "that run Debian Bullseye or later. For this, the \"libseccomp2\" library version must be 2.4 or later."
echo "This script will check this, and upgrade the library as necessary."
echo ""
echo "Once upgraded, you can always stay up to date by typing \"sudo apt update && sudo apt upgrade\" on your command line."
echo ""

# Make sure we are indeed running a Debian Buster (Raspberry Pi OS) system:
OS_VERSION="$(sed -n 's/\(^\s*VERSION_CODENAME=\)\(.*\)/\2/p' /etc/os-release)"
OS_VERSION=${OS_VERSION^^}
if [[ "$OS_VERSION" != "BUSTER" ]] && [[ "${1,,}" != "override" ]]
then
	echo "You aren't running BUSTER. The system reports $OS_VERSION."
	echo "This script has been optimized for Raspberry Pi OS \"BUSTER\". Aborting."
	echo ""
	echo "If you are 100% sure what you are doing and want to go ahead despite this warning,"
	echo "you can skip this check by downloading the script and running it with the OVERRIDE commandline parameter:"
	echo "libseccomp2-checker.sh OVERRIDE"
	exit 1
else
	echo "Your system is \"${OS_VERSION}\" based."
	echo "We will first check if we need to update \"libseccomp2\"."
	read -rp "Press ENTER to continue or Control-C to cancel" </dev/tty
	echo ""
fi

# Now make sure that all packages are at their latest version, just in case the system is running way behind:

LIBVERSION_MAJOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\1/p')"
LIBVERSION_MINOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\2/p')"
if (( LIBVERSION_MAJOR >= 2 )) && (( LIBVERSION_MINOR > 3 ))
then
	# No need to update!
    # shellcheck disable=SC2046,SC2027
	echo "You are running libseccomp2 v"$(apt-cache policy libseccomp2|sed -n 's/\s*Installed:\s*\(.*\)/\1/p')"), which is recent enough. No need to upgrade!"
	exit 0
fi

echo "Your system is \"${OS_VERSION}\" based, and it has libseccomp2 v${LIBVERSION_MAJOR}.${LIBVERSION_MINOR}. Upgrade is recommended."
echo "We will first update your system with the latest package versions. Please be patient, this may take a while."
read -rp "Press ENTER to the upgrade or Control-C to cancel" </dev/tty
echo ""
sudo apt update -q && sudo apt upgrade -y -q
echo ""


# Now check once more which version of libseccomp2 is installed, because the apt upgrade may have already installed a suitable version:
LIBVERSION_MAJOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\1/p')"
LIBVERSION_MINOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\2/p')"
if (( LIBVERSION_MAJOR <= 2 )) && (( LIBVERSION_MINOR < 4 ))
then
	# We need to upgrade
	echo "Now upgrading libseccomp2..."
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC 648ACFD622F3D138
	echo "deb http://deb.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list.d/buster-backports.list
	sudo apt update
	sudo apt install -y -q -t buster-backports libseccomp2
fi
echo "Upgrade complete. Your system now uses libseccomp2 version $(apt-cache policy libseccomp2|sed -n 's/\s*Installed:\s*\(.*\)/\1/p')."
