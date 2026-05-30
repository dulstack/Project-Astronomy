.PHONY: 4_systemd download-systemd systemd-untar systemd-build

4_systemd: download-4_systemd systemd-untar systemd-build

download-systemd:
	cd $(DOWNLOAD_DIR);\
	if [ ! -f v259.tar.gz ]; then \
		wget https://github.com/systemd/systemd/archive/refs/tags/v259.tar.gz; \
	fi

systemd-untar:
	cd $(OUT);\
	if [ ! -d systemd-259 ]; then \
		tar -xvf download/v259.tar.gz; \
	fi

systemd-build:
	cd $(OUT);\
	 meson setup ./systemd-259/build ./systemd-259 -D buildtype=release -D optimization=2;\
	 ninja -C ./systemd-259/build;\
	 DESTDIR=$(PWD)/$(ROOTFS) ninja -C ./systemd-259/build install


