

all: session4.hex

session4.o: session4.s
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb session4.s -o session4.o

session4.elf: session4.o session4.ld
	arm-none-eabi-ld -T ./session4.ld  session4.o -o session4.elf

session4.hex: session4.elf
	arm-none-eabi-objcopy -O ihex session4.elf session4.hex

clean:
	rm *.hex
	rm *.o
	rm *.elf

flash: session4.hex
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "init" -c "program session4.hex verify reset exit"

debug:
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg


disas: session4.elf
	arm-none-eabi-objdump -s -d session4.elf
