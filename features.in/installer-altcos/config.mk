use/installer-altcos: use/stage2 sub/stage2@installer-altcos use/syslinux/sdab.cfg \
	use/services use/firmware/full +wireless
	@$(call add_feature)
	@$(call add,INSTALLER_ALTCOS_LISTS,sysvinit)
	@$(call add,INSTALLER_ALTCOS_PACKAGES,ostree libostree startup startup-installer-acos mkpasswd udev interactivesystem livecd-net-eth dhcpcd)
	@$(call add,INSTALLER_ALTCOS_LISTS,openssh)

