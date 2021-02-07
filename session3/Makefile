

all: session3.hex

session3.o: session3.s
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb session3.s -o session3.o

session3.elf: session3.o session3.ld
	arm-none-eabi-ld -T ./session3.ld  session3.o -o session3.elf

session3.hex: session3.elf
	arm-none-eabi-objcopy -O ihex session3.elf session3.hex

clean:
	rm *.hex
	rm *.o
	rm *.elf

flash: session3.hex
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "init" -c "program session3.hex verify reset exit"

debug:
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg


disas: session3.elf
	arm-none-eabi-objdump -s -d session3.elf
