.PHONY: all

all: ubuntu-lucid centos-5 centos-6

ubuntu-lucid:
	sudo ./mkimage.sh -t phusion/ubuntu-lucid-32 debootstrap --include=ubuntu-minimal --components=main,universe --arch=i386 lucid

centos-5:
	sudo rm -rf centos-5-chroot
	sudo docker run -t -i --rm --privileged \
		-v `pwd`/centos-5-chroot:/tmp/chroot \
		-v `pwd`/build-centos5.sh:/build.sh \
		centos:5 bash /build.sh
	sudo tar -C centos-5-chroot -c . | docker import - phusion/centos-5-32

centos-6:
	sudo rm -rf centos-6-chroot
	sudo docker run -t -i --rm --privileged \
		-v `pwd`/centos-6-chroot:/tmp/chroot \
		-v `pwd`/build-centos6.sh:/build.sh \
		centos:6 bash /build.sh
	sudo tar -C centos-6-chroot -c . | docker import - phusion/centos-6-32
