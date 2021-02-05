

all: session2.hex

session2.o: session2.s
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb session2.s -o session2.o

session2.elf: session2.o session2.ld
	arm-none-eabi-ld -T ./session2.ld  session2.o -o session2.elf

session2.hex: session2.elf
	arm-none-eabi-objcopy -O ihex session2.elf session2.hex

clean:
	rm *.hex
	rm *.o
	rm *.elf

flash: session2.hex
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "init" -c "program session2.hex verify reset exit"

debug:
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg


disas: session2.elf
	arm-none-eabi-objdump -s -d session2.elf
