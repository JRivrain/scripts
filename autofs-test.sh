#!/bin/bash


if  [ -d /srv/nfs ]; then
read -p "/srv/nfs found. Wanna do a angerous roll back ? Will wipe all config files and directories !! Y/N" -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]] ;  then
        exit 1
    else
        rm -rf /srv/{smb,nfs}
        >/etc/exports
        >/etc/samba/smb.conf
        >/etc/auto.master
        >/etc/auto.nfs
        >/etc/auto.misc
        rm /root/fakedd
    fi
fi

mkdir /srv/{smb,nfs}; chmod 777 /srv/smb

LOG=$1
[ -z $LOG ] && LOG=/dev/null

nfs_test() {
set -ex
    systemctl list-unit-files |grep nfsserver || zypper in -y nfs-kernel-server
    echo "/srv/nfs *(fsid=0,rw,no_root_squash,sync,no_subtree_check)" >>/etc/exports
    echo "/nfs /etc/auto.nfs --timeout=10" >>/etc/auto.master
    echo "localnfs -fstype=nfs localhost:/srv/nfs" >> /etc/auto.nfs
    systemctl restart autofs nfsserver
    touch /nfs/localnfs/testfile
    ls /srv/nfs/testfile
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
}

local_fs() {
set -ex
    dd if=/dev/zero of=/root/fakedd bs=1M count=50
    mke2fs -t ext2 /root/fakedd
    echo "/- /etc/auto.misc --timeout=10" >> /etc/auto.master
    echo "/mnt -fstype=ext2 :/root/fakedd" >> /etc/auto.misc
    systemctl restart autofs
    ls /mnt/lost+found
}

nfs_test &>$LOG && echo "NFS test passed" || echo "NFS test failed"
samba_test &>>$LOG && echo "Samba test passed" || echo "Samba test failed"
local_fs &>>$LOG && echo "Local FS test passed" || echo "Local FS test failed"

exit 0
