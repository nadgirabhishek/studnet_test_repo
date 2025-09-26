#include <stdint.h>
#include "stm32f0_regs.h"

#define LED_PIN 5
#define SYSTEM_CORE_CLOCK 8000000UL

volatile uint32_t g_ms = 0;

/* Mark as used so --gc-sections never drops it, and read CTRL to clear COUNTFLAG */
void SysTick_Handler(void) __attribute__((used));
void SysTick_Handler(void)
{
    g_ms++;
    (void)SYST->CTRL;   // read to clear COUNTFLAG
}

static void delay_ms(uint32_t ms) {
    uint32_t start = g_ms;
    while ((g_ms - start) < ms) { __asm volatile ("nop"); }
}

int main(void) {
    /* enable GPIOA clock */
    RCC->AHBENR |= (1u << 17);

    /* PA5 as output */
    GPIOA->MODER &= ~(3u << (LED_PIN*2));
    GPIOA->MODER |=  (1u << (LED_PIN*2));

    /* SysTick 1ms tick @ 8 MHz */
    SYST->LOAD = (SYSTEM_CORE_CLOCK / 1000) - 1;
    SYST->VAL  = 0;
    SYST->CTRL = SYST_CTRL_CLKSRC | SYST_CTRL_TICKINT | SYST_CTRL_ENABLE;

    while (1) {
        GPIOA->ODR ^= (1u << LED_PIN);
        delay_ms(500);
    }
}
