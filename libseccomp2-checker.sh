#!/bin/bash
set -e
#
# This script updates a STRETCH or BUSTER Debian distribution so it will have the latest version of libseccomp2.
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
echo "Welcome to the libseccomp2 upgrade script for Debian Stretch and Buster. This script is meant to be run on Raspberry Pi Buster/Stretch-based systems that have Docker containers"
echo "that run Debian Bullseye or later. For this, the \"libseccomp2\" library version must be 2.4 or later."
echo "This script will check this, and upgrade the library as necessary."
echo ""
echo "Once upgraded, you can always stay up to date by typing \"sudo apt update && sudo apt upgrade\" on your command line."
echo ""

# Make sure we are indeed running a Debian Buster (Raspberry Pi OS) system:
OS_VERSION="$(sed -n 's/\(^\s*VERSION_CODENAME=\)\(.*\)/\2/p' /etc/os-release)"
[[ "$OS_VERSION" == "" ]] && OS_VERSION="$(sed -n 's/^\s*VERSION=.*(\(.*\)).*/\1/p' /etc/os-release)" || true
OS_VERSION=${OS_VERSION^^}
if [[ "$OS_VERSION" != "BUSTER" ]] && [[ "$OS_VERSION" != "STRETCH" ]] && [[ "${1,,}" != "override" ]]
then
	echo "You aren't running Debian STRETCH or BUSTER. The system reports this OS: $OS_VERSION."
	echo "This script has been optimized for Raspberry Pi OS \"STRETCH\" and \"BUSTER\". Aborting."
	echo ""
	echo "If you are 100% sure what you are doing and want to go ahead despite this warning,"
	echo "you can skip this check by downloading the script and running it with the OVERRIDE commandline parameter:"
	echo "libseccomp2-checker.sh OVERRIDE"
	exit 1
fi

# Now make sure that all packages are at their latest version, just in case the system is running way behind:

LIBVERSION_MAJOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\1/p')"
LIBVERSION_MINOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\2/p')"
if (( LIBVERSION_MAJOR > 2 )) || (( LIBVERSION_MAJOR == 2 && LIBVERSION_MINOR >= 4 ))
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
sudo apt update -q && sudo apt upgrade -y -q && sudo apt install -y -qq w3m
echo ""


# Now check once more which version of libseccomp2 is installed, because the apt upgrade may have already installed a suitable version:
LIBVERSION_MAJOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\1/p')"
LIBVERSION_MINOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\2/p')"
if (( LIBVERSION_MAJOR < 2 )) || (( LIBVERSION_MAJOR == 2 && LIBVERSION_MINOR < 4 )) && [[ "${OS_VERSION}" == "BUSTER" ]]
then
	# We need to upgrade
	echo "Now upgrading libseccomp2..."
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC 648ACFD622F3D138
	echo "deb http://deb.debian.org/debian buster-backports main" | sudo tee -a /etc/apt/sources.list.d/buster-backports.list
	sudo apt update
	sudo apt install -y -q -t buster-backports libseccomp2
elif (( LIBVERSION_MAJOR < 2 )) || (( LIBVERSION_MAJOR == 2 && LIBVERSION_MINOR < 4 )) && [[ "${OS_VERSION}" == "STRETCH" ]]
then
  INSTALL_CANDIDATE=$(curl -qsL http://ftp.debian.org/debian/pool/main/libs/libseccomp/ | w3m -T text/html -dump | sed -n 's/^.*\(libseccomp2_2.5.*armhf.deb\).*/\1/p' | sort | tail -1)
  curl -qsL -o /tmp/"${INSTALL_CANDIDATE}" http://ftp.debian.org/debian/pool/main/libs/libseccomp/${INSTALL_CANDIDATE}
  sudo dpkg -i /tmp/"${INSTALL_CANDIDATE}" && rm -f /tmp/"${INSTALL_CANDIDATE}"
fi

# Now make sure all went well
LIBVERSION_MAJOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\1/p')"
LIBVERSION_MINOR="$(apt-cache policy libseccomp2 | grep -e libseccomp2: -A1 | tail -n1 | sed -n 's/.*:\s*\([0-9]*\).\([0-9]*\).*/\2/p')"
if (( LIBVERSION_MAJOR > 2 )) || (( LIBVERSION_MAJOR == 2 && LIBVERSION_MINOR >= 4 ))
then
	echo "Upgrade complete. Your system now uses libseccomp2 version $(apt-cache policy libseccomp2|sed -n 's/\s*Installed:\s*\(.*\)/\1/p')."
	read -rp "For this fix to be applied, you should restart all of your containers. Do you want us to do this for you? (Y/n) " A </dev/tty
	[[ "$A" == "" ]] && A="y" || A=${A,,}
	[[ ${A:0:1} == "y" ]] && docker restart $(docker ps -q) || true
	echo "Done!"
else
	echo "Something went wrong. Please try running the script again! If that doesn't work, please file an issue at https://github.com/sdr-enthusiasts/Buster-Docker-Fixes/issues"
	echo "and we will try to help you."
fi
