VERSION ?= $(shell cat ../../src/version)

SOURCE = build/argbash-$(VERSION).tar.gz

build/LICENSE: ../../LICENSE | build
	cp $< $@

build/md5-LICENSE: build/LICENSE | build
	md5sum $< | cut -f 1 -d ' ' > $@

build/sha256-LICENSE: build/LICENSE | build
	sha256sum $< | cut -f 1 -d ' ' > $@

source: $(SOURCE)

$(SOURCE): | build
	@# If wget wasn't successful, delete the empty "downloaded" file
	wget -O $@ https://github.com/matejak/argbash/archive/$(VERSION).tar.gz || $(RM) $@

build/md5-$(VERSION): $(SOURCE)
	md5sum $< | cut -f 1 -d ' ' > $@

build/sha256-$(VERSION): $(SOURCE)
	sha256sum $< | cut -f 1 -d ' ' > $@

LONGDESC = Argbash helps your shell scripts to accept arguments.\nYou declare what arguments you want your script to accept and Argbash\ngenerates the shell code that parses them from the command-line and exposes\npassed values as shell variables.\n\nHelp message is also generated, and helpful error messages are dispatched\nif the script is called with arguments that conflict with the interface.

define substitute =
@test -n "$(PKGREL)" || { echo "Specify pkg release number like 'make ... PKGREL=1'"; exit 1; }
cat $< \
	| sed -e 's/@VERSION@/$(VERSION)/' \
	| sed -e 's/@PKGREL@/$(PKGREL)/' \
	| sed -e 's/@DESC@/Bash argument parsing code generator/' \
	| sed -e 's/@LONGDESC@/$(LONGDESC)/' \
	| sed -e 's|@URL@|https://argbash.io|' \
	| sed -e 's/@MD5SUM@/$(shell cat $(word 3,$+))/' \
	| sed -e 's/@LIC_MD5SUM@/$(shell cat $(word 4,$+))/' \
	| sed -e 's/@SHA256SUM@/$(shell cat $(word 5,$+))/' \
	| sed -e 's/@LIC_SHA256SUM@/$(shell cat $(word 6,$+))/' \
	> $@
endef

build:
	mkdir $@

build/PKGBUILD: arch/PKGBUILD.in $(SOURCE) build/md5-$(VERSION) build/md5-LICENSE build/sha256-$(VERSION) build/sha256-LICENSE
	$(substitute)

archlinux: build/PKGBUILD
	cd build && makepkg -f && makepkg --printsrcinfo > .SRCINFO

fedora: build/argbash.spec
	@test -n "$(FEDORA_RELEASE)" || { echo "Specify fedora release number like 'make ... FEDORA_RELEASE=f25'"; exit 1; }
	cd build && fedpkg --release $(FEDORA_RELEASE) mockbuild && fedpkg --release $(FEDORA_RELEASE) srpm

build/argbash.spec: rpm/argbash.spec.in $(SOURCE) build/md5-$(VERSION) build/md5-LICENSE build/sha256-$(VERSION) build/sha256-LICENSE
	$(substitute)

clean:
	$(RM) -r build/*
