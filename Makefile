TARGET=firmware
CC=arm-none-eabi-gcc
CFLAGS=-mcpu=cortex-m0 -mthumb -O2 -ffunction-sections -fdata-sections -Iinclude -Wall -Wextra
LDFLAGS=-T stm32f0.ld -nostdlib -Wl,--gc-sections
OBJS=startup_stm32f0.o src/main.o

all: $(TARGET).elf

$(TARGET).elf: $(OBJS) stm32f0.ld
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)

startup_stm32f0.o: startup_stm32f0.s
	$(CC) $(CFLAGS) -c $< -o $@

src/main.o: src/main.c include/stm32f0_regs.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET).elf $(OBJS)

.PHONY: all clean
