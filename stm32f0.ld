ENTRY(Reset_Handler)

/* Adjust sizes to your exact STM32F0 part if needed */
MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 64K
  RAM   (rwx): ORIGIN = 0x20000000, LENGTH = 8K
}

/* Initial stack pointer */
_estack = ORIGIN(RAM) + LENGTH(RAM);

/* Used by startup to copy .data */
_sidata = LOADADDR(.data);

SECTIONS
{
  /* Vector table must be first in FLASH */
  .isr_vector :
  {
    KEEP(*(.isr_vector))
  } > FLASH

  .text :
  {
    *(.text*)
    *(.rodata*)
    *(.glue_7) *(.glue_7t)
    *(.eh_frame*)

    . = ALIGN(4);
    KEEP(*(.init))
    KEEP(*(.fini))
    . = ALIGN(4);
    _etext = .;
  } > FLASH

  .ARM.exidx :
  {
    *(.ARM.exidx*)
    *(.ARM.extab*)
  } > FLASH

  .data : AT (ADDR(.text) + SIZEOF(.text) + SIZEOF(.ARM.exidx))
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } > RAM

  .bss (NOLOAD) :
  {
    . = ALIGN(4);
    _sbss = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } > RAM
}
