ENTRY(start)

SECTIONS {
  . = 0xC0010000;

  .text ALIGN(0x1000) : AT(ADDR(.text)-0xC0000000) {
    KEEP(*(.multiboot))
    *(.text .text.*)
  }

  .data ALIGN(0x1000) : AT(ADDR(.data)-0xC0000000) {
    *(.data .data.*)
  }

  .rodata ALIGN(0x1000) : AT(ADDR(.rodata)-0xC0000000) {
    *(.rodata .rodata.*)
  }

  .bss ALIGN(0x1000) : AT(ADDR(.bss)-0xC0000000) {
    *(.bss)
  }
}
