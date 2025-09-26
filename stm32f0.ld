/* STM32F042: 32 KB Flash @ 0x0800_0000, 6 KB SRAM @ 0x2000_0000 */
ENTRY(Reset_Handler)

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 32K
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 6K
}

/* Top of stack = end of RAM */
_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
  /* Vector table must be first in FLASH */
  .isr_vector :
  {
    KEEP(*(.isr_vector))
  } > FLASH

  /* Code + const */
  .text :
  {
    _stext = .;
    *(.text*)
    *(.rodata*)
    *(.glue_7) *(.glue_7t)
    *(.eh_frame*)
    . = ALIGN(4);
    _etext = .;              /* End of text in FLASH; use as LMA for .data */
  } > FLASH

  /* Exception unwind tables (if any) */
  .ARM.exidx :
  {
    *(.ARM.exidx*)
    *(.ARM.extab*)
    . = ALIGN(4);
  } > FLASH

  /* Initialized data lives in RAM but is loaded from FLASH at _etext */
  .data : AT ( _etext )
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data*)
    *(.gnu.linkonce.d*)
    . = ALIGN(4);
    _edata = .;
  } > RAM

  /* Alias used by startup for copy source */
  _sidata = _etext;

  /* Uninitialized data */
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
