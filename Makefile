.PHONY: all ubuntu-lucid centos-5

all: ubuntu-lucid centos-5

ubuntu-lucid:
	sudo ./mkimage.sh -t phusion/ubuntu-lucid-32 debootstrap --include=ubuntu-minimal --components=main,universe --arch=i386 lucid

centos-5:
	./mkimage.sh -t phusion/centos-5-32 rinse --distribution centos-5
