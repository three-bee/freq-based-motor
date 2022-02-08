			AREA	char_table, DATA, READONLY, ALIGN=2
FREQ		DCB		"FREQ (HZ)  : "
			DCB		0x04	;end of transmission

MAG			DCB		"MAG: "
			DCB		0x04

BREAK		DCB		"==========="
			DCB		0x04
			
T_FREQ_L	DCB		"FREQ_LO(HZ): 256"
			DCB		0x04
			
T_FREQ_H	DCB		"FREQ_HI(HZ): 768"
			DCB		0x04			

T_MAG		DCB		"MAG_THRESH :1000"
			DCB		0x04
;**************************
;GPIO_PORTA Registers
RCGCGPIO		EQU 	0x400FE608 ; GPIO clock register
PORTA_DEN	    EQU 	0x4000451C ; Digital Enable
PORTA_PCTL 		EQU 	0x4000452C ; Alternate function select
PORTA_AFSEL 	EQU 	0x40004420 ; Enable Alt functions
PORTA_AMSEL 	EQU 	0x40004528 ; Enable analog
PORTA_DATA		EQU		0x400043FC ; Data register
PORTA_DIR		EQU		0x40004400 ; Direction register
PORTA_PUR		EQU		0x40004510 ; Pull up register

;SSI0 Registers
RCGCSSI			EQU		0x400FE61C ; SSI clock register
SSI0_CR0		EQU		0x40008000 ; SSI control 0
SSI0_CR1		EQU		0x40008004 ; SSI control 1
SSI0_CPSR		EQU		0x40008010 ; SSI clock prescale
SSI0_CC			EQU		0x40008FC8 ; SSI clock configuration
;**************************
			AREA 	routines, CODE, READONLY
			THUMB

			IMPORT	LCDSendString
			IMPORT 	LCDSendData
			EXPORT	init_PA_lcd
init_PA_lcd	PROC	
			PUSH	{R0-R2,LR}
			
			LDR		R1,=RCGCGPIO
			LDR		R0,[R1]
			ORR		R0,R0,#0x01 	;Enable CLK on A
			STR		R0,[R1]
			
			LDR		R1,=RCGCSSI
			LDR		R0,[R1]
			ORR		R0,R0,#0x01		;Enable CLK on SSI0
			STR		R0,[R1]
			NOP
			NOP
			NOP
			
			LDR		R1,=PORTA_DIR
			LDR		R0,[R1]
			ORR		R0,#0xC0		;A6,A7 outputs
			STR		R0,[R1]
			
			LDR		R1,=PORTA_DEN
			LDR		R0,[R1]
			ORR		R0,#0xFF		;All digital
			STR		R0,[R1]
			
			LDR		R1,=PORTA_AFSEL
			LDR 	R0,[R1]
			ORR		R0,#0x2C		;A2,A3,A5 alternating func
			STR		R0,[R1]
		
			LDR		R1,=PORTA_PCTL
			LDR		R0,[R1]
			MOV		R0,#0x2022
			LSL		R0,#8			;#0x00202200	,SSI alt functions for A2,A3,A5
			STR		R0,[R1]
			
			LDR		R1,=PORTA_PUR
			LDR		R0,[R1]
			ORR		R0,#0x04		;Set CLK pin of LCD (PA2) as PUR due to steady state low in CR0
			STR		R0,[R1]
			
			;**************************
			
			LDR		R1,=SSI0_CR1
			LDR		R0,[R1]
			BIC		R0,#0x02		;Disable serial port
			STR		R0,[R1]
			BIC		R0,#0x04		;After SSE=0, select as master
			STR		R0,[R1]
			
			;Configure SSI0Clk to 2.6667 MHz = 16 MHz/(2*(1+2))
			;BR = SYSCLK / (CSDVSR * (1+SCR))
			LDR		R1,=SSI0_CC
			LDR		R0,[R1]
			MOV		R0,#0x00		;Use system clk, 16MHz
			STR		R0,[R1]
			
			LDR		R1,=SSI0_CPSR
			LDR		R0,[R1]
			MOV		R0,#2			;Divide clock by prescaling
			STR		R0,[R1]
			
			LDR		R1,=SSI0_CR0
			LDR		R0,[R1]
			MOV		R0,#0x207		;SCR=2 for prescaling
									;1st edge transition (rising), steady state low, freescale SPI frame
									;8-bit data
			STR		R0,[R1]
			
			LDR		R1,=SSI0_CR1
			LDR		R0,[R1]
			ORR		R0,#0x02		;Enable serial port
			STR		R0,[R1]
						
			LDR		R1,=PORTA_DATA
			LDR		R0,[R1]
			BIC		R0,#0x80		;RST pin PA7 to LOW
			STR		R0,[R1]
			
			MOV32	R2,#600000		;Delay
loop		SUBS	R2,#1
			BNE		loop			
			
			ORR		R0,#0x80		;RST pin PA7 to HIGH
			STR		R0,[R1]
			
			;**************************
			
			MOV		R9,#0x21		;Enable chip (PD=0), Horizontal addressing (V=0), Extended instructions (H=1)	
			BL		LCDSendData
			
			MOV		R9,#0xBF		;VOP
			BL		LCDSendData
			
			MOV		R9,#0x06		;Temperature control
			BL		LCDSendData
			
			MOV		R9,#0x13		;Voltage bias
			BL		LCDSendData
			
			;**************************

			MOV		R9,#0x20		;H=0 for basic command mode
			BL		LCDSendData
			
			MOV		R9,#0x0C		;Normal display mode
			BL		LCDSendData
			
			MOV		R9,#0x80		;Reset X position
			BL		LCDSendData
			MOV		R9,#0x40		;Reset Y position
			BL		LCDSendData
			
			MOV		R9,#0x100		;Clear screen
			MOV		R0,#504
clear		BL		LCDSendData
			SUBS	R0,#1
			BNE		clear
			;************
			MOV		R9,#0x80		;Reset X position
			BL		LCDSendData
			MOV		R9,#0x40		;Y=0
			BL		LCDSendData
			
			LDR		R0,=MAG
			BL		LCDSendString
			;************
			MOV		R9,#0x80		;Reset X position
			BL		LCDSendData
			MOV		R9,#0x41		;Y=1
			BL		LCDSendData
			
			LDR		R0,=FREQ
			BL		LCDSendString
			;************
			MOV		R9,#0x80		;Reset X position
			BL		LCDSendData
			MOV		R9,#0x42		;Y=2
			BL		LCDSendData
			
			LDR		R0,=BREAK
			BL		LCDSendString
			;************
			MOV		R9,#0x80		;Reset X position
			BL		LCDSendData
			MOV		R9,#0x43		;Y=3
			BL		LCDSendData
			
			LDR		R0,=T_FREQ_L
			BL		LCDSendString
			;************
			MOV		R9,#0x80		;Reset X position
			BL		LCDSendData
			MOV		R9,#0x44		;Y=4
			BL		LCDSendData
			
			LDR		R0,=T_FREQ_H
			BL		LCDSendString
			;************
			MOV		R9,#0x80		;Reset X position
			BL		LCDSendData
			MOV		R9,#0x45		;Y=5
			BL		LCDSendData
			
			LDR		R0,=T_MAG
			BL		LCDSendString
			;************
			
			POP		{R0-R2,LR}
			BX 		LR
			ENDP
			ALIGN
			END