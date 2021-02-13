
        .syntax unified
        .cpu cortex-m4
        .thumb
        
        .global vtable
        .global reset_handler

        .section .text

        @ Register addresses 
        .equ FLASH_ACR,   0x40023c00      @ FLASH Access Control Register
        .equ RCC_CR,      0x40023800      @ Clock Control Register
        .equ RCC_CFGR,    0x40023808      @ Clock Configuration Register        
        .equ RCC_PLLCFGR, 0x40023804      @ PLL Configuration Register

        .equ RCC_AHB1ENR, 0x40023830      @ AHB1 Peripheral Clock Enable Register

        .equ GPIOA_MODER, 0x40020000      @ PA Mode Register
        .equ GPIOA_OUT,   0x40020014      @ PA Output Data Register
        .equ GPIOC_MODER, 0x40020800      @ PC Mode Register
        .equ GPIOC_AFRH,  0x40020824      @ GPIOC Alternate function register (high)

        @ Bits and Masks 
        .equ RCC_PLLCFGR_RESET_KEEP_MASK, 0xF0BC8000     @ Bits that should be kept at reset value 

        .equ RCC_CR_PLL_ENABLE_BIT, 0x01000000     @ PLL enable bit
        .equ RCC_CR_PLL_RDY_BIT,    0x02000000     @ PLL rdy bit

        .equ RCC_CR_HSE_ON_BIT,     0x00010000     @ HSE_ON bit
        .equ RCC_CR_HSE_RDY_BIT,    0x00020000     @ HSE_RDY flag

        @ Constants
        .equ DELAY_LOOP_ITERATIONS, 20000000
	
        
vtable:
        .word _estack
        .word reset_handler
        .word 0
        .word hard_fault_handler


        .thumb_func
delay:
        ldr r0,=DELAY_LOOP_ITERATIONS
delay_loop:     
        cmp r0, 0
        beq delay_done
        sub r0,r0, 1
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
                
        ldr r0, =_dstart        @ Address to copy to
        ldr r1, =_dend

        sub r2,r1,r0
        cmp r2, 0
        beq reset_continue 

        ldr r1, =_flash_dstart  @ Address to copy from
        
cpy_loop:
        ldrb r3, [r1]
        strb r3, [r0] 

        add r1, r1, 1
        add r0, r0, 1
        
        sub r2, r2, 1
        cmp r2, 0
        bne cpy_loop


reset_continue: 
        @ Try some clock stuff

        ldr r0, =FLASH_ACR     
        ldr r1, [r0]            @ should be zeroes after reset
        ldr r2, =0x705
        orr r1, r1, r2          @ 5 wait states
        str r1, [r0]

        @ RCC_CFGR
        ldr r0, =RCC_CFGR 
        mov r1, 0
        mov r2, 0x7             @ Divide by 5
        lsl r2, r2, 27          @ MCO2
        orr r1, r1, r2         

        mov r2, 0x5             @ PPRE1 (DIV 4)
        lsl r2, 10
        orr r1, r1, r2

        mov r2, 0x4             @ PPRE0 (DIV 2)
        lsl r2, 13
        orr r1, r1, r2

        str r1, [r0]            
        
        @ RCC_CR ** TURN on HSE 
        ldr r0, =RCC_CR
        ldr r1, [r0]
        
        ldr r2, =RCC_CR_HSE_ON_BIT
        orr r1, r1, r2
        str r1, [r0]

        @ Wait for HSE_RDY to be set 
        ldr r2, =RCC_CR_HSE_RDY_BIT
wait_hse_rdy:
        ldr r1, [r0]            @ poll RCC_RC
        and r1, r1, r2
        cmp r1, r2              
        bne wait_hse_rdy        @ loop if not rdy


        @ PLLCFGR 
        ldr r0, =RCC_PLLCFGR
        ldr r1, [r0]

        ldr r2, =RCC_PLLCFGR_RESET_KEEP_MASK
        and r1, r1, r2          @ Clear everything else
        
        mov r2, 336             @ multiplication factor
        lsl r2, r2, 6           @ PLLN 
        orr r1, r1, r2
        
        mov r2, 8               @ division on input (PLLM)
        orr r1, r1, r2          

        mov r2, 7               @ Division factor usb 
        lsl r2, r2, 24          @ PLLQ
        orr r1, r1, r2

        @ PLLP  (set to 00 gives div by 2)
        @ldr r2, =0xFFFCFFFF
        @and r1, r1, r2
        
        mov r2, 1
        lsl r2, r2, 22          @ HSE source for pll
        orr r1, r1, r2

        str r1, [r0]                    

        ldr r0, =RCC_CR
        ldr r1, [r0]

        ldr r2, =RCC_CR_PLL_ENABLE_BIT
        orr r1, r1, r2
        str r1, [r0]

        @ Wait for PLL_RDY flag to be set
        ldr r2, =RCC_CR_PLL_RDY_BIT
wait_pll_rdy:
        ldr r1, [r0]
        and r1, r1, r2
        cmp r1, r2
        bne wait_pll_rdy

        @ Set PLL as source for sysclk  
        ldr r0, =RCC_CFGR
        ldr r1, [r0]
        orr r1, r1, 0x2         @ PLL as source for SYSCLK
        str r1, [r0]

        @ Wait for sw flags to indicate PLL is used for SYSCLK
wait_use_pll:
        ldr r1, [r0]
        and r1, r1, 0xC         @ System clock switch status bits
        cmp r1, 0x8             @ Is PLL used as SYSCLK?
        bne wait_use_pll
                

main:
        ldr r1, =RCC_AHB1ENR
        ldr r0, [r1]
        orr r0, 0x1             @ Turn on GPIO A
        orr r0, 0x4             @ Turn on GPIO C
        str r0, [r1]            @ Make it happen

        
        ldr r0, =GPIOC_MODER    @ PC9 alternative function mode
        ldr r1, [r0]
        ldr r2, =0xFFF3FFFF
        and r1, r1, r2
        mov r2, 2
        lsl r2, 18
        orr r1, r1 ,r2
        str r1, [r0]

        ldr r0, =GPIOC_AFRH     @ PC9 alternative function 0
        ldr r1, [r0]
        ldr r2, =0xFFFFFFF0F
        and r1, r1, r2
        str r1, [r0]
        
        ldr r1, =GPIOA_MODER
        ldr r0, [r1]            @ Value of PA MODER
        ldr r2, =0xFFFFFF00
        and r0, r0, r2
        orr r0, r0, 0x55        @ PA0 - PA 3 output, 
        str r0, [r1]            @ Write back PA MODER   
                

        ldr r3,=GPIOA_OUT
        ldr r5,=0xFFFFFF00      @ Clear-mask for bits of interest

        mov r1, 0xF
        mov r2, 0x0
forever:
        bl delay                        
        str r2, [r3]
        bl delay                
        str r1, [r3]
        b forever

