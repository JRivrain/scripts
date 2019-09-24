#!/bin/bash

LOG=$1
[ -z $LOG ] && LOG=/dev/null

cleanup() {
        set -x
        rm -rf /srv/{smb,nfs}
        sed -i -e '/srv\/nfs/d' /etc/exports
        sed -i -e '/stuff/,+5d' /etc/samba/smb.conf
        sed -i -e '/auto.nfs/,+3d' /etc/auto.master
        sed -i -e '/localnfs/d' /etc/auto.nfs
        sed -i -e '/fakedd/d'  /etc/auto.misc
        rm /root/fakedd
        systemctl restart autofs smb nfsserver
        set +x
}

grep localnfs /etc/auto.nfs && cleanup
mkdir /srv/{smb,nfs}; chmod 777 /srv/smb

nfs_test() {
set -ex
    systemctl list-unit-files |grep nfsserver || zypper in -y nfs-kernel-server
    echo "/srv/nfs *(fsid=0,rw,no_root_squash,sync,no_subtree_check)" >>/etc/exports
    echo "/nfs /etc/auto.nfs --timeout=10" >>/etc/auto.master
    echo "localnfs -fstype=nfs localhost:/srv/nfs" >> /etc/auto.nfs
    systemctl restart autofs nfsserver
    touch /nfs/localnfs/testfile
    ls /srv/nfs/testfile
    set +x
}

samba_test() {
    set -ex
    systemctl list-unit-files |grep smb || zypper in -y samba
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
    ls /srv/smb/testfile
    set +x
}

local_fs() {
    set -ex
    dd if=/dev/zero of=/root/fakedd bs=1M count=50
    mke2fs -t ext2 /root/fakedd
    echo "/- /etc/auto.misc --timeout=10" >> /etc/auto.master
    echo "/mnt -fstype=ext2 :/root/fakedd" >> /etc/auto.misc
    systemctl restart autofs
    ls /mnt/lost+found
    set +x
}

nfs_test &>$LOG && echo "NFS test passed" || echo "NFS test failed"
samba_test &>>$LOG && echo "Samba test passed" || echo "Samba test failed"
local_fs &>>$LOG && echo "Local FS test passed" || echo "Local FS test failed"
sleep 10
cleanup &>>$LOG


exit 0
