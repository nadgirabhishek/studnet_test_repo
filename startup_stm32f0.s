/* Minimal STM32F0 (Cortex-M0) startup file with correct SysTick override and VTOR set */

.syntax unified
.cpu cortex-m0
.thumb

/* External symbols provided by the linker script */
.extern _sidata
.extern _sdata
.extern _edata
.extern _sbss
.extern _ebss
.extern _estack
.extern main

/*----------------------------------------------------------------------------
 * Vector table
 *---------------------------------------------------------------------------*/
.section .isr_vector, "a", %progbits
.align  2
.global g_pfnVectors
.type   g_pfnVectors, %object

g_pfnVectors:
  .word  _estack            /* Initial Stack Pointer */
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

/* If you have device-specific IRQs, list them here after SysTick.
 * For a basic template, we leave them out or alias them in Default_Handler.
 */

/*----------------------------------------------------------------------------
 * Default weak handlers
 *---------------------------------------------------------------------------*/
.text
.thumb
.align 1

/* Declare handlers weak so user code can override them */
.weak  NMI_Handler
.weak  HardFault_Handler
.weak  SVC_Handler
.weak  PendSV_Handler
.weak  SysTick_Handler

/* All but SysTick get aliased to Default_Handler.
 * DO NOT alias SysTick_Handler, so a C definition overrides properly.
 */
.thumb_set NMI_Handler,       Default_Handler
.thumb_set HardFault_Handler, Default_Handler
.thumb_set SVC_Handler,       Default_Handler
.thumb_set PendSV_Handler,    Default_Handler
/* No alias for SysTick_Handler on purpose */

/*----------------------------------------------------------------------------
 * Reset handler: init data/bss, set VTOR, enable IRQs, call main
 *---------------------------------------------------------------------------*/
.global Reset_Handler
.type   Reset_Handler, %function
Reset_Handler:
  /* Copy .data from FLASH to RAM */
  ldr   r0, =_sidata
  ldr   r1, =_sdata
  ldr   r2, =_edata
1:
  cmp   r1, r2
  ittt  lt
  ldrlt r3, [r0], #4
  strlt r3, [r1], #4
  blt   1b

  /* Zero .bss */
  ldr   r0, =_sbss
  ldr   r1, =_ebss
  movs  r2, #0
2:
  cmp   r0, r1
  it    lt
  strlt r2, [r0], #4
  blt   2b

  /* Point VTOR at our vector table (SCB->VTOR = &g_pfnVectors) */
  ldr   r0, =g_pfnVectors
  ldr   r1, =0xE000ED08   /* SCB->VTOR */
  str   r0, [r1]

  /* Enable IRQs just in case (should be enabled by default) */
  cpsie i

  /* Call main */
  bl    main

  /* If main returns, loop forever */
3:
  b     3b

.size Reset_Handler, .-Reset_Handler

/*----------------------------------------------------------------------------
 * Default handler
 *---------------------------------------------------------------------------*/
.global Default_Handler
.type   Default_Handler, %function
Default_Handler:
  /* Stay here if an unexpected interrupt occurs */
  b Default_Handler

.size Default_Handler, .-Default_Handler
