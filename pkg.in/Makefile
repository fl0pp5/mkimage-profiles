# step 3: copy package lists and groups as well as installation profiles
#         referenced in distro configuration (and only those!)
#         over to $(BUILDDIR)

ifeq (,$(BUILDDIR))
$(error BUILDDIR not defined)
endif

# sequential execution, no reason to haste
all:
	@for dir in lists groups profiles; do \
		$(MAKE) -C $$dir || exit; \
	done
