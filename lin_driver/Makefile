obj-m += aperf_mperf1_0.o
aperf_mperf1_0-objs := ./src/aperf_mperf.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

