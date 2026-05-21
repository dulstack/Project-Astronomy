# Quick and dirty Makefile for building Linux kernel
CPUS := $(shell nproc)
OUT ?= out

.PHONY: all symlink detach-rootfs.img

all: $(OUT) linux systemd symlink disk

include build/linux.mk
include build/systemd.mk

symlink:
	cd $(OUT)/mnt;\
	 ln -sf usr/bin bin;\
	 ln -sf usr/sbin sbin;\
	 ln -sf usr/lib lib;\
	 ln -sf usr/lib64 lib64

DISK = $(OUT)/rootfs.img
DISK_SIZE = 128M

disk: format-$(DISK)

$(DISK):
	qemu-img create -f raw $(DISK) $(DISK_SIZE)

format-$(DISK): $(DISK) | $(OUT)
	fakeroot /sbin/mke2fs -d $(OUT)/mnt -t ext4 $(DISK) $(DISK_SIZE) 


run:
	qemu-system-x86_64 \
		-kernel $(LINUX_BZIMAGE) \
		-drive file=$(OUT)/rootfs.img,format=raw \
		-append "init=/sbin/init root=/dev/sda console=ttyS0" \
		-serial stdio \
		-display none \
		--enable-kvm
$(OUT):
	mkdir -p $(OUT)/mnt
