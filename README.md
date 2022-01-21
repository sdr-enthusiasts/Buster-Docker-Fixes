# Buster Docker Fixes
 
## Note for ARM32 Users

32-bit Raspberry Pi users running Debian "Buster"-based operating systems may have issues running certain docker containers. A docker container's maintainer may choose to update the base image to use Debian "Bullseye". The choice to do this update is generally made to ensure the container continues to receive bug fixes and timely security updates for installed packages.

However, this choice impacts users of "Buster"-based distros and causes containers based on "Bullseye" to stop working. You will see errors in the logs indicating issues with the `RTC` or `Real Time Clock`.

The issue with "Buster"-based systems involves a very outdated system package called `libseccomp2`. Using "Bullseye"-based base images requires a more up-to-date `libseccomp2` that is not typically available without extra steps 

You have four options to ensure this container will work on your Pi.

* Update `libseccomp2` in your operating system.
* Update to a fresh install of Raspberry Pi OS 1.4 (Debian "Bullseye"-based), or an install of Raspberry Pi OS from an image made after November 2021.
* Use Ubuntu ARM 64 bit
* Run this container with the `priviledged` flag. **SECURITY ISSUE: NOT RECOMMENDED**

[KX1T](https://github.com/kx1t) has created a [script](https://github.com/fredclausen/docker-acarshub/blob/main/libseccomp2-checker.sh) that you can run that will check your system and ensure it is ready. This script will only work on "Buster"-based Debian distros and will only change anything if your `libseccomp2` is outdated.

The `libseccomp2` script will do the following things to your system if the version of libseccomp2 is outdated:

* Add an official Debian repository to your apt sources along with the associated GPG key
* Update your system packages prior to updating `libseccomp2`
* Finally, install `libseccomp2`

You may be prompted for a password because the script is modifying things that require escalated privileges.

To run this script, which only needs to be done once, please do the following:

```shell
curl -sL https://raw.githubusercontent.com/fredclausen/Buster-Docker-Fixes/main/libseccomp2-checker.sh | bash
```

Apologies for any inconvenience this causes, however "Buster"-based distributions are now getting pretty old, and updating the container's base image to something less old provides benefits that outweigh the cost of running a simple script to fix your host. :-)
