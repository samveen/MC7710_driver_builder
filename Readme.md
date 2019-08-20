# MC7710 linux driver builder

I have an MC7710 running on an x230. Whenever apt upgrades the kernel, I have to
rebuild the bloody driver manually, as there isn't a [DKMS](https://github.com/dell-oss/dkms) module for the Linux
QMI USB Drivers for the Sierra Airprime series.

This is the preliminary framework I wrote up to atleast automate the process of 
building and installing the modules. Future TODO is to do Full DKMS-ization of the build.

# Licensing

- All driver code is copyright of their respective owners under their licensing
- My code is licensed under a modified BSD license as detailed in the LICENSE file

## Requirements

- Recent modern [Bash](https://www.gnu.org/software/bash/)
- All the other requirements as listed on the [driver package page](https://source.sierrawireless.com/resources/airprime/software/usb-drivers-linux-qmi-software-s2,-d-,37n2,-d-,58/) on the Sierra Wireless website.

# Tested build environment

- [Lenovo Thinkpad x230](https://www.lenovo.com/gb/en/laptops/thinkpad/x-series/x230/) running [Xubuntu "18.04.3 LTS (Bionic Beaver)"](https://xubuntu.org/download) with linux kernel version 5.0.0 via `updates` apt repo (package `linux-image-5.0.0-23-generic` version `5.0.0-23.24~18.04.1` for arch `amd64`)

## Notes

- The driver version in this repo is `S2.37N2.58` (latest as of August 20, 2019).
- List of versions of the Linux QMI USB drivers is available
  [here](https://source.sierrawireless.com/resources/airprime/software/usb-drivers-linux-qmi-software-history/).
- I have some Makefile improvements that I have made here (and [submitted to Sierra](https://forum.sierrawireless.com/t/patches-to-sierra-linux-qmi-drivers-version-s2-37n2-57/16899/3)). Once they are included, I probably don't need to include the source anymore.
