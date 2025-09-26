#include <stdint.h>

#define RCC_AHBENR        (*(volatile uint32_t*)0x40021014)
#define RCC_AHBENR_IOPAEN (1u << 17)

#define GPIOA_MODER       (*(volatile uint32_t*)0x48000000)
#define GPIOA_ODR         (*(volatile uint32_t*)0x48000014)
#define LED_PIN           5u

/* SysTick (ARMv6-M) registers */
#define SYST_CSR          (*(volatile uint32_t*)0xE000E010)  /* CTRL */
#define SYST_RVR          (*(volatile uint32_t*)0xE000E014)  /* LOAD */
#define SYST_CVR          (*(volatile uint32_t*)0xE000E018)  /* VAL  */

#define SYST_CSR_ENABLE   (1u << 0)
#define SYST_CSR_TICKINT  (1u << 1)          /* we will NOT set this */
#define SYST_CSR_CLKSRC   (1u << 2)          /* 0: ext, 1: core */
#define SYST_CSR_COUNTFLAG (1u << 16)

/* Assume 8 MHz core clock in Renode F0 model */
#define CORE_HZ 8000000u

static void systick_init_1ms(void)
{
    SYST_RVR = (CORE_HZ / 1000u) - 1u;  /* 1 ms */
    SYST_CVR = 0u;
    /* Enable counter, core clock, NO interrupt */
    SYST_CSR = SYST_CSR_ENABLE | SYST_CSR_CLKSRC;
}

/* Delay that polls COUNTFLAG; with a watchdog fallback so it never hangs */
static void delay_ms(uint32_t ms)
{
    for (uint32_t m = 0; m < ms; ++m) {
        /* Wait for one wrap; COUNTFLAG sets to 1 when it wraps.
           Reading SYST_CSR returns it; it will set again on next wrap. */
        uint32_t guard = CORE_HZ / 50u;     /* ~20 ms guard at 8 MHz */
        while ((SYST_CSR & SYST_CSR_COUNTFLAG) == 0u) {
            if (guard-- == 0u) {
                /* Fallback: simple busy loop ~1 ms at 8 MHz (coarse) */
                for (volatile uint32_t i = 0; i < 8000u; ++i) { __asm volatile("nop"); }
                break;
            }
        }
    }
}

int main(void)
{
    /* Enable GPIOA clock */
    RCC_AHBENR |= RCC_AHBENR_IOPAEN;

    /* Configure PA5 as output (MODER5 = 01) */
    uint32_t moder = GPIOA_MODER;
    moder &= ~(3u << (LED_PIN * 2));
    moder |=  (1u << (LED_PIN * 2));
    GPIOA_MODER = moder;

    systick_init_1ms();

    for (;;) {
        GPIOA_ODR ^= (1u << LED_PIN);  /* toggle */
        delay_ms(500);                 /* ~500 ms */
    }
}
