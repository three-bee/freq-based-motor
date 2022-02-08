PORTF_DATA_LED		EQU		0x40025038 ; Data register for only PF1-PF3
;**************************
			AREA 	routines, CODE, READONLY
			THUMB
				
			;updateLED.s
			;Inputs:  R7 (max freq magnitude)
			;		  R8 (max frequency value (7-992))
			
			EXPORT	updateLED
updateLED	PROC
			PUSH	{R1-R2}
			
			LDR		R1,=PORTF_DATA_LED
			LDR		R2,[R1]
			
			CMP		R7,#1000	;Magnitude threshold, empirical value
			MOVLO	R2,#0x00
			BLO		exit
			
			CMP		R8,#256		;~256Hz
			MOVLO	R2,#0x02	;red
			BLO		exit
			
			CMP		R8,#768		;~768Hz
			MOVLO	R2,#0x08	;green
			BLO		exit
			MOV		R2,#0x04	;blue
			
exit		STR		R2,[R1]
			POP		{R1-R2}
			BX		LR
			ENDP
			ALIGN
			END