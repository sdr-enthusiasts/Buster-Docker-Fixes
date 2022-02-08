# Buster (and Stretch) Docker Fixes
[](https://discord.com/channels/@me/804331474513690625/940387433797799980 =200x)
## The situation

Users running Debian "Stretch" or "Buster"-based operating systems (e.g., Raspbian/Raspberry Pi OS 1.3) on ARM hardware (e.g., Raspberry Pi) may have issues running certain Docker containers.

Newer Docker containers can be based on Debian "Bullseye", the latest stable branch of Debian Linux. Newer versions of Linux are generally better maintained and receive timely bug fixes and security updates for installed packages.

## The problem

Users of older "Stretch" or "Buster" based ARM systems may experience problems running "Bullseye" based Docker Containers. For example, you may see errors in the logs indicating issues such as:

* With the `RTC`
* `Real Time Clock`
* Any odd error message that may have the word `Time` in it
* Or be otherwise related to the clock.

This is an example of such error message:

```
sleep: cannot read realtime clock: Operation not permitted
```

The issue with "Buster" systems is related to a system package called `libseccomp2`. "Bullseye" Docker containers require a more up-to-date `libseccomp2` than is typically available on these older systems.

## How to fix this

### ~~Four~~ Three options to fix
You have ~~four~~ three options to ensure this container will work on your Pi.

1. Update `libseccomp2` in your operating system
2. Update to a fresh install of Raspberry Pi OS 1.4 (Debian "Bullseye"-based), or an install of Raspberry Pi OS from an image made after November 2021
3. Upgrade to Ubuntu ARM 64 bit
4. ~~Run this container with the `privileged` flag.~~ **SECURITY ISSUE: NOT RECOMMENDED, PLEASE DO NOT DO THIS**

### Our recommendation
The easiest solution is option 1: update `libseccomp2` in your operating system. [KX1T](https://github.com/kx1t) has created a [script](libseccomp2-checker.sh) that you can run. It will check that your system is "Buster" based and install an updated version of `libseccomp2` only if required and available.

If you are unsure if your system may be affected you can also run this script. The script is designed to only run on systems it knows will have the problem and we can safely apply a fix.

To run this script, which only needs to be done once, please do the following:

```shell
curl -sL https://raw.githubusercontent.com/sdr-enthusiasts/Buster-Docker-Fixes/main/libseccomp2-checker.sh | bash
```

After updating `libseccomp2`, you may have to restart your containers to ensure they run properly.

### What does the script do?

The script will only work on "Stretch" or "Buster"-based Debian distributions and will only update `libseccomp2` if it is outdated.
The `libseccomp2` script will do the following things to your system:

* Determine if your system is buster based, and if not, stop
* Update your system packages and install `w3m` (needed to parse some HTML data for Stretch OS fixes)
* If the script determines `libseccomp2` is outdated, it will then do the following after you give it permission to continue:
  - Add an official Debian repository to your apt sources along with the associated GPG key
  - Install a new version of `libseccomp2`

You may be prompted for a password because the script is modifying things that require escalated (`sudo`) privileges.
Feel free to inspect the script [here](libseccomp2-checker.sh).

## LICENSE
This repository, including any scripts, data, SDKs, and documentation is subject to the MIT License, [included](LICENSE) with this package. Copyright (c) 2021, 2022 by Ramon F. Kolb (kx1t), Fred Clausen, Mike Nye, and others.
