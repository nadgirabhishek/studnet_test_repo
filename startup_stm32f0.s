/* STM32F0 (Cortex-M0) startup:
 * - No multi-instruction IT blocks (ARMv6-M)
 * - No post-indexed LDR/STR (Thumb-1)
 * - Do NOT alias SysTick_Handler; C override will work
 * - No VTOR write (not on M0); vector table must be first in FLASH
 */

.syntax unified
.cpu cortex-m0
.thumb

/* Linker-provided symbols */
.extern _sidata
.extern _sdata
.extern _edata
.extern _sbss
.extern _ebss
.extern _estack
.extern main

/* ---------------- Vector Table ---------------- */
.section .isr_vector, "a", %progbits
.align  2
.global g_pfnVectors
.type   g_pfnVectors, %object

g_pfnVectors:
  .word  _estack            /* Initial SP */
  .word  Reset_Handler      /* Reset */
  .word  NMI_Handler        /* NMI */
  .word  HardFault_Handler  /* HardFault */
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  SVC_Handler        /* SVCall */
  .word  0                  /* Reserved */
  .word  0                  /* Reserved */
  .word  PendSV_Handler     /* PendSV */
  .word  SysTick_Handler    /* SysTick (IRQ 15) */

.text
.thumb
.align 1

/* ---------------- Weak Handlers ---------------- */
.weak  NMI_Handler
.weak  HardFault_Handler
.weak  SVC_Handler
.weak  PendSV_Handler
.weak  SysTick_Handler

.thumb_set NMI_Handler,       Default_Handler
.thumb_set HardFault_Handler, Default_Handler
.thumb_set SVC_Handler,       Default_Handler
.thumb_set PendSV_Handler,    Default_Handler
/* DO NOT alias SysTick_Handler */

/* ---------------- Reset Handler ---------------- */
.global Reset_Handler
.type   Reset_Handler, %function
Reset_Handler:
  /* Copy .data from FLASH (_sidata) to RAM (_sdata .. _edata) */
  ldr   r0, =_sidata        /* src */
  ldr   r1, =_sdata         /* dst */
  ldr   r2, =_edata         /* end */
copy_data_loop:
  cmp   r1, r2
  bcs   copy_data_done
  ldr   r3, [r0]
  str   r3, [r1]
  adds  r0, r0, #4
  adds  r1, r1, #4
  b     copy_data_loop
copy_data_done:

  /* Zero .bss (_sbss .. _ebss) */
  ldr   r0, =_sbss          /* dst */
  ldr   r1, =_ebss          /* end */
  movs  r2, #0
zero_bss_loop:
  cmp   r0, r1
  bcs   zero_bss_done
  str   r2, [r0]
  adds  r0, r0, #4
  b     zero_bss_loop
zero_bss_done:

  /* Enable IRQs (usually already enabled) */
  cpsie i

  /* Jump to main */
  bl    main

hang:
  b     hang

.size Reset_Handler, .-Reset_Handler

/* ---------------- Default Handler ---------------- */
.global Default_Handler
.type   Default_Handler, %function
Default_Handler:
  b Default_Handler
.size Default_Handler, .-Default_Handler
