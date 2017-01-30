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
	wget -O $@ https://github.com/matejak/argbash/archive/$(VERSION).tar.gz

build/md5-$(VERSION): $(SOURCE)
	md5sum $< | cut -f 1 -d ' ' > $@

build/sha256-$(VERSION): $(SOURCE)
	sha256sum $< | cut -f 1 -d ' ' > $@

define substitute =
@test -n "$(PKGREL)" || { echo "Specify pkg release number like 'make ... PKGREL=1'"; exit 1; }
cat $< \
	| sed -e 's/@VERSION@/$(VERSION)/' \
	| sed -e 's/@PKGREL@/$(PKGREL)/' \
	| sed -e 's/@DESC@/Bash argument parsing code generator/' \
	| sed -e 's/@LONGDESC@/Argbash helps your shell scripts to accept arguments. You declare what arguments you want your script to accept and Argbash generates the shell code that parses them from the command-line and exposes passed values as shell variables.\nHelp message is also generated, and helpful error messages are dispatched if the script is called with arguments that conflict with the interface./' \
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

build/argbash.spec: rpm/argbash.spec.in $(SOURCE) build/md5-$(VERSION) build/md5-LICENSE build/sha256-$(VERSION) build/sha256-LICENSE
	$(substitute)

clean:
	$(RM) build/*
