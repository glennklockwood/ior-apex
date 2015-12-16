#
#  Makefile for assembling the APEX IOR benchmark package
#
.PHONY: all clean

PACKAGE=ior-3.0.1-apex

TARFILE_CONTENTS = $(PACKAGE)/configure     $(PACKAGE)/README           \
                   $(PACKAGE)/COPYRIGHT     $(PACKAGE)/testing          \
                   $(PACKAGE)/contrib       $(PACKAGE)/doc              \
                   $(PACKAGE)/scripts       $(PACKAGE)/src              \
                   $(PACKAGE)/config        $(PACKAGE)/META             \
                   $(PACKAGE)/README.APEX   $(PACKAGE)/Makefile.in

INPUTS_APEX = load1-posix-filepertask.ior \
              load1-posix-sharedfile.ior \
              load1-mpiio-filepertask.ior \
              load1-mpiio-sharedfile.ior \
              load2-generate-testFile.ior \
              load2-posix-filepertask.ior \
              load2-posix-sharedfile.ior \
              load3-posix-filepertask.ior \
              load3-posix-sharedfile.ior

$(PACKAGE).tar.gz: $(PACKAGE) $(TARFILE_CONTENTS) $(PACKAGE)/inputs.apex
	tar -cz --exclude=*.m4 --exclude=Makefile.am -f $@ $^

$(PACKAGE):
	mkdir $@

ior/configure ior/Makefile.in: ior/bootstrap
	cd ior && ./bootstrap

$(PACKAGE)/inputs.apex:
	make -C inputs.apex
	mkdir -p $@
	for file in $(INPUTS_APEX); do cp -v inputs.apex/$$file $@;done

$(PACKAGE)/README.APEX: README.APEX
	cp -v $< $@

$(PACKAGE)/%: ior/%
	if [ -d "ior/`basename $@`" ]; then cp -rv "ior/`basename $@`/." "$@"; else cp -rv "ior/`basename $@`" "$@";fi

clean:
	-rm -r $(PACKAGE) $(PACKAGE).tar.gz
	make -C inputs.apex clean
