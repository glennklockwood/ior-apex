.PHONY: all clean

INPUTS = load1-mpiio-filepertask.ior \
         load1-mpiio-sharedfile.ior \
         load1-posix-filepertask.ior \
         load1-posix-sharedfile.ior \
         load2-posix-filepertask.ior \
         load2-posix-sharedfile.ior \
         load3-posix-filepertask.ior \
         load3-posix-sharedfile.ior

all: $(INPUTS)

load1-mpiio-filepertask.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=MPIIO/' \
	    -e 's/collective=[01]/collective=1/' \
	    -e 's/readFile=[01]/readFile=1/' \
	    -e 's/writeFile=[01]/writeFile=1/' \
	    -e '/^ *blastMode=/d' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the MPI-IO I\/O API and one file per task/' \
	    -e 's/filePerProc=[01]/filePerProc=1/' $< > $@
load1-mpiio-sharedfile.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=MPIIO/' \
	    -e 's/collective=[01]/collective=1/' \
	    -e 's/readFile=[01]/readFile=1/' \
	    -e 's/writeFile=[01]/writeFile=1/' \
	    -e '/^ *blastMode=/d' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the MPI-IO I\/O API and a single shared file/' \
	    -e 's/testFile=\(.*\)# will read\/write .*$$/testFile=\1# will read\/write to a shared file called \1/' \
	    -e 's/filePerProc=[01]/filePerProc=0/' $< > $@

load1-posix-filepertask.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e 's/collective=[01]/collective=0/' \
	    -e 's/readFile=[01]/readFile=1/' \
	    -e 's/writeFile=[01]/writeFile=1/' \
	    -e '/^ *blastMode=/d' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the POSIX I\/O API and one file per task/' \
	    -e 's/filePerProc=[01]/filePerProc=1/' $< > $@

load1-posix-sharedfile.ior: load1-template.ior
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e 's/collective=[01]/collective=0/' \
	    -e 's/readFile=[01]/readFile=1/' \
	    -e 's/writeFile=[01]/writeFile=1/' \
	    -e '/^ *blastMode=/d' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the POSIX I\/O API and a single shared file/' \
	    -e 's/testFile=\(.*\)# will read\/write .*$$/testFile=\1# will read\/write to a shared file called \1/' \
	    -e 's/filePerProc=[01]/filePerProc=0/' $< > $@

load2-template.ior: load1-template.ior
	ed -s $< <<< $$'14m20\n14m20\nw /dev/stdout' | \
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e 's/readFile=[01]/readFile=1/' \
	    -e 's/writeFile=[01]/writeFile=0/' \
	    -e '/^ *collective=/d' \
	    -e '/^ *memoryPerNode=/d' \
	    -e 's/blastMode=[01]/blastMode=1/' \
	    -e 's/transferSize=[^ ]*/transferSize=4K/' \
	    -e 's/blockSize=[^ ]* /blockSize=10M/' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the POSIX I\/O API and one file per task/' \
	    -e 's/.  You must find the optimal transferSize for the storage system.//' > $@

load2-posix-filepertask.ior: load2-template.ior
	sed -e 's/filePerProc=[01]/filePerProc=1/' $< > $@

load2-posix-sharedfile.ior: load2-template.ior
	sed -e 's/filePerProc=[01]/filePerProc=0/' $< > $@

load3-template.ior: load1-template.ior
	ed -s $< <<< $$'14m20\n14m20\nw /dev/stdout' | \
	sed -e 's/api=[^ ]*/api=POSIX/' \
	    -e 's/readFile=[01]/readFile=1/' \
	    -e 's/writeFile=[01]/writeFile=1/' \
	    -e 's/randomOffset=[01]/randomOffset=1/' \
	    -e '/^ *collective=/d' \
	    -e '/^ *blastMode=/d' \
	    -e 's/Size=[^ ]*/Size=4K/' \
	    -e '3,3s/Run the .*$$/Run the IOR benchmark with the POSIX I\/O API and one file per task/' \
	    -e 's/.  You must find the optimal transferSize for the storage system.//' \
	    -e 's/filePerProc=[01]/filePerProc=1/' > $@

load3-posix-filepertask.ior: load3-template.ior
	sed -e 's/filePerProc=[01]/filePerProc=1/' $< > $@

load3-posix-sharedfile.ior: load3-template.ior
	sed -e 's/filePerProc=[01]/filePerProc=0/' $< > $@

clean:
	-rm $(INPUTS) load[23]-template.ior
