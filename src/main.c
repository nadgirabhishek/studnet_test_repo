#include <stdint.h>
#include "stm32f0_regs.h"

#define LED_PIN 5
#define SYSTEM_CORE_CLOCK 8000000UL  // HSI 8 MHz default after reset on STM32F0


volatile uint32_t g_ms;
void SysTick_Handler(void) { g_ms++; }


static void delay_ms(uint32_t ms) {
    uint32_t start = g_ms;
    while ((g_ms - start) < ms) { __asm volatile ("nop"); }
}

int main(void) {
    // Enable GPIOA clock
    RCC->AHBENR |= RCC_AHBENR_IOPAEN;

    // Set PA5 as general purpose output (MODER5 = 01)
    GPIOA->MODER &= ~(3u << (LED_PIN*2));
    GPIOA->MODER |=  (1u << (LED_PIN*2));

    // Configure SysTick for 1ms tick
    SYST->LOAD = (SYSTEM_CORE_CLOCK / 1000) - 1; // 8000 - 1
    SYST->VAL  = 0;
    SYST->CTRL = SYST_CTRL_CLKSRC | SYST_CTRL_TICKINT | SYST_CTRL_ENABLE;

    while (1) {
        // Toggle PA5 every 500 ms -> 1 Hz square wave
        GPIOA->ODR ^= (1u << LED_PIN);
        delay_ms(500);
    }
}
