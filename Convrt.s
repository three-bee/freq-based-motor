;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA		routines, READONLY, CODE
			THUMB
			EXPORT		convertASCII
						
			;convertASCII: Converts a number NUM into its ASCII chars, and
			;writes them into memory, starting from [N_ADDR]
			
			;INPUTS: R0=NUM, R10=N_ADDR
			;NUM: Number to be converted.
			;N_ADDR: Starting location of the ASCII chars of the number to be converted.

convertASCII	PROC
			
			PUSH		{R1-R3, R10, LR}
			MOV			R3,#10		;R3=10 
			MOV			R1,#0		;R1=M
			
decompose	UDIV		R2,R0,R3	;R2(temp) = int division of NUMBER by 10
			MUL			R2,R3		;R2 = R2*10
			SUB			R2,R0,R2	;R2 = NUMBER-R2 = LSD of NUMBER
			ADD			R2,#0x30	;0x30=0 in ASCII. 0x31=1, etc...
			PUSH		{R2}
			UDIV		R0,R3		;NUMBER/=10
			ADD			R1,#1		;At each division M++
			CMP			R0,#0		;if NUMBER==0, stop
			BNE			decompose

reorder		POP			{R2}
			STRB		R2,[R10],#1	;Store digits to N_ADDR and following addresses
			SUBS		R1,#1		;Until M==0, pop from stack to reorder the digits
			MOVEQ		R2,#0x04	;When M==0, place 0x04 char
			STRBEQ		R2,[R10]
			BNE			reorder
			
			POP			{R1-R3, R10, LR}
			BX			LR
			
			ENDP
			ALIGN
			END