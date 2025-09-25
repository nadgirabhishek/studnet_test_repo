/* STM32F091RC: 256KB Flash, 32KB RAM */
MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 256K
  RAM   (rwx): ORIGIN = 0x20000000, LENGTH = 32K
}

_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
  .isr_vector :
  {
    KEEP(*(.isr_vector))
  } > FLASH

  .text :
  {
    *(.text*) *(.rodata*) *(.glue_7) *(.glue_7t)
    _etext = .;
  } > FLASH

  .data : AT ( _etext )
  {
    __data_start__ = .;
    *(.data*)
    __data_end__ = .;
  } > RAM

  .bss (NOLOAD) :
  {
    __bss_start__ = .;
    *(.bss*) *(COMMON)
    __bss_end__ = .;
  } > RAM
}
