CPUS               := $(shell nproc)
CFLAGS             ?= -O2
OUT                ?= out
ROOTFS             ?= $(OUT)/mnt
DOWNLOAD_DIR       ?= $(OUT)/download
SUBMAKEFILES        = $(wildcard build/*.mk)
PACKAGES            = $(SUBMAKEFILES:build/%.mk=%) 
DOWNLOAD_TARGETS    = $(PACKAGES:%=download-%)
COMMON_CONFIG_FLAGS = LIBRARY_PATH="$(PWD)/$(ROOTFS)/usr/lib:$(PWD)/$(ROOTFS)/usr/lib64:$(PWD)/$(ROOTFS)/usr/lib/x86_64-linux-gnu/" CC=$(PWD)/$(TOOLS_ROOT)/bin/x86_64-linux-gnu-gcc CXX=$(PWD)/$(TOOLS_ROOT)/bin/x86_64-linux-gnu-g++ CPP=$(PWD)/$(TOOLS_ROOT)/bin/x86_64-linux-gnu-cpp

.PHONY: all download-all disk symlink packages
.NOTPARALLEL: all

all: $(ROOTFS) symlink download-all packages disk

download-all: $(DOWNLOAD_TARGETS) | $(ROOTFS)
packages: $(PACKAGES) | $(DOWNLOAD_TARGETS)

include $(SUBMAKEFILES)

symlink: $(ROOTFS)
	cd $(ROOTFS);\
	 ln -sf usr/bin bin;\
	 ln -sf usr/sbin sbin;\
	 ln -sf usr/lib lib;\
	 ln -sf usr/lib64 lib64

RAMDISK = $(OUT)/initrd.cpio.gz

disk: $(RAMDISK) #| $(PACKAGES)

$(RAMDISK): $(ROOTFS)
	cd $(ROOTFS);\
	 fakeroot find . | fakeroot cpio -o -H newc | gzip > $(PWD)/$(RAMDISK)

run:
	qemu-system-x86_64 \
		-cpu host \
		-kernel $(LINUX_BZIMAGE) \
		-initrd  $(RAMDISK) \
		-append "LD_LIBRARY_PATH="/lib:/lib64:/lib/x86_64-linux-gnu" rdinit=/bin/bash console=ttyS0 raid=noautodetect" \
		-m 1G \
		-serial stdio \
		--enable-kvm
		#-display none \

$(ROOTFS):
	mkdir -p $(ROOTFS)/usr/lib64 $(ROOTFS)/usr/lib/x86_64-linux-gnu\
		$(ROOTFS)/usr/bin $(ROOTFS)/usr/sbin $(ROOTFS)/usr/lib\
	       	$(ROOTFS)/usr/lib64 $(DOWNLOAD_DIR)
	# Missing shared objects that should be added later:
	# libcrypt.so.1
	# libcrypto.so.3 libz.so.1 libzstd.so.1 libselinux.so.1
	# libcap.so.2 libpcre2-8.so.0 libtinfo.so.6

