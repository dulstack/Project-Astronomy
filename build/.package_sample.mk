.PHONY: package package-download package-untar package-configure package-build package-install

PACKAGE_NAME         = package
PACKAGE_VERSION      = 1.0
PACKAGE_TARBALL      = $(PACKAGE_NAME)-$(PACKAGE_VERSION).tar.gz
PACKAGE_URL          = https://example.com/$(PACKAGE_TARBALL)
PACKAGE_DIR          = package-$(PACKAGE_VERSION)
PACKAGE_CONFIG_FLAGS = --prefix=$(PWD)/$(ROOTFS) CFLAGS="$(CFLAGS)"

package: download-package package-untar package-configure package-build package-install

download-package: $(OUT)/.downloaded_package_stamp
package-untar: $(OUT)/.unpacked_package_stamp
package-configure: $(OUT)/.configured_package_stamp
package-build: $(OUT)/.built_package_stamp
package-install: $(OUT)/.installed_package_stamp

$(OUT)/.downloaded_$(PACKAGE_NAME)_stamp:
	wget -O $(DOWNLOAD_DIR)/$(PACKAGE_TARBALL) $(PACKAGE_URL)
	touch $@

$(OUT)/.unpacked_$(PACKAGE_NAME)_stamp: $(OUT)/.downloaded_$(PACKAGE_NAME)_stamp
	tar -xf $(DOWNLOAD_DIR)/$(PACKAGE_TARBALL) -C $(OUT)
	touch $@

$(OUT)/.configured_$(PACKAGE_NAME)_stamp: $(OUT)/.unpacked_$(PACKAGE_NAME)_stamp
	mkdir -p $(OUT)/$(PACKAGE_DIR)/out
	cd $(OUT)/$(PACKAGE_DIR)/out;\
		../configure $(PACKAGE_CONFIG_FLAGS) 
	touch $@

$(OUT)/.built_$(PACKAGE_NAME)_stamp: $(OUT)/.configured_$(PACKAGE_NAME)_stamp
	cd $(OUT)/$(PACKAGE_DIR)/out;\
		make
	touch $@

$(OUT)/.installed_$(PACKAGE_NAME)_stamp: $(OUT)/.built_$(PACKAGE_NAME)_stamp
	make -C $(OUT)/$(PACKAGE_DIR)/out install
	touch $@
