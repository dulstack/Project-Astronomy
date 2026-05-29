CPUS            := $(shell nproc)
CFLAGS          ?= -O2
OUT             ?= out
ROOTFS          ?= $(OUT)/mnt
DOWNLOAD_DIR    ?= $(OUT)/download
SUBMAKEFILES     = $(wildcard build/*.mk)
PACKAGES         = $(SUBMAKEFILES:build/%.mk=%) 
DOWNLOAD_TARGETS = $(PACKAGES:%=download-%)

.PHONY: all download-all disk symlink

all: $(ROOTFS) symlink download-all $(PACKAGES) disk

download-all: $(DOWNLOAD_TARGETS)

include $(SUBMAKEFILES)

symlink:
	cd $(ROOTFS);\
	 ln -sf usr/bin bin;\
	 ln -sf usr/sbin sbin;\
	 ln -sf usr/lib lib;\
	 ln -sf usr/lib64 lib64

RAMDISK = $(OUT)/initrd.cpio.gz

disk: $(RAMDISK)

$(RAMDISK): $(ROOTFS)
	cd $(ROOTFS);\
	 fakeroot find . | fakeroot cpio -o -H newc | gzip > $(PWD)/$(RAMDISK)

run:
	qemu-system-x86_64 \
		-cpu host \
		-kernel $(LINUX_BZIMAGE) \
		-initrd  $(RAMDISK) \
		-append "rdinit=/bin/bash console=ttyS0 raid=noautodetect" \
		-m 1G \
		-serial stdio \
		-display none \
		--enable-kvm

$(ROOTFS):
	mkdir -p $(ROOTFS)/usr/lib64 $(ROOTFS)/usr/lib/x86_64-linux-gnu\
		$(ROOTFS)/usr/bin $(ROOTFS)/usr/sbin $(ROOTFS)/usr/lib\
	       	$(ROOTFS)/usr/lib64 $(DOWNLOAD_DIR)
	# Missing shared objects that should be added later:
	# glibcrypt.so.1
	# glibcrypto.so.3 glibz.so.1 glibzstd.so.1 glibselinux.so.1
	# glibcap.so.2 glibpcre2-8.so.0 glibtinfo.so.6

