# stage2 mod: installer-altcos "live" image

IMAGE_PACKAGES = $(COMMON_PACKAGES) \
                 $(INSTALLER_ALTCOS_PACKAGES) \
                 $(call list,$(INSTALLER_ALTCOS_LISTS))

MKI_PACK_RESULTS = squash:installer-altcos

debug::
	@echo "** installer-altcos: IMAGE_PACKAGES: $(IMAGE_PACKAGES)"
	@echo "** installer-altcos: IMAGE_PACKAGES_REGEXP: $(IMAGE_PACKAGES_REGEXP)"

