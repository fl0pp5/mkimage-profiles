# stage2 mod: live-install-altcos "live" image

IMAGE_PACKAGES = $(COMMON_PACKAGES) \
		 $(LIVE_INSTALL_ALTCOS_PACKAGES) \
		 $(call list,$(LIVE_INSTALL_ALTCOS_LISTS))

MKI_PACK_RESULTS = squash:live-install-altcos

debug::
	@echo "** live-install-altcos: IMAGE_PACKAGES: $(IMAGE_PACKAGES)"
	@echo "** live-install-altcos: IMAGE_PACKAGES_REGEXP: $(IMAGE_PACKAGES_REGEXP)"