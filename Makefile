# Quick and dirty Makefile for building Linux kernel
CPUS := $(shell nproc)
OUT ?= out

.PHONY: all

all: $(OUT)/mnt linux systemd symlink coreutils disk

include build/linux.mk
include build/systemd.mk
include build/coreutils.mk

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
		-initrd  $(RAMDISK) \
		-append "rdinit=/sbin/init console=ttyS0 root=/dev/ram0 raid=noautodetect" \
		-m 1G \
		-serial stdio \
		-display none \
		--enable-kvm
$(OUT)/mnt:
	mkdir -p $(OUT)/mnt/usr/lib64 $(OUT)/mnt/usr/lib/x86_64-linux-gnu
	cd $(OUT)/mnt ;\
	 cp /lib64/ld-linux-x86-64.so.2 usr/lib64/;\
	 cp /lib/x86_64-linux-gnu/libc.so.6 usr/lib/x86_64-linux-gnu/;\
	 cp /lib/x86_64-linux-gnu/libm.so.6 usr/lib/x86_64-linux-gnu/
