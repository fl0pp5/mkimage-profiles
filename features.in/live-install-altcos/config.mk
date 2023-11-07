use/live-install-altcos: use/stage2 sub/rootfs@live-install-altcos \
	sub/stage2@live-install-altcos +efi +systemd \
	use/l10n use/grub/live-install-altcos.cfg use/deflogin/live
	@$(call add_feature)
	@$(call add,LIVE_INSTALL_ALTCOS_PACKAGES,libostree startup startup-installer-altcos)
	@$(call add,LIVE_INSTALL_ALTCOS_PACKAGES,mkpasswd udev interactivesystem grub-efi)
	@$(call add,LIVE_INSTALL_ALTCOS_PACKAGES,altcos-archives curl)
