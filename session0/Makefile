
all: session0.hex

session0.o: session0.s
	arm-none-eabi-as -g -mcpu=cortex-m4 -mthumb session0.s -o session0.o

session0.elf: session0.o session0.ld
	arm-none-eabi-ld session0.o -T ./session0.ld -o session0.elf

session0.hex: session0.elf
	arm-none-eabi-objcopy -O ihex session0.elf session0.hex

clean:
	rm *.hex
	rm *.o
	rm *.elf

flash: session0.hex
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg -c "init" -c "program session0.hex verify reset exit"

debug:
	openocd -f interface/stlink.cfg -f target/stm32f4x.cfg


disas: session0.elf
	arm-none-eabi-objdump -s -d session0.elf
