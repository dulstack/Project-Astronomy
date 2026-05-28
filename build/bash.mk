.PHONY: bash bash-download bash-untar bash-configure bash-build bash-install

BASH_VERSION=5.3
BASH_TARBALL=bash-$(BASH_VERSION).tar.gz
BASH_URL=https://ftp.gnu.org/gnu/bash/$(BASH_TARBALL)
BASH_DIR=bash-$(BASH_VERSION)

bash: download-bash bash-untar bash-configure bash-build bash-install

download-bash: $(OUT)/.downloaded_bash_stamp
bash-untar: $(OUT)/.unpacked_bash_stamp
bash-configure: $(OUT)/.configured_bash_stamp
bash-build: $(OUT)/.built_bash_stamp
bash-install: $(OUT)/.installed_bash_stamp

$(OUT)/.downloaded_bash_stamp: $(OUT)/download/$(BASH_TARBALL)
	touch $@
$(OUT)/.unpacked_bash_stamp: $(OUT)/.downloaded_bash_stamp
	tar -xf $(OUT)/download/$(BASH_TARBALL) -C $(OUT)
	touch $@
$(OUT)/.configured_bash_stamp: $(OUT)/.unpacked_bash_stamp
	mkdir -p $(OUT)/$(BASH_DIR)/out
	cd $(OUT)/$(BASH_DIR)/out;\
		../configure --prefix=$(PWD)/$(OUT)/mnt CFLAGS="-O2"
	touch $@

$(OUT)/.built_bash_stamp: $(OUT)/.configured_bash_stamp
	cd $(OUT)/$(BASH_DIR)/out;\
		make -j$(CPUS)
	touch $@

$(OUT)/.installed_bash_stamp: $(OUT)/.built_bash_stamp
	make -C $(OUT)/$(BASH_DIR)/out install
	touch $@

$(OUT)/download/$(BASH_TARBALL): $(OUT)
	if [ ! -f $@ ] && [ ! -d $(OUT)/$(BASH_DIR) ]; then\
		wget -O $@ $(BASH_URL);\
	fi
