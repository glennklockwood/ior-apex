.PHONY: all clean

INPUTS = load1-mpiio-filepertask.ior \
         load1-mpiio-sharedfile.ior \
         load1-posix-filepertask.ior \
         load1-posix-sharedfile.ior \
         load3-posix-filepertask.ior \
         load3-posix-sharedfile.ior


all: $(INPUTS)

load1-mpiio-filepertask.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=MPIIO/' \
	    -e 's/collective=[01]/collective=1/' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the MPI-IO I\/O API and one file per task/' \
	    -e 's/filePerProc=[01]/filePerProc=1/' $< > $@
load1-mpiio-sharedfile.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=MPIIO/' \
	    -e 's/collective=[01]/collective=1/' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the MPI-IO I\/O API and a single shared file/' \
	    -e 's/filePerProc=[01]/filePerProc=0/' $< > $@

load1-posix-filepertask.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e 's/collective=[01]/collective=0/' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the POSIX I\/O API and one file per task/' \
	    -e 's/filePerProc=[01]/filePerProc=1/' $< > $@

load1-posix-sharedfile.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e 's/collective=[01]/collective=0/' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the POSIX I\/O API and a single shared file/' \
	    -e 's/filePerProc=[01]/filePerProc=0/' $< > $@

load3-posix-filepertask.ior: load1-template.ior
	ed -s $< <<< $$'15m19\n14m19\nw /dev/stdout' | \
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e '/^ *collective=/d' \
	    -e 's/Size=[^ ]*/Size=4K/' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the POSIX I\/O API and one file per task/' \
	    -e 's/filePerProc=[01]/filePerProc=1/' > $@

load3-posix-sharedfile.ior: load1-template.ior
	ed -s $< <<< $$'15m19\n14m19\nw /dev/stdout' | \
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e '/^ *collective=/d' \
	    -e 's/Size=[^ ]*/Size=4K/' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the POSIX I\/O API and a single shared file/' \
	    -e 's/filePerProc=[01]/filePerProc=0/' > $@

clean:
	-rm $(INPUTS)
