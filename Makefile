#
#  Makefile for assembling the APEX IOR benchmark package
#
.PHONY: all clean

all:
	make -C inputs.apex

clean:
	make -C inputs.apex clean
