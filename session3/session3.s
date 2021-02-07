
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


        .thumb_func
delay:
        ldr r0,=1000000
delay_loop:     
        cmp r0, #0
        beq delay_done
        sub r0,r0, #1
        b delay_loop
delay_done:     
        bx lr
        
        .thumb_func     
hard_fault_handler:
        b hard_fault_handler

        .thumb_func     
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
        ldr r1, =0x40023830     @ AHB1ENR
        ldr r0, [r1]
        orr r0, 0x1             @ Turn on GPIO A        
        str r0, [r1]

        ldr r1, =0x40020000     @ Pointer to PA MODER
        ldr r0, [r1]            @ Value of PA MODER
        ldr r2, =0xFFFFFF00
        and r0, r0, r2
        orr r0, r0, 0x55        @ PA0 - PA 3 output, 
        str r0, [r1]            @ Write back PA MODER   
                

        
        ldr r2,=led_states      @ Load led_states array address
        ldr r6,=led_states_end  @ Load led_states array end address
        ldr r3,=0x40020014      @ PA output data register
        ldr r5,=0xFFFFFF00      @ Clear-mask for bits of interest
forever:
        ldrb r1, [r2], #1       @ Load a byte from array and increment address
        ldr r4, [r3]            @ Load state of PA output data register
        and r4, r4, r5          @ Clear some bits
        orr r4, r4, r1          @ Turn some bits on based on led_states value
        str r4, [r3]            @ Write to PA output data register

        cmp r2, r6              @ Did we reach end of array?
        blt forever_cont
        ldr r2,=led_states      @ Reset r2 to start of led_states
forever_cont:    
        
        bl delay
        b forever

        .section .data 

led_states:     .byte 0x1, 0x2, 0x4, 0x8, 0xF, 0x0
        @ led_states could have been stored in flash as it is constant. 
led_states_end: 
