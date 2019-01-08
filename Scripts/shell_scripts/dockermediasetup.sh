#!/bin/bash
# I recommend running this with -x so that you can watch the output of this file.
$USR1=
$USR1PW=
$USR2=
$USR2PW=
$EXTPATH4MEDIA=
$INTPATH4MEDIA=
$EXTPATH4LOGS=
$INTPATH4LOGS=
# DO NOT ADD A TRAILING /!
$PATH2CREDFILES=
$DNSHOSTNAME4MEDIASERVER=
$IPFORMEDIASERVER=
$DNSHOSTNAME4PLEXLOGS=
$IPFORPLEXLOGS=

#CREATE CIFS DIRS

mkdir $INTPATH4MEDIA
mkdir $INTPATH4LOGS

#CREATE PASSWORD FILES

touch $PATH2CREDFILES/.smbcred
echo "username=$USR1" >> $PATH2CREDFILES/.smbcred
echo "password=$USR1PW" >> $PATH2CREDFILES/.smbcred
chmod 600 $PATH2CREDFILES/.smbcred

touch $PATH2CREDFILES/.smbcred2
echo "username=$USR2" >> $PATH2CREDFILES/.smbcred2
echo "password=$USR2PW" >> $PATH2CREDFILES/.smbcred2
chmod 600 $PATH2CREDFILES/.smbcred2

#MOUNT CIFS DIRS

cp -p /etc/fstab /etc/fstab.bak
echo "$EXTPATH4MEDIA $INTPATH4MEDIA cifs credentials=$PATH2CREDFILES/.smbcred,iocharset=utf8,noperm 0 0" >> /etc/fstab
echo "$EXTPATH4LOGS $INTPATH4LOGS cifs credentials=$PATH2CREDFILES/.smbcred2,iocharset=utf8,noperm 0 0" >> /etc/fstab

#EDIT HOSTS FILE

cp -p /etc/hosts /etc/hosts.bak
echo "$IPFORMEDIASERVER    $DNSHOSTNAME4MEDIASERVER" >> /etc/hosts
echo "$IPFORPLEXLOGS    $DNSHOSTNAME4PLEXLOGS" >> /etc/hosts

#MOUNT DIRS
mount -a