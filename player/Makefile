DISKIMAGE=player.dsk

system_files = player.system

src_files = $(wildcard *.s)
objects = $(patsubst %.s,%.o,$(src_files))

all: $(DISKIMAGE)

%.o : %.s
	ca65 -t apple2 --cpu 6502 -o $@ -l player.lst $<

%.system : %.o
	cl65 -t apple2 -C make/apple2-asm-system.cfg -u __EXEHDR__ --start-addr 0x2000 -o $@ $<

clean:
	rm -f $(objects) $(system_files) $(DISKIMAGE)

$(DISKIMAGE): $(bin_files) $(system_files)
	cp make/prodos_template.dsk $(DISKIMAGE)
	java -jar make/AppleCommander.jar -d $(DISKIMAGE) NS.CLOCK.SYSTEM
	java -jar make/AppleCommander.jar -d $(DISKIMAGE) LOADER.SYSTEM

	java -jar make/AppleCommander.jar -as $(DISKIMAGE) player.system < player.system
