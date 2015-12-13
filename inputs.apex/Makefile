.PHONY: all clean

INPUTS = load1-mpiio-filepertask.ior \
         load1-mpiio-sharedfile.ior \
         load1-posix-filepertask.ior \
         load1-posix-sharedfile.ior

all: $(INPUTS)

load1-mpiio-filepertask.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=MPIIO/' \
	    -e 's/collective=[01]/collective=1/' \
	    -e 's/filePerProc=[01]/filePerProc=1/' $< > $@
load1-mpiio-sharedfile.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=MPIIO/' \
	    -e 's/collective=[01]/collective=1/' \
	    -e 's/filePerProc=[01]/filePerProc=0/' $< > $@

load1-posix-filepertask.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e 's/collective=[01]/collective=0/' \
	    -e 's/filePerProc=[01]/filePerProc=1/' $< > $@

load1-posix-sharedfile.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e 's/collective=[01]/collective=0/' \
	    -e 's/filePerProc=[01]/filePerProc=0/' $< > $@

clean:
	-rm $(INPUTS)
