			AREA	char_table, DATA, READONLY, ALIGN=2
CHARS		DCB		0x00, 0x00, 0x00, 0x00, 0x00 ; 20 SPACE  
			DCB		0x00, 0x00, 0x5f, 0x00, 0x00 ; 21 !
			DCB 	0x00, 0x07, 0x00, 0x07, 0x00 ; 22 "
			DCB		0x14, 0x7f, 0x14, 0x7f, 0x14 ; 23 #
			DCB		0x24, 0x2a, 0x7f, 0x2a, 0x12 ; 24 $
			DCB		0x23, 0x13, 0x08, 0x64, 0x62 ; 25 %
			DCB		0x36, 0x49, 0x55, 0x22, 0x50 ; 26 &
			DCB		0x00, 0x05, 0x03, 0x00, 0x00 ; 27 '
			DCB		0x00, 0x1c, 0x22, 0x41, 0x00 ; 28 (
			DCB 	0x00, 0x41, 0x22, 0x1c, 0x00 ; 29 )
			DCB		0x14, 0x08, 0x3e, 0x08, 0x14 ; 2a *
			DCB		0x08, 0x08, 0x3e, 0x08, 0x08 ; 2b +
			DCB		0x00, 0x50, 0x30, 0x00, 0x00 ; 2c ,
			DCB		0x08, 0x08, 0x08, 0x08, 0x08 ; 2d -
			DCB		0x00, 0x60, 0x60, 0x00, 0x00 ; 2e .
			DCB		0x20, 0x10, 0x08, 0x04, 0x02 ; 2f /
			DCB		0x3e, 0x51, 0x49, 0x45, 0x3e ; 30 0
			DCB		0x00, 0x42, 0x7f, 0x40, 0x00 ; 31 1
			DCB		0x42, 0x61, 0x51, 0x49, 0x46 ; 32 2
			DCB		0x21, 0x41, 0x45, 0x4b, 0x31 ; 33 3
			DCB		0x18, 0x14, 0x12, 0x7f, 0x10 ; 34 4
			DCB		0x27, 0x45, 0x45, 0x45, 0x39 ; 35 5
			DCB		0x3c, 0x4a, 0x49, 0x49, 0x30 ; 36 6
			DCB		0x01, 0x71, 0x09, 0x05, 0x03 ; 37 7
			DCB		0x36, 0x49, 0x49, 0x49, 0x36 ; 38 8
			DCB		0x06, 0x49, 0x49, 0x29, 0x1e ; 39 9
			DCB		0x00, 0x36, 0x36, 0x00, 0x00 ; 3a :
			DCB		0x00, 0x56, 0x36, 0x00, 0x00 ; 3b ;
			DCB		0x08, 0x14, 0x22, 0x41, 0x00 ; 3c <
			DCB		0x14, 0x14, 0x14, 0x14, 0x14 ; 3d =
			DCB		0x00, 0x41, 0x22, 0x14, 0x08 ; 3e >
			DCB		0x02, 0x01, 0x51, 0x09, 0x06 ; 3f ?
			DCB		0x32, 0x49, 0x79, 0x41, 0x3e ; 40 @
			DCB		0x7e, 0x11, 0x11, 0x11, 0x7e ; 41 A
			DCB		0x7f, 0x49, 0x49, 0x49, 0x36 ; 42 B
			DCB	 	0x3e, 0x41, 0x41, 0x41, 0x22 ; 43 C
			DCB 	0x7f, 0x41, 0x41, 0x22, 0x1c ; 44 D
			DCB 	0x7f, 0x49, 0x49, 0x49, 0x41 ; 45 E
			DCB		0x7f, 0x09, 0x09, 0x09, 0x01 ; 46 F
			DCB		0x3e, 0x41, 0x49, 0x49, 0x7a ; 47 G
			DCB		0x7f, 0x08, 0x08, 0x08, 0x7f ; 48 H
			DCB		0x00, 0x41, 0x7f, 0x41, 0x00 ; 49 I
			DCB		0x20, 0x40, 0x41, 0x3f, 0x01 ; 4a J
			DCB		0x7f, 0x08, 0x14, 0x22, 0x41 ; 4b K
			DCB		0x7f, 0x40, 0x40, 0x40, 0x40 ; 4c L
			DCB		0x7f, 0x02, 0x0c, 0x02, 0x7f ; 4d M
			DCB		0x7f, 0x04, 0x08, 0x10, 0x7f ; 4e N
			DCB		0x3e, 0x41, 0x41, 0x41, 0x3e ; 4f O
			DCB		0x7f, 0x09, 0x09, 0x09, 0x06 ; 50 P
			DCB		0x3e, 0x41, 0x51, 0x21, 0x5e ; 51 Q
			DCB		0x7f, 0x09, 0x19, 0x29, 0x46 ; 52 R
			DCB		0x46, 0x49, 0x49, 0x49, 0x31 ; 53 S
			DCB		0x01, 0x01, 0x7f, 0x01, 0x01 ; 54 T
			DCB		0x3f, 0x40, 0x40, 0x40, 0x3f ; 55 U
			DCB		0x1f, 0x20, 0x40, 0x20, 0x1f ; 56 V
			DCB		0x3f, 0x40, 0x38, 0x40, 0x3f ; 57 W
			DCB		0x63, 0x14, 0x08, 0x14, 0x63 ; 58 X
			DCB		0x07, 0x08, 0x70, 0x08, 0x07 ; 59 Y
			DCB		0x61, 0x51, 0x49, 0x45, 0x43 ; 5a Z
;**************************
				AREA 	routines, CODE, READONLY
				THUMB
				
				;LCDSendData.s
				;Gets memory address of a string (R0), finds corresponding index in ASCII table, and sends
				;each column of a character in the string (R9) to LCDSendData.
				;Inputs: R0 (String memory address)
				;		 R9 (LCD-related register)
				
				IMPORT	LCDSendData
				EXPORT	LCDSendString
LCDSendString	PROC
				PUSH	{R1-R3,LR}
				
getChar			LDRB	R1,[R0],#1
				CMP		R1,#0x04	
				BEQ		done		;EOT char, end
				SUB		R1,#0x20	;ASCII(0x20)= SPACE, starting point of CHARS array
				MOV		R3,#5
				MUL		R1,R3		;Each char takes 5 bytes
				
				;Print all 5 columns of a character
				MOV		R3,#0
				LDR		R2,=CHARS
writeColumn		LDRB	R9,[R2,R1]	;Load each column byte of a char into R9
				ORR		R9,#0x100	;R9[2] = D/C flag, set D
				BL		LCDSendData
				ADD		R1,#1
				ADD		R3,#1
				CMP		R3,#5
				BNE		writeColumn
				BEQ		getChar
				
done			POP		{R1-R3,LR}
				BX		LR
				ENDP
				ALIGN
				END	