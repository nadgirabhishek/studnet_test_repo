.syntax unified
.cpu cortex-m0
.thumb

.global _estack
.global Reset_Handler

/* Linker provides these */
.extern __etext
.extern __data_start__
.extern __data_end__
.extern __bss_start__
.extern __bss_end__
.extern main

/* Vector table placed at start of FLASH */
.section .isr_vector, "a", %progbits
.word _estack                 /* Initial SP */
.word Reset_Handler           /* Reset */
.word Default_Handler         /* NMI */
.word Default_Handler         /* HardFault */
.word Default_Handler         /* Reserved */
.word Default_Handler         /* Reserved */
.word Default_Handler         /* Reserved */
.word Default_Handler         /* Reserved */
.word Default_Handler         /* Reserved */
.word Default_Handler         /* Reserved */
.word Default_Handler         /* Reserved */
.word Default_Handler         /* SVC */
.word Default_Handler         /* Reserved */
.word Default_Handler         /* Reserved */
.word Default_Handler         /* PendSV */
.word SysTick_Handler         /* SysTick */

.section .text.Reset_Handler, "ax", %progbits
.thumb_func
Reset_Handler:
  /* Copy .data from FLASH to RAM */
  ldr r0, =__etext
  ldr r1, =__data_start__
  ldr r2, =__data_end__
1:
  cmp r1, r2
  ittt lt
  ldrlt r3, [r0], #4
  strlt r3, [r1], #4
  blt 1b

  /* Zero .bss */
  ldr r0, =__bss_start__
  ldr r1, =__bss_end__
  movs r2, #0
2:
  cmp r0, r1
  it lt
  strlt r2, [r0], #4
  blt 2b

  /* Jump to main */
  bl main
  b .
  
.thumb_func
Default_Handler:
  b .
