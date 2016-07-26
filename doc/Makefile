# Makefile for Sphinx documentation
#

# Directory of this Makefile
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
PAPER         =
BUILDDIR      = $(ROOT_DIR)/_build

# User-friendly check for sphinx-build
ifeq ($(shell which $(SPHINXBUILD) >/dev/null 2>&1; echo $$?), 1)
$(error The '$(SPHINXBUILD)' command was not found. Make sure you have Sphinx installed, then set the SPHINXBUILD environment variable to point to the full path of the '$(SPHINXBUILD)' executable. Alternatively you can add the directory with the executable to your PATH. If you dont have Sphinx installed, grab it from http://sphinx-doc.org/)
endif

# Internal variables.
PAPEROPT_a4     = -D latex_paper_size=a4
PAPEROPT_letter = -D latex_paper_size=letter
ALLSPHINXOPTS   = -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .
# the i18n builder cannot share the environment and doctrees with the others
I18NSPHINXOPTS  = $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .

.PHONY: help clean html singlehtml epub latex latexpdf man gettext texinfo info

include $(ROOT_DIR)/Makefile.pieces

html: $(PIECES)
	$(BUILD_STEP)

clean: clean-pieces
	rm -rf $(BUILDDIR)/*

define BUILD_STEP
	$(SPHINXBUILD) -b $@ $(ALLSPHINXOPTS) $(BUILDDIR)/$@
	@echo
	@echo "Build finished. The result is in $(BUILDDIR)/$@."
endef

singlehtml: $(PIECES)
	$(BUILD_STEP)

epub: $(PIECES)
	$(BUILD_STEP)

latex: $(PIECES)
	$(BUILD_STEP)

latexpdf: $(PIECES) latex
	$(SPHINXBUILD) -b latex $(ALLSPHINXOPTS) $(BUILDDIR)/latex
	@echo "Running LaTeX files through pdflatex..."
	$(MAKE) -C $(BUILDDIR)/latex all-pdf
	@echo "pdflatex finished; the PDF files are in $(BUILDDIR)/latex."

man: $(PIECES)
	$(BUILD_STEP)

MANDIR = man
$(MANDIR):
	mkdir -p $@

# Man files should be part of the repo.
argbash.1: argbash.rst | $(MANDIR)
	grep -v ':ref:' $< | sed -e 's/^\.\.\s\+code-block.*/::/' | rst2man > $@

argbash.5: config.rst | $(MANDIR)
	grep -v ':ref:' $< | sed -e 's/^\.\.\s\+code-block.*/::/' | rst2man > $@

texinfo: $(PIECES)
	$(BUILD_STEP)

info: $(PIECES) texinfo
	@echo "Running Texinfo files through makeinfo..."
	make -C $(BUILDDIR)/texinfo info
	@echo "makeinfo finished; the Info files are in $(BUILDDIR)/texinfo."
