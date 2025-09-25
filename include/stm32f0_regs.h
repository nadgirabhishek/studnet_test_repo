#pragma once
#include <stdint.h>

#define PERIPH_BASE        0x40000000UL
#define AHBPERIPH_BASE     (PERIPH_BASE + 0x00020000UL)
#define GPIOA_BASE         (0x48000000UL)            // STM32F0 GPIOA
#define RCC_BASE           (0x40021000UL)            // STM32F0 RCC
#define SYSTICK_BASE       (0xE000E010UL)            // SysTick

typedef struct { volatile uint32_t MODER; volatile uint32_t OTYPER; volatile uint32_t OSPEEDR;
                 volatile uint32_t PUPDR; volatile uint32_t IDR;    volatile uint32_t ODR;
                 volatile uint32_t BSRR; volatile uint32_t LCKR;    volatile uint32_t AFR[2];
                 volatile uint32_t BRR; } GPIO_TypeDef;

typedef struct { volatile uint32_t CR; volatile uint32_t CFGR; volatile uint32_t CIR;
                 volatile uint32_t APB2RSTR; volatile uint32_t APB1RSTR; volatile uint32_t AHBENR;
                 volatile uint32_t APB2ENR; volatile uint32_t APB1ENR; volatile uint32_t BDCR;
                 volatile uint32_t CSR; volatile uint32_t AHBRSTR; volatile uint32_t CFGR2;
                 volatile uint32_t CFGR3; volatile uint32_t CR2; } RCC_TypeDef;

typedef struct { volatile uint32_t CTRL; volatile uint32_t LOAD; volatile uint32_t VAL; volatile uint32_t CALIB; } SYST_TypeDef;

#define GPIOA              ((GPIO_TypeDef*) GPIOA_BASE)
#define RCC                ((RCC_TypeDef*)  RCC_BASE)
#define SYST               ((SYST_TypeDef*) SYSTICK_BASE)

/* RCC_AHBENR bits for GPIO */
#define RCC_AHBENR_IOPAEN  (1u << 17)

/* SysTick CTRL bits */
#define SYST_CTRL_ENABLE   (1u << 0)
#define SYST_CTRL_TICKINT  (1u << 1)
#define SYST_CTRL_CLKSRC   (1u << 2)
