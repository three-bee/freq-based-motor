			AREA 	routines, CODE, READONLY
			THUMB
			
			;updateScreen.s
			;Updates values shown on LCD (frequency and magnitude) with the given string address.
			;Inputs: R10 (string address)
			;		  R9 (LCD-related register)
			;		  R7 (max freq magnitude)
			;		  R8 (max freq response index, between 1-511)
			
			IMPORT  convertASCII
			IMPORT	LCDSendData
			IMPORT	LCDSendString
			EXPORT	updateScreen
updateScreen	PROC	
			PUSH	{R0-R2, LR}
			
			;Clear relevant regions of the screen
			;MAGNITUDE
			MOV		R9,#0x99		;Starting point of X
			BL		LCDSendData
			MOV		R9,#0x40		;Y=0
			BL		LCDSendData
			MOV		R9,#0x100		;Clear screen
			
			MOV		R0,#58
clearY0		BL		LCDSendData
			SUBS	R0,#1
			BNE		clearY0
			
			MOV		R9,#0xBF		;Starting point of X
			BL		LCDSendData
			MOV		R9,#0x41		;Y=1
			BL		LCDSendData
			MOV		R9,#0x100		;Clear screen
			MOV		R0,#15
clearY1		BL		LCDSendData
			SUBS	R0,#1
			BNE		clearY1
			
			;Write to relevant regions of the screen
			;MAGNITUDE
			MOV		R9,#0x99		;Starting point of X
			BL		LCDSendData
			MOV		R9,#0x40		;Y=0
			BL		LCDSendData
			
			MOV		R0,R7
			BL		convertASCII
			MOV		R0,R10
			BL		LCDSendString
			
			;FREQUENCY
			MOV		R9,#0xBF		;Starting point of X
			BL		LCDSendData
			MOV		R9,#0x41		;Y=1
			BL		LCDSendData
			
			MOV		R0,R8
			BL		convertASCII
			MOV		R0,R10
			BL		LCDSendString
			
			POP		{R0-R2, LR}
			BX		LR
			ENDP
			ALIGN
			END