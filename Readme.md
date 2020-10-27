# MC7710 linux driver builder

I have an MC7710 running on an x230. Whenever apt upgrades the kernel, I have to
rebuild the bloody driver manually, as there isn't a [DKMS](https://github.com/dell-oss/dkms) module for the Linux
QMI USB Drivers for the Sierra AirPrime series.

This is the preliminary framework I wrote up to atleast automate the process of
building and installing the modules. Future TODO is to do Full DKMS-ization of the build.

# Before Anything Else

The Sierra sources require the kernel include file `linux/memcontrol.h` to be edited in
different ways depending on the kernel version the module is being built against. This
framework edits the code expecting that the kernel version being used is `5.0.0` or greater.

Starting from version `S2.42N2.62`, the Seirra source package now contains a `dkms/` folder
(which is included here) somewhat inspired by this repo, but very limited in what it can do
(only builds against running kernel version, still requires manual kernel includes editing).
If you decide to use that instead, please read everything in the DKMS conf and Makefiles, and
examine dkms build logs carefully for any issues and errors.

# Licensing

- All driver code is copyright of their respective owners under their licensing
- My code is licensed under a modified BSD license as detailed in the LICENSE file

# Requirements

- Recent modern [Bash](https://www.gnu.org/software/bash/)
- Recent version of [DKMS](https://github.com/dell/dkms)
- All the other requirements as listed on the [driver package page](https://source.sierrawireless.com/resources/airprime/software/usb-drivers-linux-qmi-software-s2,-d-,37n2,-d-,58/) on the Sierra Wireless website.

# Last Tested Build Environment

- [Lenovo Thinkpad x230](https://www.lenovo.com/gb/en/laptops/thinkpad/x-series/x230/) running [Xubuntu "18.04.4 LTS (Bionic Beaver)"](https://xubuntu.org/download) with `dkms` version `2.3-3ubuntu9.7` and running linux kernel version 5.3.0 (version `5.3.0-59-generic`) to build Sierra Linux QMI Drivers version `S2.42N2.62` for package `linux-image-5.3.0-61-generic` (version `5.3.0-61.55~18.04.1`) on arch `amd64` via `updates` apt repo (`apt upgrade`).

# Build Instructions


- *(First time install only)* Clone this repo into `/usr/src/SierraLinuxQMIdrivers`:
  ```
  sudo git clone https://github.com/samveen/MC7710_driver_builder /usr/src/SierraLinuxQMIdrivers
  ```

- Create a link to the source dir with a version number(easier versioned driver updates):
  ```
  sudo ln -s /usr/src/SierraLinuxQMIdrivers SierraLinuxQMIdrivers-S2.42N2.63
  ```

- Register the module with DKMS:
  ```
  sudo dkms add --verbose -m SierraLinuxQMIdrivers -v S2.42N2.63
  ```

- Build and install the module:
  ```
  sudo dkms build --verbose -m SierraLinuxQMIdrivers -v S2.42N2.63
  sudo dkms install --verbose -m SierraLinuxQMIdrivers -v S2.42N2.63
  ```

- Check status:
  ```
  sudo dkms status --verbose -m SierraLinuxQMIdrivers -v S2.42N2.63
  ```

- Get rid of the DKMS setup in case it's a pain:
  ```
  sudo dkms uninstall --verbose -m SierraLinuxQMIdrivers -v S2.42N2.63
  sudo dkms remove --verbose -m SierraLinuxQMIdrivers -v S2.42N2.63 --all
  sudo rm -fR /usr/src/SierraLinuxQMIdrivers\*
  ```

- Update older versions of modules(remixes install and cleanup instructions above):
  ```
  # Remove old versions of drivers from all kernels
  sudo dkms remove SierraLinuxQMIdrivers/S2.42N2.62 --all
  # Update source
  cd /usr/src/SierraLinuxQMIdrivers && sudo git pull & cd ..
  # Move old driver version link to correct version number
  sudo mv SierraLinuxQMIdrivers-S2.42N2.62 SierraLinuxQMIdrivers-S2.42N2.63
  # Alternative syntax for dkms commands
  sudo dkms add --verbose SierraLinuxQMIdrivers/S2.42N2.63
  sudo dkms build SierraLinuxQMIdrivers/S2.42N2.63
  sudo dkms install SierraLinuxQMIdrivers/S2.42N2.63
  sudo dkms status --verbose SierraLinuxQMIdrivers/S2.42N2.63
  ```

## TODO
- Add kernel module signing for secure boot (Needs some research in Machine owner keys, via mokutil maybe).

## Notes

- The driver version in this repo is `S2.42N2.62` (latest as of June 25, 2020).
- List of versions of the Linux QMI USB drivers is available
  [here](https://source.sierrawireless.com/resources/airprime/software/usb-drivers-linux-qmi-software-history/).
- My Makefile improvements [submitted to Sierra](https://forum.sierrawireless.com/t/patches-to-sierra-linux-qmi-drivers-version-s2-37n2-57/16899/3)) are now included.
- I've had to [submit a second patch to Sierra](https://forum.sierrawireless.com/t/patches-to-sierra-linux-qmi-drivers-version-s2-39n2-60/19221) for a similar problem as previously.
- **IMPORTANT** The Sierra build installs the modules into `/lib/modules/${kversion}/kernel/drivers/net/usb`, but `dkms` ignores  the corresponding `DEST_MODULE_LOCATION` in the `dkms.conf` for Ubuntu, as per design, putting the modules into `/lib/modules/${kversion}/updates/dkms` instead . More details at the [Ubuntu dkms manpage](http://manpages.ubuntu.com/manpages/bionic/man8/dkms.8.html#dkms.conf)
