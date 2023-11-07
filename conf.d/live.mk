# live images
ifeq (distro,$(IMAGE_CLASS))

ifeq (,$(filter-out i586 x86_64,$(ARCH)))
distro/dos: distro/.boot use/dos use/syslinux/ui/menu
	@$(call set,RELNAME,ALT FreeDOS)

distro/syslinux: distro/.boot \
	use/syslinux/localboot.cfg use/syslinux/ui/vesamenu use/hdt
	@$(call set,BOOTLOADER,isolinux)
endif

ifeq (,$(filter-out i586 x86_64 aarch64 ppc64le riscv64,$(ARCH)))
distro/grub: distro/.boot use/grub use/hdt use/memtest +efi \
	use/grub/localboot_bios.cfg use/grub/sdab_bios.cfg; @:
ifeq (,$(filter-out i586 x86_64,$(ARCH)))
	@$(call set,BOOTLOADER,grubpcboot)
endif

distro/grub-ui: distro/grub use/branding use/grub/ui/gfxboot; @:
ifeq (,$(filter-out i586 x86_64 aarch64,$(ARCH)))
	@$(call add,STAGE1_BRANDING,bootloader)
endif

distro/grub-net-install: distro/.base +efi \
	use/firmware use/grub/sdab_bios.cfg use/l10n \
	use/stage2/net-install use/stage2/hid use/stage2/usb \
	use/stage2/ata use/stage2/sbc
ifeq (,$(filter-out i586 x86_64,$(ARCH)))
	@$(call set,BOOTLOADER,grubpcboot)
endif
	@$(call set,KFLAVOURS,un-def std-def)
	@$(call set,GRUB_DEFAULT,network)
	@$(call set,LOCALES,en_US ru_RU pt_BR)
endif

distro/rescue: distro/.base use/rescue use/syslinux/ui/menu use/stage2/cifs \
	use/rescue/.base use/syslinux/sdab.cfg use/grub/sdab_bios.cfg \
	use/stage2/ata use/stage2/hid use/stage2/usb \
	use/efi/shell +efi; @:

distro/rescue-remote: distro/.base use/rescue/base use/stage2/net-eth
	@$(call set,SYSLINUX_CFG,rescue_remote)
	@$(call set,SYSLINUX_DIRECT,1)
	@$(call add,RESCUE_PACKAGES,livecd-net-eth)

distro/.live-base: distro/.base use/live/base \
	use/stage2/ata use/stage2/hid use/stage2/usb; @:

distro/.live-x11: distro/.live-base use/live/x11; @:

distro/.live-desktop: distro/.live-x11 +live use/live/install use/stage2/net-eth \
	use/plymouth/live; @:
distro/.live-desktop-ru: distro/.live-desktop use/live/ru; @:

distro/.live-kiosk: distro/.live-base use/live/autologin \
	use/syslinux/timeout/1 use/cleanup use/stage2/net-eth \
	use/fonts/otf/adobe
	@$(call add,CLEANUP_PACKAGES,'alterator*' 'guile*' 'vim-common')
	@$(call set,SYSLINUX_UI,none)
	@$(call set,SYSLINUX_CFG,live)
	@$(call add,STAGE2_BOOTARGS,quiet)
	@$(call add,DEFAULT_SERVICES_DISABLE,rpcbind klogd syslogd)
	@$(call add,DEFAULT_SERVICES_DISABLE,consolesaver fbsetfont keytable)

distro/live-builder-mini: distro/.live-base use/dev/builder/base \
	use/syslinux/timeout/30 use/isohybrid \
	use/stage2/net-eth use/net-eth/dhcp +sysvinit; @:

distro/live-builder: distro/live-builder-mini \
	use/dev/builder/full use/live/rw +efi; @:

distro/live-install: distro/.live-base use/live/textinstall; @:
distro/.livecd-install: distro/.live-base use/live/install; @:

distro/live-icewm: distro/.live-desktop use/x11/gdm2.20 use/ntp +icewm \
	+sysvinit; @:
distro/live-fvwm: distro/.live-desktop-ru use/x11/gdm2.20 use/ntp use/x11/fvwm \
	+sysvinit; @:

distro/live-rescue: distro/live-icewm +efi
	@$(call add,LIVE_LISTS,$(call tags,rescue && (fs || live || x11)))
	@$(call add,LIVE_LISTS,openssh \
		$(call tags,(base || extra) && (archive || rescue || network)))

# NB: this one doesn't include the browser, needs to be chosen downstream
distro/.live-webkiosk: distro/.live-kiosk \
	use/isohybrid use/live/hooks use/live/ru use/sound \
	use/stage2/kms use/x11/xorg
	@$(call add,LIVE_LISTS,$(call tags,live desktop))

distro/.live-webkiosk-gtk: distro/.live-webkiosk
	@$(call add,CLEANUP_PACKAGES,'libqt4*' 'qt4*')

