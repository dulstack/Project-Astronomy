# Quick and dirty Makefile for building Linux kernel
CPUS := $(shell nproc)

LINUX_VERSION = 6.18.6
LINUX         = linux-$(LINUX_VERSION)
LINUX_TARBALL = $(LINUX).tar.xz
LINUX_LINK    = https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)
LINUX_BZIMAGE = $(LINUX)/arch/x86/boot/bzImage

.PHONY: all linux systemd symlink detach-rootfs.img

all: disk linux systemd symlink detach-rootfs.img

linux: download-linux untar-linux configure-linux compile-linux

linux-nocompile: download-linux untar-linux configure-linux

download-linux:
	if [ ! -f $(LINUX_TARBALL) ]; then \
		wget $(LINUX_LINK); \
	fi

untar-linux:
	if [ ! -d $(LINUX) ]; then \
		tar -xvf $(LINUX_TARBALL); \
	fi

configure-linux:
	make -j$(CPUS) -C $(LINUX) defconfig

compile-linux:
	make -C $(LINUX) -j$(CPUS) 2>&1 | tee kernel-build.log

systemd: download-systemd systemd-untar systemd-build

download-systemd:
	if [ ! -f v259.tar.gz ]; then \
		wget https://github.com/systemd/systemd/archive/refs/tags/v259.tar.gz; \
	fi

systemd-untar:
	if [ ! -d systemd-259 ]; then \
		tar -xvf v259.tar.gz; \
	fi

systemd-build:
	meson setup ./systemd-259/build ./systemd-259 -D buildtype=release -D optimization=2
	ninja -C ./systemd-259/build
	sudo DESTDIR=/mnt ninja -C ./systemd-259/build install

symlink:
	sudo ln -sf /mnt/usr/bin /mnt/bin
	sudo ln -sf /mnt/usr/sbin /mnt/sbin
	sudo ln -sf /mnt/usr/lib /mnt/lib
	sudo ln -sf /mnt/usr/lib64 /mnt/lib64

DISK      = rootfs.img
DISK_SIZE = 16G

disk: format-$(DISK) mount-$(DISK)

$(DISK):
	qemu-img create -f raw $(DISK) $(DISK_SIZE)

setup-$(DISK): $(DISK)
	LOOPDEV=$$(sudo losetup --find --show -P $(DISK)); \
	echo $$LOOPDEV > .loopdev

format-$(DISK): setup-$(DISK)
	LOOPDEV=$$(cat .loopdev); \
	sudo parted -s $$LOOPDEV mklabel gpt; \
	sudo parted -s $$LOOPDEV mkpart primary ext4 0% 100%; \
	yes | sudo mkfs.ext4 $${LOOPDEV}p1

mount-$(DISK): setup-$(DISK)
	LOOPDEV=$$(cat .loopdev); \
	sudo mount $${LOOPDEV}p1 /mnt

unmount-$(DISK):
	sync
	sudo umount /mnt

detach-rootfs.img: unmount-rootfs.img
	LOOPDEV=$$(cat .loopdev); \
	sudo losetup -d $$LOOPDEV

run:
	qemu-system-x86_64 \
		-kernel $(LINUX_BZIMAGE) \
		-drive file=rootfs.img,format=raw \
		-append "init=/lib/systemd/systemd root=/dev/sda1 console=ttyS0" \
		-nographic
