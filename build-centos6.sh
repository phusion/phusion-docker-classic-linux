#!/bin/bash
set -ex

RELEASE_RPM=http://mirror.centos.org/centos/6.10/os/i386/Packages/centos-release-6-10.el6.centos.12.3.i686.rpm
CHROOT=/tmp/chroot

mkdir -p $CHROOT
mkdir -p $CHROOT/var/lib/rpm
rpm --rebuilddb --root=$CHROOT

yum install -y wget setarch
wget $RELEASE_RPM
rpm -i --root=$CHROOT --nodeps centos-release-*.rpm


linux32 yum --installroot=$CHROOT install -y rpm yum setarch
sed -i 's|$arch|i686|; s|\$basearch|i686|g' $CHROOT/etc/yum.repos.d/*.repo

mkdir -p $CHROOT/proc
mkdir -p $CHROOT/dev
mkdir -p $CHROOT/etc
mkdir -p $CHROOT/root

mount --bind /proc $CHROOT/proc
mount --bind /dev $CHROOT/dev
if [[ -e $CHROOT/etc/resolv.conf ]]; then
	cp $CHROOT/etc/resolv.conf $CHROOT/etc/resolv.conf.bak
fi
cp /etc/resolv.conf $CHROOT/etc/resolv.conf
chroot $CHROOT linux32 yum update -y
chroot $CHROOT linux32 yum clean all
rm -f $CHROOT/etc/resolv.conf
if [[ -e $CHROOT/etc/resolv.conf.bak ]]; then
	mv $CHROOT/etc/resolv.conf.bak $CHROOT/etc/resolv.conf
fi

# allow networking init scripts inside the container to work without extra steps
echo 'NETWORKING=yes' > "$CHROOT/etc/sysconfig/network"

# effectively: febootstrap-minimize --keep-zoneinfo --keep-rpmdb --keep-services "$target"
#  locales
rm -rf $CHROOT/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive}
#  docs and man pages
rm -rf $CHROOT/usr/share/{man,doc,info,gnome/help}
#  cracklib
rm -rf $ChROOT/usr/share/cracklib
#  i18n
rm -rf $CHROOT/usr/share/i18n
#  yum cache
rm -rf $CHROOT/var/cache/yum
mkdir -p --mode=0755 $CHROOT/var/cache/yum
#  sln
rm -rf $CHROOT/sbin/sln
#  ldconfig
#rm -rf sbin/ldconfig
rm -rf $CHROOT/etc/ld.so.cache $CHROOT/var/cache/ldconfig
mkdir -p --mode=0755 $CHROOT/var/cache/ldconfig