# kiosk users rather prefer stability to latest bling
distro/live-webkiosk-mini: distro/.live-webkiosk-gtk \
	use/browser/firefox use/browser/firefox/esr use/fonts/otf/mozilla
	@$(call add,LIVE_PACKAGES,livecd-webkiosk-firefox)

# NB: flash/java plugins are predictable security holes
distro/live-webkiosk-flash: distro/live-webkiosk-mini use/plymouth/live +vmguest; @:

distro/live-webkiosk: distro/live-webkiosk-mini use/live/desktop; @:

distro/live-webkiosk-chromium: distro/.live-webkiosk use/fonts/ttf/google +efi
	@$(call add,LIVE_PACKAGES,livecd-webkiosk-chromium)

#distro/live-webkiosk-seamonkey: distro/.live-webkiosk use/fonts/ttf/google
#	@$(call add,LIVE_PACKAGES,livecd-webkiosk-seamonkey)

distro/.live-3d: distro/.live-x11 use/x11/3d \
	use/x11/lightdm/gtk +icewm +sysvinit
	@$(call add,LIVE_PACKAGES,glxgears glxinfo)

distro/live-glxgears: distro/.live-3d; @:

distro/.live-games: distro/.live-kiosk use/x11/3d use/sound \
	use/stage2/net-eth use/net-eth/dhcp use/services +efi +sysvinit
	@$(call set,KFLAVOURS,un-def)
	@$(call add,LIVE_LISTS,$(call tags,xorg misc))
	@$(call add,LIVE_PACKAGES,pciutils input-utils glxgears glxinfo)
	@$(call add,LIVE_PACKAGES,glibc-locales apulse)
	@$(call add,DEFAULT_SERVICES_DISABLE,rpcbind alteratord messagebus)
	@$(call add,SERVICES_DISABLE,livecd-net-eth)

distro/live-flightgear: distro/.live-games
	@$(call add,LIVE_PACKAGES,FlightGear)
	@$(call add,LIVE_PACKAGES,fgo livecd-fgfs)
	@$(call try,HOMEPAGE,http://www.4p8.com/eric.brasseur/flight_simulator_tutorial.html)

distro/live-flightgear-tu154: distro/.live-games
	@$(call add,LIVE_PACKAGES,FlightGear-tu154b)

distro/live-0ad: distro/.live-games
	@$(call add,STAGE2_BOOTARGS,quiet)
	@$(call add,LIVE_PACKAGES,0ad livecd-0ad)
	@$(call try,HOMEPAGE,http://play0ad.com/)

distro/live-gimp: distro/live-icewm use/live/ru
	@$(call add,LIVE_LISTS,$(call tags,desktop sane))
	@$(call add,LIVE_PACKAGES,gimp immix)
	@$(call add,LIVE_PACKAGES,darktable geeqie rawstudio ufraw)
	@$(call add,LIVE_PACKAGES,macrofusion)
	@$(call add,LIVE_PACKAGES,qtfm openssh-clients rsync usbutils)

distro/live-blender: distro/.live-games use/live/runapp
	@$(call add,LIVE_PACKAGES,blender)
	@$(call set,LIVE_RUNAPP_BINARY,blender)
	@$(call try,HOMEPAGE,http://blender.com/)

# NB: use/browser won't do as it provides a *single* browser ATM
distro/live-privacy: distro/.base +efi +systemd +vmguest \
	use/live/base use/live/privacy use/live/ru \
	use/x11/xorg use/x11/lightdm/gtk use/x11/mate use/x11-autologin \
	use/browser/firefox/esr use/browser/firefox use/sound \
	use/fonts/otf/adobe use/fonts/otf/mozilla \
	use/fonts/ttf/google use/fonts/ttf/redhat
	@$(call set,KFLAVOURS,un-def)
	@$(call add,LIVE_LISTS,$(call tags,base l10n))
	@$(call add,LIVE_LISTS,$(call tags,archive extra))
ifeq (,$(filter-out x86_64 aarch64,$(ARCH)))
	@$(call add,LIVE_PACKAGES,chromium)
endif
	@$(call add,LIVE_PACKAGES,gedit mc-full easypaint xchm)
	@$(call add,LIVE_PACKAGES,LibreOffice-langpack-ru java-11-openjdk)
	@$(call add,LIVE_PACKAGES,mate-document-viewer-caja)
	@$(call add,LIVE_PACKAGES,mate-document-viewer-djvu)
	@$(call add,LIVE_PACKAGES,cups system-config-printer livecd-admin-cups)
	@$(call add,LIVE_KMODULES,staging)
	@$(call add,DEFAULT_SERVICES_ENABLE,cups)

distro/live-privacy-dev: distro/live-privacy use/live/rw use/live/repo \
	use/dev/repo use/dev/mkimage use/dev use/control/sudo-su
	@$(call add,LIVE_LISTS,$(call tags,(base || live) && builder))
	@$(call add,MAIN_LISTS,$(call tags,live builder))
	@$(call add,MAIN_PACKAGES,syslinux mkisofs)

endif

distro/live-install-altcos: distro/.base use/live-install-altcos
	@$(call set,BOOTLOADER,grubpcboot)

