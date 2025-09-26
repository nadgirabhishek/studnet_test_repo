/* Minimal STM32F0 linker script ensuring vector table is first in FLASH */

ENTRY(Reset_Handler)

/* Adjust sizes to your exact STM32F0 part if needed */
MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 64K
  RAM   (rwx): ORIGIN = 0x20000000, LENGTH = 8K
}

/* Initial stack pointer: top of RAM */
_estack = ORIGIN(RAM) + LENGTH(RAM);

/* Provide symbols used by startup */
_sidata = LOADADDR(.data);

SECTIONS
{
  /* Vector table at the very beginning of FLASH */
  .isr_vector :
  {
    KEEP(*(.isr_vector))
  } > FLASH

  .text :
  {
    *(.text*) 
    *(.rodata*)
    *(.gnu.linkonce.t*)
    *(.gnu.linkonce.r*)

    /* Exception unwinding data */
    *(.glue_7) *(.glue_7t)
    *(.eh_frame*)

    /* ARM build attributes */
    . = ALIGN(4);
    KEEP(*(.init))
    KEEP(*(.fini))

    . = ALIGN(4);
    _etext = .;
  } > FLASH

  /* ARM.exidx (if any) must be in FLASH too */
  .ARM.exidx :
  {
    *(.ARM.exidx*)
    *(.ARM.extab*)
  } > FLASH

  /* Initialized data goes in RAM, load from FLASH */
  .data : AT (ADDR(.text) + SIZEOF(.text) + SIZEOF(.ARM.exidx))
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data*)
    *(.gnu.linkonce.d*)
    . = ALIGN(4);
    _edata = .;
  } > RAM

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

  /* Optional heap/stack reservations if you want explicit sizes
     Otherwise, SP uses _estack and heap uses remaining space. */
  /* ._user_heap_stack (NOLOAD) :
  {
    . = ALIGN(8);
    PROVIDE( end = . );
    PROVIDE( _end = . );
  } > RAM */
}
