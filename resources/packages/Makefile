VERSION = $(shell cat ../../src/version)

SOURCE = argbash-$(VERSION).tar.gz

LICENSE: ../../LICENSE
	cp $< $@

md5-LICENSE: LICENSE
	md5sum $< | cut -f 1 -d ' ' > $@

source: $(SOURCE)

$(SOURCE):
	wget -O $@ https://github.com/matejak/argbash/archive/$(VERSION).tar.gz

md5-$(VERSION): $(SOURCE)
	md5sum $< | cut -f 1 -d ' ' > $@

define substitute =
@test -n "$(PKGREL)" || { echo "Specify pkg release number like 'make ... PKGREL=1'"; exit 1; }
cat $< \
	| sed -e 's/@VERSION@/$(VERSION)/' \
	| sed -e 's/@PKGREL@/$(PKGREL)/' \
	| sed -e 's/@DESC@/Bash argument parsing code generator/' \
	| sed -e 's|@URL@|https://github.com/matejak/argbash|' \
	| sed -e 's/@MD5SUM@/$(shell cat md5-$(VERSION))/' \
	| sed -e 's/@LIC_MD5UM@/$(shell cat md5-LICENSE)/' \
	> $@
endef

PKGBUILD: arch/PKGBUILD $(SOURCE) md5-$(VERSION) md5-LICENSE
	$(substitute)

archlinux: PKGBUILD
	makepkg -f

SPEC: rpm/SPEC $(SOURCE)
	$(substitute)
