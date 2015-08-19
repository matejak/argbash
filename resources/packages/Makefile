VERSION = $(shell cat ../../src/version)

SOURCE = argbash-$(VERSION).tar.gz

source: $(SOURCE)

$(SOURCE):
	wget https://github.com/matejak/argbash/archive/$(VERSION).tar.gz

md5-$(VERSION): $(SOURCE)
	md5sum $< | cut -f 1 -d ' ' > $@

PKGBUILD: arch/PKGBUILD $(SOURCE) md5-$(VERSION)
	cat $< \
		| sed -e 's/@VERSION@/$(VERSION)/' \
		| sed -e 's/@PKGREL@/$(PKGREL)/' \
		| sed -e 's/@DESC@/Bash argument parsing code generator/' \
		| sed -e 's|@URL@|https://github.com/matejak/argbash|' \
		| sed -e 's/@MD5SUM@/$(shell cat md5-$(VERSION))/' \
		> $@

SPEC: rpm/SPEC $(SOURCE)
	sed -e 's/@VERSION@/$(VERSION)/' $< > $@
