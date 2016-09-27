INDIR		= .
OUTDIR		= build
MKRDIR		= iso
TARGET		= plain-plain-i386
ASFORMAT	= elf32
LDFORMAT	= elf32-i386
LDEMULMF	= elf_i386
LDSCRIPT	= linker.ld
STATFILE	= status

all: setup assemble link verify pack explain

explain:
	@ \
	cat $(STATFILE); \
	rm -f $(STATFILE)*

qemu:
	qemu-system-i386 -m 64 -cdrom $(OUTDIR)/$(TARGET).iso -vga std -display curses

pack:
	@ \
	printf "Packing kernel...\040" >> $(STATFILE); \
	cp $(OUTDIR)/$(TARGET) $(MKRDIR)/boot/; \
	if grub-mkrescue \
		-o $(OUTDIR)/$(TARGET).iso $(MKRDIR) \
		1>/dev/null 2> $(STATFILE)_grub; \
	then \
		printf "OK\n" >> $(STATFILE); \
	else \
		printf "FAIL\n" >> $(STATFILE); \
		cat $(STATFILE)_grub >> $(STATFILE); \
	fi

verify:
	@ \
	printf "Verifying multiboot2 header...\040" >> $(STATFILE); \
	if grub-file --is-x86-multiboot2 $(OUTDIR)/$(TARGET); then \
		printf "OK\n" >> $(STATFILE); \
	else \
		printf "FAIL\n" >> $(STATFILE); \
	fi

link:
	@ \
	printf "Linking objects...\040" >> $(STATFILE); \
	if ld \
		-nmagic \
		-m $(LDEMULMF) \
		-o $(OUTDIR)/$(TARGET) \
		--oformat $(LDFORMAT) \
		--script $(INDIR)/linker.ld \
		$(OUTDIR)/start.o \
		>> $(STATFILE)_ld; \
	then \
		printf "OK\n" >> $(STATFILE); \
	else \
		printf "FAIL\n" >> $(STATFILE); \
		cat $(STATFILE)_ld >> $(STATFILE); \
	fi

assemble:
	@ \
	printf "Assembling sources...\040" >> $(STATFILE); \
	if nasm \
		-f $(ASFORMAT) \
		-o $(OUTDIR)/start.o \
		$(INDIR)/start.s \
		>> $(STATFILE)_as; \
	then \
		printf "OK\n" >> $(STATFILE); \
	else \
		printf "FAIL\n" >> $(STATFILE); \
		cat $(STATFILE)_as >> $(STATFILE); \
	fi

setup:
	@ \
	mkdir -p $(OUTDIR)

.PHONY: clean

clean:
	@ \
	rm -f $(OUTDIR)/*.o $(STATFILE)*