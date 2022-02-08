;SysTick Counter Initialization
NVIC_ST_CTRL		EQU		0xE000E010
NVIC_ST_RELOAD		EQU		0xE000E014
NVIC_ST_CURRENT		EQU		0xE000E018
SHP_SYSPRI3			EQU		0xE000ED20
RELOAD_VALUE		EQU		1999
	
;ADC is checked in SysTick_Handler
ADC0_RIS 			EQU 	0x40038004 ; Interrupt status
ADC0_SSFIFO3 		EQU 	0x400380A8 ; Channel 3 results
ADC0_ISC			EQU		0x4003800C ; Interrupt status clear
ADC0_PSSI 			EQU 	0x40038028 ; Initiate sample
;**************************
			AREA 	routines, CODE, READONLY
			THUMB

			EXPORT	init_SysTick
init_SysTick	PROC	
			
			;ENABLE=0
			;INTEN=0   (interrupt disabled)
			;CLK_SRC=0 (PIOSC/4)
			LDR		R1,=NVIC_ST_CTRL
			MOV		R0,#0
			STR		R0,[R1]
			
			;timeout period
			LDR		R1,=NVIC_ST_RELOAD
			LDR		R0,=RELOAD_VALUE
			STR		R0,[R1]
			
			LDR		R1,=NVIC_ST_CURRENT
			STR		R0,[R1]
			
			;set priority of SysTick to 2
			LDR		R1,=SHP_SYSPRI3
			MOV		R0,#0x40000000
			STR		R0,[R1]
			
			;enable system timer
			LDR		R1,=NVIC_ST_CTRL
			MOV		R0,#0x03
			STR		R0,[R1]
				
			BX		LR
			ENDP

;**************************
			;MY_ST_ISR
			;Custom SysTick ISR for getting data from ADC0_SSFIFO3.
			;Updates samplecount variable each time ISR is executed.
			;Counts readings taken from the ADC0_SSFIFO3, then updates samplecount.
			;Output = R5 (samplecount)
			
			EXPORT  MY_ST_ISR
MY_ST_ISR	PROC
			
			; check for sample complete (bit 3 of ADC0_RIS set)
poll		LDR 	R1,=ADC0_RIS ; interrupt address
			LDR 	R0, [R1]
			ANDS 	R0, R0, #8
			BEQ 	poll

			LDR 	R1,=ADC0_SSFIFO3 ;result address
			LDR 	R0, [R1]
			SUB		R0,#1551		;remove 1.25V offset
			
			LDR		R1,=0x20000400
			STRH	R0,[R1,R5]		;store least significant 16 bits of FIFO to [MEM+samplecount], real
			ADD		R5,#2			;samplecount+2
			MOV		R0,#0
			STRH	R0,[R1,R5]		;store 0 to imag
			ADD		R5,#2			;samplecount+2
			
			;Initiate ADC0 SS3 at each fetch from SS3 FIFO
			LDR 	R1,=ADC0_PSSI ; sample sequence initiate address
			LDR 	R0, [R1]
			ORR 	R0, R0, #0x08 ; set bit 3 for SS3
			STR 	R0, [R1]
			
exit		BX		LR
			ENDP
			ALIGN
			END
				