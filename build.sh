#!/bin/bash

# Cleanup old
#rm -fR GobiNet GobiSerial

# untar everything again
#tar xzf SierraLinuxQMIdriversS2.37N2.57.tar.gz

# file list
FILELIST=$(find /usr/src/linux-headers-$(uname -r|sed 's/-generic//') -name memcontrol.h)

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
    sudo rsync -auv ${f} ${f}.bak
    sudo perl -i -pe 'BEGIN{undef $/;} s/(static inline bool task_in_memcg_oom\(struct task_struct \*p\)\n\{\n\s+return p->memcg_in_oom)(;\n\})/\1==NULL ? 0 : 1\2/' ${f}
done

# Fix #define in file:
sed -i 's/^\(#define MEMCG_NOT_FIX\)$/\/* \1 *\//' GobiNet/GobiUSBNet.c 

# build
make -C GobiNet
make -C GobiSerial

# undo
for f in $FILELIST; do
    sudo mv ${f}.bak ${f}
done

# install
sudo install Gobi*/*.ko -t /lib/modules/$(uname -r)/updates/dkms/

sudo depmod
