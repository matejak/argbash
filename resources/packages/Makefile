VERSION = $(shell cat ../../src/version)

SOURCE = build/argbash-$(VERSION).tar.gz

build/LICENSE: ../../LICENSE | build
	cp $< $@

build/md5-LICENSE: build/LICENSE | build
	md5sum $< | cut -f 1 -d ' ' > $@

source: $(SOURCE)

$(SOURCE): | build
	wget -O $@ https://github.com/matejak/argbash/archive/$(VERSION).tar.gz

build/md5-$(VERSION): $(SOURCE)
	md5sum $< | cut -f 1 -d ' ' > $@

define substitute =
@test -n "$(PKGREL)" || { echo "Specify pkg release number like 'make ... PKGREL=1'"; exit 1; }
cat $< \
	| sed -e 's/@VERSION@/$(VERSION)/' \
	| sed -e 's/@PKGREL@/$(PKGREL)/' \
	| sed -e 's/@DESC@/Bash argument parsing code generator/' \
	| sed -e 's|@URL@|https://github.com/matejak/argbash|' \
	| sed -e 's/@MD5SUM@/$(shell cat $(word 3,$+))/' \
	| sed -e 's/@LIC_MD5UM@/$(shell cat $(word 4,$+))/' \
	> $@
endef

build:
	mkdir $@

build/PKGBUILD: arch/PKGBUILD $(SOURCE) build/md5-$(VERSION) build/md5-LICENSE
	$(substitute)

archlinux: build/PKGBUILD
	cd build && makepkg -f

build/SPEC: rpm/SPEC $(SOURCE)
	$(substitute)

clean:
	$(RM) build/*
