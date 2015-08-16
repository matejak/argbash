NUL =
M4_SRC = \
	../src/output.m4 \
	../src/output-standalone.m4 \
	../src/stuff.m4 \
	$(NUL)

GENPARSE = ../bin/genparse.sh
EXAMPLES = \
	examples/simple.sh \
	examples/simple-standalone.sh \
	$(NUL)

%-standalone.sh: %-standalone.m4s $(GENPARSE)
	$(GENPARSE) $< -o $@ --standalone

%-standalone2.sh: %-standalone.sh $(GENPARSE)
	$(GENPARSE) $< -o $@ --standalone

%.sh: %.m4s $(GENPARSE)
	$(GENPARSE) $< -o $@

%2.sh: %.sh $(GENPARSE)
	$(GENPARSE) $< -o $@

%3.sh: %2.sh $(GENPARSE)
	$(GENPARSE) $< -o $@

$(GENPARSE): bin/genparse.m4s $(M4_SRC)
	$(GENPARSE) $< -o $@

examples: $(EXAMPLES)
