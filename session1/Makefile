

all: session1.hex

session1.o: session1.s
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb session1.s -o session1.o

session1.elf: session1.o session1.ld
	arm-none-eabi-ld -T ./session1.ld  session1.o -o session1.elf

session1.hex: session1.elf
	arm-none-eabi-objcopy -O ihex session1.elf session1.hex

clean:
	rm *.hex
	rm *.o
	rm *.elf

flash: session1.hex
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "init" -c "program session1.hex verify reset exit"

debug:
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg


disas: session1.elf
	arm-none-eabi-objdump -s -d session1.elf
