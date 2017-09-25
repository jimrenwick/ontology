
m4_files=$(wildcard *.m4)
sh_files=$(patsubst %.m4, %.sh, $(m4_files))

%.sh : %.m4 $(ONTOLOGY_HOME)/lib/onts-macros.m4
	m4 $(M4_DEBUG)--prefix-builtins $(ONTOLOGY_HOME)/lib/onts-macros.m4 $< > $@ 2> $@.m4_log ; \
	if [ $$? -ne 0 ]; then \
		echo "ERROR!" ; \
	fi ; \
	cat $@.m4_log ; \
	rm -f $@.m4_log ; \
	chmod 600 $@

all : $(sh_files)

$(sh_files) : $(m4_files)

clean :; @rm -f $(sh_files) *~ *.tar.gz
