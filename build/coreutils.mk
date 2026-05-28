.PHONY: coreutils coreutils-download coreutils-untar coreutils-configure coreutils-build coreutils-install

COREUTILS_VERSION ?= 9.11
COREUTILS_TARBALL  = download/coreutils-$(COREUTILS_VERSION).tar.xz
COREUTILS_URL      = https://ftp.gnu.org/gnu/coreutils/$(COREUTILS_TARBALL)
COREUTILS          = coreutils-$(COREUTILS_VERSION)

coreutils: download-coreutils coreutils-untar coreutils-configure coreutils-build coreutils-install

download-coreutils: $(OUT)/.downloaded_coreutils_stamp
coreutils-untar: $(OUT)/.unpacked_coreutils_stamp
coreutils-configure: $(OUT)/.configured_coreutils_stamp
coreutils-build: $(OUT)/.built_coreutils_stamp
coreutils-install: $(OUT)/.installed_coreutils_stamp


$(OUT)/.downloaded_coreutils_stamp: $(OUT)/download/$(COREUTILS_TARBALL)
	touch $@
$(OUT)/.unpacked_coreutils_stamp: $(OUT)/.downloaded_coreutils_stamp
	tar -xf $(OUT)/download/$(COREUTILS_TARBALL) -C $(OUT)
	touch $@
$(OUT)/.configured_coreutils_stamp: $(OUT)/.unpacked_coreutils_stamp
	mkdir -p $(OUT)/$(COREUTILS)/out
	cd $(OUT)/$(COREUTILS)/out;\
		../configure --prefix=$(PWD)/$(OUT)/mnt CFLAGS="-O2"
	touch $@

$(OUT)/.built_coreutils_stamp: $(OUT)/.configured_coreutils_stamp
	cd $(OUT)/$(COREUTILS)/out;\
		make -j$(CPUS)
	touch $@

$(OUT)/.installed_coreutils_stamp: $(OUT)/.built_coreutils_stamp
	make -C $(OUT)/$(COREUTILS)/out install
	touch $@

$(OUT)/download/$(COREUTILS_TARBALL): $(OUT)
	if [ ! -f $@ ] && [ ! -d $(OUT)/$(COREUTILS) ]; then\
		wget -O $@ $(COREUTILS_URL);\
	fi
