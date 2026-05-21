.PHONY: linux linux-nocompile download-linux untar-linux configure-linux compile-linux

LINUX_VERSION = 6.18.6
LINUX         = linux-$(LINUX_VERSION)
LINUX_TARBALL = $(LINUX).tar.xz
LINUX_LINK    = https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_TARBALL)
LINUX_BZIMAGE = $(OUT)/$(LINUX)/arch/x86/boot/bzImage

linux: download-linux untar-linux configure-linux compile-linux

linux-nocompile: download-linux untar-linux configure-linux

download-linux:
	cd $(OUT);\
	if [ ! -f $(LINUX_TARBALL) ]; then \
		wget $(LINUX_LINK); \
	fi

untar-linux:
	cd $(OUT);\
	if [ ! -d $(LINUX) ]; then \
		tar -xvf $(LINUX_TARBALL); \
	fi

configure-linux:
	make -j$(CPUS) -C $(OUT)/$(LINUX) defconfig

compile-linux:
	make -C $(OUT)/$(LINUX) -j$(CPUS) 2>&1 | tee $(OUT)/kernel-build.log

