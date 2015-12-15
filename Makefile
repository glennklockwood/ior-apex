#
#  Makefile for assembling the APEX IOR benchmark package
#
.PHONY: all clean

PACKAGE=ior-3.0.1-apex

TARFILE_CONTENTS = $(PACKAGE)/configure $(PACKAGE)/README \
                   $(PACKAGE)/COPYRIGHT $(PACKAGE)/testing \
                   $(PACKAGE)/contrib $(PACKAGE)/doc \
                   $(PACKAGE)/scripts $(PACKAGE)/src

INPUTS_APEX = load1-posix-filepertask.ior \
              load1-posix-sharedfile.ior \
              load1-mpiio-filepertask.ior \
              load1-mpiio-sharedfile.ior \
              load2-generate-testFile.ior \
              load2-posix-filepertask.ior \
              load2-posix-sharedfile.ior \
              load3-posix-filepertask.ior \
              load3-posix-sharedfile.ior

all: $(PACKAGE).tar.gz

clean:
	-rm -r $(PACKAGE) $(PACKAGE).tar.gz
	make -C inputs.apex clean

ior/configure: ior/bootstrap
	cd ior && ./bootstrap

$(PACKAGE): ior/configure
	mkdir $@

$(TARFILE_CONTENTS): ior/configure $(PACKAGE) 
	cp -rv ior/`basename $@` $@

$(PACKAGE)/inputs.apex: $(PACKAGE)
	make -C inputs.apex
	mkdir -p $@
	for file in $(INPUTS_APEX); do cp -v inputs.apex/$$file $@;done

$(PACKAGE)/README.APEX: README.APEX $(PACKAGE)
	cp -v $< $@

$(PACKAGE).tar.gz: $(TARFILE_CONTENTS) $(PACKAGE)/inputs.apex $(PACKAGE)/README.APEX
	tar -cz --exclude=Makefile.in --exclude=Makefile.am --exclude=config.h.in -f $@ $^
