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

RAMDISK = $(OUT)/initrd.cpio.gz

disk: $(RAMDISK)

$(RAMDISK): $(OUT)/mnt
	cd $(OUT)/mnt;\
	 fakeroot find . | fakeroot cpio -o -H newc | gzip > $(PWD)/$(RAMDISK)

run:
	qemu-system-x86_64 \
		-cpu host \
		-kernel $(LINUX_BZIMAGE) \
		-initrd  $(RAMDISK)\
		-append "rdinit=/sbin/init console=ttyS0" \
		-serial stdio \
		-display none \
		--enable-kvm
$(OUT):
	mkdir -p $(OUT)/mnt
