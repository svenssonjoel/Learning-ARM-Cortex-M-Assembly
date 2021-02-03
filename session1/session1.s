
	.syntax unified
	.cpu cortex-m4
	.thumb
	
	.global vtable
	.global reset_handler

	.section .text
	
vtable:
	.word _estack
	.word reset_handler
	.word 0
	.word hard_fault_handler

@.thumb_func	
hard_fault_handler:
	b hard_fault_handler

@.thumb_func	
reset_handler:
	ldr r0, =_estack
	mov sp, r0
		
	ldr r0, =_dstart
	ldr r1, =_dend

	sub r2,r1,r0
	cmp r2, #0
	beq main

	ldr r1, =_flash_dstart
    	
cpy_loop:
	ldrb r3, [r1]
	strb r3, [r0] 

	add r1, r1, #1
	add r0, r0, #1
	
	sub r2, r2, #1
	cmp r2, #0
	bne cpy_loop
	

main:
	ldr r1, =0x40023830
	ldr r0, [r1]
	orr r0, 0x1
	str r0, [r1]
	
	ldr r1, =0x40020000     @ Pointer to PA MODER
	ldr r0, [r1]            @ Value of PA MODER

	orr r0, r0, 0x55        @ PA0 - PA 3 output set 
        str r0, [r1]            @ Write back PA MODER

	ldr r1, =0x40020014     @ PA output data register
	ldr r0, [r1]
	orr r0, r0, 0xF         @ Set all PA0 - PA3 to 1
	str r0, [r1]            @ Write back data reister
	
	
	
done:	
	b done

	.section .data 
