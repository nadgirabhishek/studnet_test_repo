#include <stdint.h>
#include "stm32f0_regs.h"

#define LED_PIN 5
#define SYSTEM_CORE_CLOCK 8000000UL

static inline void systick_init_1ms(void)
{
    SYST->LOAD = (SYSTEM_CORE_CLOCK / 1000) - 1;  // 1 ms reload
    SYST->VAL  = 0;
    // Enable counter, use core clock, BUT DO NOT enable interrupt
    SYST->CTRL = SYST_CTRL_CLKSRC | SYST_CTRL_ENABLE;
}

static void delay_ms(uint32_t ms)
{
    while (ms--)
    {
        // COUNTFLAG is bit 16; it is set to 1 when the counter wraps
        // Reading CTRL returns it; next wrap will set it again.
        while ((SYST->CTRL & (1u << 16)) == 0) { __asm volatile("nop"); }
    }
}

int main(void)
{
    // Enable GPIOA clock
    RCC->AHBENR |= (1u << 17);

    // PA5 output
    GPIOA->MODER &= ~(3u << (LED_PIN * 2));
    GPIOA->MODER |=  (1u << (LED_PIN * 2));

    systick_init_1ms();

    for (;;)
    {
        GPIOA->ODR ^= (1u << LED_PIN);
        delay_ms(500);
    }
}
