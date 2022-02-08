SSI0_DR			EQU		0x40008008 ; SSI data register
SSI0_SR			EQU		0x4000800C ; SSI status register
PORTA_DATA_DC	EQU		0x40004100 ; Data register for only PA6 (DC)
;**************************
			AREA 	routines, CODE, READONLY
			THUMB
			
			;LCDSendData.s
			;Writes the data in R9 inside SSI0_DR, when SSI is available.
			;Inputs: R9 (LCD-related register)
			
			EXPORT	LCDSendData
LCDSendData	PROC	
			PUSH	{R0-R2}
			
			LDR		R1,=SSI0_SR	   ; Poll SR until BSY=0
poll		LDR		R0,[R1]
			BIC		R0,#0x0F
			CMP		R0,#0x10
			BEQ		poll
			
			LDR		R1,=PORTA_DATA_DC
			LDR		R0,[R1]
			MOV		R0,#0	   		;Clear PA6 (D/C)
			
			MOV		R0,R9			;Then, set PA6 according to R9[8]
			LSR		R0,#2			
			STR		R0,[R1]		
						
			LDR		R1,=SSI0_DR		;Write the data of R9[3:0] to SSI_DR 
			LDR		R0,[R1]
			MOV		R0,R9
			BIC		R0,#0xF00
			STR		R0,[R1]
			
			POP		{R0-R2}
			BX		LR
			ENDP
			ALIGN
			END