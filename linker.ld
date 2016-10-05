ENTRY(start)

SECTIONS {
  . = 1M;

  .text ALIGN(0x1000) : {
    KEEP(*(.multiboot))
    *(.text .text.*)
  }

  .data ALIGN(0x1000) : {
    *(.data .data.*)
  }

  .rodata ALIGN(0x1000) : {
    *(.rodata .rodata.*)
  }

  .bss ALIGN(0x1000) : {
    *(.bss)
  }
}