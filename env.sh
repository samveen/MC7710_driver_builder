#!/bin/bash
# Easy creator script for the environment line of the Readme

cat <<__ENDL | fmt -w2000
[Lenovo Thinkpad x230](https://www.lenovo.com/gb/en/laptops/thinkpad/x-series/x230/) running 
[Xubuntu "$(awk -F'"' '/VERSION=/{print $2}' /etc/os-release)"](https://xubuntu.org/download)
with $(dpkg -l dkms | awk '/dkms/{print "`"$2"`","version","`"$3"`"}')
and linux kernel version $(uname -r |sed 's/-.*//') via \`updates\` apt repo
(package $(dpkg -l|awk "/linux-image-$(uname -r)/"'{print "`"$2"`","version","`"$3"`","for arch","`"$4"`"}'))
to build Sierra Linux QMI Drivers version
$(sudo dkms status |awk '/SierraLinuxQMIdrivers/{print "`"$2"`"}' |sed 's/,//').
__ENDL
