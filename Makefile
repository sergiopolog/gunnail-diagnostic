AS=asl
P2BIN=p2bin
SRC=src/patch.a68
BSPLIT=bsplit
MAME=mame

ASFLAGS=-i . -n -U

.PHONY: all clean prg.o data

all: prg.bin

data: gunnail.zip nmk004.zip
	mkdir -p $@
	cp gunnail.zip $@ && cd $@ && unzip -o $<
	cp nmk004.zip $@ && cd $@ && unzip -o $<

prg.orig: data
	$(BSPLIT) c data/3e.u131 data/3o.u133 $@

prg.o: prg.orig
	$(AS) $(SRC) $(ASFLAGS) -o prg.o

prg.bin: prg.o
	$(P2BIN) $< $@ -r \$$-0x7FFFF

gunnail: prg.bin data
	mkdir -p $@
	cp data/* $@
	$(BSPLIT) s $< $@/3e.u131 $@/3o.u133

gunnailp: prg.bin data
	mkdir -p $@
	cp data/* $@
	# gunnailp unique prg rom is byte-swapped, proceed with that:
	$(BSPLIT) s $< $@.even $@.odd
	$(BSPLIT) c $@.odd $@.even data/3.u132
	rm -rf $@.odd $@.even

test: gunnail
	$(MAME) $< -rompath $(shell pwd) -debug

testp: gunnailp
	$(MAME) $< -rompath $(shell pwd) -debug

package: gunnail
	zip gunnail-test.zip $</*

packagep: gunnailp
	zip gunnailp-test.zip $</*

clean:
	@-rm -rf gunnail-test.zip
	@-rm -rf gunnailp-test.zip
	@-rm -rf data
	@-rm -rf prg.orig
	@-rm -rf prg.bin
	@-rm -rf prg.o
