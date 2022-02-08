;GPIO_PORTF Registers
PORTF_LOCK		EQU		0x40025520 ; GPIO Lock
PORTF_CR		EQU		0x40025524 ; GPIO Commit

RCGCGPIO		EQU 	0x400FE608 ; GPIO clock register
PORTF_DEN	    EQU 	0x4002551C ; Digital Enable
PORTF_PCTL 		EQU 	0x4002552C ; Alternate function select
PORTF_AFSEL 	EQU 	0x40025420 ; Enable Alt functions
PORTF_AMSEL 	EQU 	0x40025528 ; Enable analog
PORTF_DATA_BTN	EQU		0x40025044 ; Data register for only P0 & P4
PORTF_DIR		EQU		0x40025400 ; Direction register
PORTF_PUR		EQU		0x40025510 ; Pull up register
	
PORTF_IS		EQU		0x40025404	;Interrupt sense
PORTF_IBE		EQU		0x40025408	;Interrupt both edges
PORTF_IEV		EQU		0x4002540C	;Interrupt event
PORTF_IM		EQU		0x40025410	;Interrupt mask
PORTF_MIS		EQU		0x40025418	;Masked interrupts
PORTF_ICR		EQU		0x4002541C	;Interrupt clear

;Interrupt #30 is Port F interrupts on the interrupt table
NVIC_EN0		EQU		0xE000E100	;IRQ 0 to 31 set enable register
NVIC_PRI7		EQU		0xE000E41C	;Bits 23:21 control the interrupt #30 priority
;**************************
			AREA 	routines, CODE, READONLY
			THUMB

			EXPORT	init_PF_led_button
init_PF_led_button	PROC	
			
			LDR		R1,=RCGCGPIO
			LDR		R0,[R1]
			ORR		R0,R0,#0x20 	;Enable CLK on F
			STR		R0,[R1]
			NOP
			NOP
			NOP
			
			LDR		R1,=PORTF_LOCK
			LDR		R0,=0x4C4F434B	;Unlock port F
			STR		R0,[R1]
			
			LDR		R1,=PORTF_CR
			MOV		R0,#0x1F		;Enable commiting changes in PF0
			STR		R0,[R1]
			
			LDR		R1,=PORTF_DIR
			LDR		R0,[R1]
			ORR		R0,#0x0E		;F1,F2,F3 are outputs (LEDs) F4,F0 are inputs (buttons)
			STR		R0,[R1]
			
			LDR		R1,=PORTF_PUR
			MOV		R0,#0x11		;Pull up resistor to buttons
			STR		R0,[R1]
			
			LDR		R1,=PORTF_AFSEL
			LDR 	R0,[R1]
			BIC		R0,#0xFF		;No alternating func
			STR		R0,[R1]
			
			LDR		R1,=PORTF_DEN
			LDR		R0,[R1]
			ORR		R0,#0xFF		;All digital
			STR		R0,[R1]
			
			LDR		R1,=PORTF_IS
			MOV		R0,#0x00
			STR		R0,[R1]			;Edge sensitive
			
			LDR		R1,=PORTF_IBE
			STR		R0,[R1]			;Controlled by IEV
			
			LDR		R1,=PORTF_IEV
			ORR		R0,#0x00
			STR		R0,[R1]			;Falling edge for buttons (F0,F4)
			
			LDR		R1,=PORTF_IM
			MOV		R0,#0x11
			STR		R0,[R1]			;Only interested in button (F0,F4) interrupts
			
			LDR		R1,=NVIC_PRI7
			LDR		R0,[R1]
			AND		R0,R0,#0xFF0FFFFF ;Bits 23:21 control the interrupt #30 priority
			ORR		R0,R0,#0x00800000 ;Set priority to 3
			STR		R0,[R1]
			
			LDR		R1,=NVIC_EN0
			MOVT	R0,#0x4000		  ;Set bit 30 for Port F priorities. Writing 0 does not disable interrupt
			STR		R0,[R1]
			
			BX		LR
			ENDP
				
;**************************
			;MY_GPIO_F_ISR
			;Custom GPIOPortF_Handler for getting button input & changing LEDs.
			;Input/output = R4 (flag register)
			
			EXPORT  MY_GPIO_F_ISR
MY_GPIO_F_ISR	PROC		

			LDR		R1,=PORTF_DATA_BTN
			LDR		R2,[R1]			;R2 is expected to be 0x10 or 0x01
			CMP		R2,#0x11		;If 0x11, accidental ISR entry due to bouncing, exit
			BEQ		exit
			
pressed		LDR		R0,[R1]
			CMP		R0,#0x11
			BNE		pressed
			
			;R4[0]=1 <- PORTF_DATA_BTN=0x01, SW1 
			;R4[0]=0 <- PORTF_DATA_BTN=0x10, SW2
			CMP		R2,#0x01		
			ORREQ	R4,#0x1
			BICNE	R4,#0x1		

exit		LDR 	R1,=PORTF_MIS	
			LDR		R0,[R1]
			LDR		R1,=PORTF_ICR	;Clear current interrupt to enable further interrupts
			STR		R0,[R1]
			
			BX		LR
			ENDP
			ALIGN
			END