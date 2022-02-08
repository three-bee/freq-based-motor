RCGCGPIO		EQU		0x400FE608
PORTB_DATA		EQU		0x400053FC
PORTB_DIR		EQU		0x40005400
PORTB_AFSEL		EQU		0x40005420
PORTB_DEN		EQU		0x4000551C
PORTB_PUR		EQU		0x40005510
PORTB_PDR		EQU		0x40005514
;**************************

			AREA 	routines, CODE, READONLY
			THUMB
				
			EXPORT	init_PB_motor
init_PB_motor	PROC
			
			LDR		R1,=RCGCGPIO
			LDR		R0,[R1]
			ORR		R0,R0,#0x02	;Enable Port B CLK
			STR		R0,[R1]
			NOP
			NOP
			NOP
			
			LDR		R1,=PORTB_DIR
			LDR		R0,[R1]
			ORR		R0,#0x0F	;PB0-3 are outputs
			STR		R0,[R1]
			
			LDR		R1,=PORTB_AFSEL
			LDR 	R0,[R1]
			BIC		R0,#0xFF	;No alternating func
			STR		R0,[R1]
			
			LDR		R1,=PORTB_DEN
			LDR		R0,[R1]
			ORR		R0,#0xFF	;All digital
			STR		R0,[R1]
			
			BX		LR
			ENDP
			ALIGN
			END