#!/bin/bash

echo -n "build env:"; uname -a
echo "===params===="; echo "'" "$@" "'" ; echo "======="
echo "======="; env ; echo "======="

# Get and parse options
OPTIONS=$(getopt -o k: --long kver: -n "$0" -- "$@")

# Note the quotes around `$OPTIONS': they are essential!
eval set -- "$OPTIONS"

while true ; do
	case "$1" in
		-k|--kver) kernelver=$2 ; shift 2 ;;
		--) shift ; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

if [[ -z ${kernelver} ]]; then
    kernelver=$(uname -r)
    echo "No kernel version. Using current ver by default($kernelver)"
else
    echo "Building for kernel version '$kernelver'"
fi
# Cleanup old
#rm -fR GobiNet GobiSerial

# untar everything again
#tar xzf SierraLinuxQMIdriversS2.37N2.58.tar.gz

# file list
FILELIST=$(find /usr/src/linux-headers-"${kernelver}" -follow -name memcontrol.h)

# For function 'task_in_memcg_oom' in memcontrol.h replace
#    'return p->memcg_in_oom;'
# with
#    'return p->memcg_in_oom==NULL ? 0 : 1;'

# static inline bool task_in_memcg_oom(struct task_struct *p)
# {
#         return p->memcg_in_oom;
# }

# replace in files
for f in $FILELIST; do
    sudo rsync -auv "${f}" "${f}.bak"
    sudo perl -i -pe 'BEGIN{undef $/;} s/(static inline bool task_in_memcg_oom\(struct task_struct \*p\)\n\{\n\s+return p->memcg_in_oom)(;\n\})/\1==NULL ? 0 : 1\2/' "${f}"
done

# Fix #define in file:
sed -i.bak 's/^\(#define MEMCG_NOT_FIX\)$/\/* \1 *\//' GobiNet/GobiUSBNet.c
chmod --reference GobiNet/GobiUSBNet.c.bak GobiNet/GobiUSBNet.c

export kernelver
# build
make -C GobiNet
make -C GobiSerial

# install
#sudo install Gobi*/*.ko -t /lib/modules/${kernelver}/updates/dkms/

# Rebuild module dependencies
#sudo depmod

# undo all changes
for f in $FILELIST; do
    sudo mv "${f}.bak" "${f}"
done
mv GobiNet/GobiUSBNet.c.bak GobiNet/GobiUSBNet.c
#make -C GobiNet clean
#make -C GobiSerial clean
