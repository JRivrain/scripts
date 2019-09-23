#!/bin/bash

mkdir /srv/{smb,nfs}; chmod 777 /srv/smb

nfs_test() {
set -e
    systemctl list-unit-files |grep nfsserver &>/dev/null || zypper in -y nfs-kernel-server &>/dev/null
    echo "/nfs /etc/auto.nfs --timeout=10" >>/etc/auto.master
    echo "localnfs -fstype=nfs localhost:/srv/nfs" >> /etc/auto.nfs
    systemctl restart autofs nfsserver
    touch /nfs/localnfs/testfile
    ls /srv/nfs/testfile &>/dev/null
}

samba_test() {
set -e
systemctl list-unit-files |grep smb &>/dev/null || zypper in -y samba &>/dev/null
echo "
[stuff]
    browseable = yes
    path = /srv/smb
    guest ok = yes
    read only = No
    create mask = 777" >> /etc/samba/smb.conf
echo "/cifs /etc/auto.smb --timeout=10" >> /etc/auto.master
systemctl restart autofs smb
touch /cifs/localhost/stuff/testfile
ls /srv/smb/tes &>/dev/null
}

local_fs() {
set -e
    dd if=/dev/zero of=/root/fakedd bs=1M count=50 &>/dev/null
    mke2fs -t ext2 /root/fakedd &>/dev/null
    echo "/- /etc/auto.misc --timeout=10" >> /etc/auto.master
    echo "/mnt -fstype=ext2 :/root/fakedd" >> /etc/auto.misc
    systemctl restart autofs
    ls /mnt/lost+found &>/dev/null
}



nfs_test && echo "NFS test passed" || echo "NFS test failed"
samba_test && echo "Samba test passed" || echo "Samba test failed"
local_fs && echo "Local FS test passed" || echo "Local FS test failed"

exit 0
