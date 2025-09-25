/* startup_stm32f0.s — Cortex-M0 safe startup
 * - No IT blocks (Thumb-2) and no post-indexed LDR/STR
 * - Copies .data from FLASH (_etext) to RAM
 * - Zeros .bss
 * - Jumps to main
 */

.syntax unified
.cpu cortex-m0
.thumb

/* Externs from linker script */
.global _estack
.extern _etext
.extern __data_start__
.extern __data_end__
.extern __bss_start__
.extern __bss_end__
.extern main

/* Weak core handlers map to Default_Handler unless overridden in C */
.weak  NMI_Handler, HardFault_Handler, SVC_Handler, PendSV_Handler, SysTick_Handler
.thumb_set NMI_Handler,     Default_Handler
.thumb_set HardFault_Handler, Default_Handler
.thumb_set SVC_Handler,     Default_Handler
.thumb_set PendSV_Handler,  Default_Handler
/* SysTick_Handler can be provided by your C code; otherwise defaults */
.thumb_set SysTick_Handler, Default_Handler

/* ---------------- Vector Table ---------------- */
.section .isr_vector, "a", %progbits
.align  2
.global g_pfnVectors
g_pfnVectors:
  .word _estack            /* 0: Initial MSP value (provided by linker) */
  .word Reset_Handler      /* 1: Reset */
  .word NMI_Handler        /* 2: NMI */
  .word HardFault_Handler  /* 3: HardFault */
  .word 0                  /* 4: Reserved */
  .word 0                  /* 5: Reserved */
  .word 0                  /* 6: Reserved */
  .word 0                  /* 7: Reserved */
  .word 0                  /* 8: Reserved */
  .word 0                  /* 9: Reserved */
  .word 0                  /* 10: Reserved */
  .word SVC_Handler        /* 11: SVCall */
  .word 0                  /* 12: Reserved */
  .word 0                  /* 13: Reserved */
  .word PendSV_Handler     /* 14: PendSV */
  .word SysTick_Handler    /* 15: SysTick */

/* If you want, you can extend with device-specific IRQs here,
 * all defaulting to Default_Handler. For minimal bring-up this
 * core table is enough.
 */

/* ---------------- Reset Handler ---------------- */
.section .text.Reset_Handler, "ax", %progbits
.align  2
.thumb_func
.global Reset_Handler
Reset_Handler:
  /* r0 = src (FLASH image), r1 = dst (RAM), r2 = end */
  ldr   r0, =_etext
  ldr   r1, =__data_start__
  ldr   r2, =__data_end__
1:                                /* copy .data */
  cmp   r1, r2
  bge   2f                        /* done when dst >= end */
  ldr   r3, [r0]                  /* r3 = *src */
  adds  r0, r0, #4                /* src += 4 */
  str   r3, [r1]                  /* *dst = r3 */
  adds  r1, r1, #4                /* dst += 4 */
  b     1b
2:
  /* zero .bss: r0 = bss, r1 = end, r2 = 0 */
  ldr   r0, =__bss_start__
  ldr   r1, =__bss_end__
  movs  r2, #0
3:
  cmp   r0, r1
  bge   4f
  str   r2, [r0]
  adds  r0, r0, #4
  b     3b
4:
  /* call main() */
  bl    main

  /* if main returns, loop forever */
5:
  b     5b

/* ---------------- Default Handler ---------------- */
.section .text.Default_Handler, "ax", %progbits
.align  2
.thumb_func
.global Default_Handler
Default_Handler:
  b     Default_Handler
