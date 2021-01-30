
	.syntax unified

	.text 
	
	.global vtable
	.global reset_handler

vtable:
	.word _estack
	.word reset_handler
	.size vtable, .-vtable

reset_handler:
	ldr r0, =_estack
	mov sp, r0

	ldr r0, =_dstart
	ldr r0, [r0]

	ldr r1, =_dend
	ldr r1, [r1]

	sub r2,r1,r0

	ldr r1, =_flash_dstart
	
cpy_loop:
	ldrb r3, [r1]
	strb r3, [r0] 

	add r1, r1, #1
	add r2, r2, #1
	
	sub r2, r2, #1
	bne cpy_loop
	

main:	
	ldr r7, =0xF00DF00D
	ldr r8, =0x1337BEEF
	ldr r9, =apa
	ldr r9, [r9]
done:	
	b done

	.data 

apa:	.word 0xFEEBDAED
