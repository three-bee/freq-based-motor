;Nested Vector Interrupt Controller registers
NVIC_EN0_INT19		EQU 0x00080000 ; Interrupt 19 enable
NVIC_EN0			EQU 0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI4			EQU 0xE000E410 ; IRQ 16 to 19 Priority Register
	
;16/32 Timer Registers
RCGCTIMER 			EQU 0x400FE604 ; GPTM Gate Control
TIMER0_CFG			EQU 0x40030000
TIMER0_TAMR			EQU 0x40030004
TIMER0_CTL			EQU 0x4003000C
TIMER0_IMR			EQU 0x40030018
TIMER0_RIS			EQU 0x4003001C ; Timer Interrupt Status
TIMER0_ICR			EQU 0x40030024 ; Timer Interrupt Clear
TIMER0_TAILR		EQU 0x40030028 ; Timer Interval
TIMER0_TAPR			EQU 0x40030038
TIMER0_TAR			EQU	0x40030048 ; Timer Register
	
;GPIO Port B Registers
PORTB_DATA			EQU	0x400053FC
;**************************
			AREA 	routines, CODE, READONLY
			THUMB
			
			EXPORT	init_Timer0A
init_Timer0A	PROC
			
			LDR R1, =RCGCTIMER ; Start Timer0
			LDR R0, [R1]
			ORR R0, R0, #0x01
			STR R0, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			
			LDR R1, =TIMER0_CTL ; disable timer during setup 
			LDR R0, [R1]
			BIC R0, R0, #0x01
			STR R0, [R1]
			
			LDR R1, =TIMER0_CFG ; set 16 bit mode
			MOV R0, #0x04
			STR R0, [R1]
			
			LDR R1, =TIMER0_TAMR
			MOV R0, #0x02 ; set to periodic, count down
			STR R0, [R1]
			
			LDR R1, =TIMER0_TAILR ; initialize match clock
			STR R6, [R1]		  ; R6 = TIMER0A interval load value
			
			LDR R1, =TIMER0_TAPR
			MOV R0, #3 ; divide 16MHz by 4 to
			STR R0, [R1] ; get 1MHz clocks
			
			LDR R1, =TIMER0_IMR ; enable timeout interrupt
			MOV R0, #0x01
			STR R0, [R1]
			
			; Configure interrupt priorities
			; Timer0A is interrupt #19.
			; Interrupts 16-19 are handled by NVIC register PRI4.
			; Interrupt 19 is controlled by bits 31:29 of PRI4.
			; set NVIC interrupt 19 to priority 2
			LDR R1, =NVIC_PRI4
			LDR R0, [R1]
			AND R0, R0, #0x00FFFFFF ; clear interrupt 19 priority
			ORR R0, R0, #0x40000000 ; set interrupt 19 priority to 2
			STR R0, [R1]
			
			; NVIC has to be enabled
			; Interrupts 0-31 are handled by NVIC register EN0
			; Interrupt 19 is controlled by bit 19
			; enable interrupt 19 in NVIC
			LDR R1, =NVIC_EN0
			MOVT R0, #0x08 ; set bit 19 to enable interrupt 19
			STR R0, [R1]
			
			; Enable timer
			LDR R1, =TIMER0_CTL
			LDR R0, [R1]
			ORR R0, R0, #0x03 ; set bit0 to enable
			STR R0, [R1] ; and bit 1 to stall on debug
			
			BX		LR
			ENDP
				
;**************************
			;MY_TIMER0A_ISR
			;Custom Timer0A_Handler for updating motor rotation speed and directions.
			;Input/output = R4 (Motor flag register), R6 (TIMER0A load value), R7(Max magnitude)
			
			EXPORT  MY_TIMER0A_ISR
MY_TIMER0A_ISR	PROC		
	
			LDR		R1,=TIMER0_CTL	 ;Disable timer
			LDR		R0,[R1]
			BIC		R0,R0,#0x01
			STR		R0,[R1]
			
			CMP		R7,#0xC0		 ;Magnitude threshold, empirical value
			LDRHS	R1,=TIMER0_TAILR ;Interval load
			STRHS	R6,[R1]			 ;Store new timer interval value (R6)
			
			;Change direction
changeDir	LDR		R1,=PORTB_DATA
			LDR		R0,[R1]
			BIC		R0,#0x0F	;Clear interested bits
			MOV		R2,R4		
			LSR		R2,#16		;R2 <- R4[7:4] (motor rotation mask bits)
			ORR		R0,R2		;Apply mask to data register
			STR		R0,[R1]
			
			MOV		R3,R4		;R3 <- R4[0], where R4[0] is the rotation direction bit
			AND		R3,#1
			CMP		R3,#0
			BEQ		CCW
			BNE		CW
			
CCW			CMP		R2,#0x08
			MOVEQ	R2,#0x01
			LSLNE	R2,#1
			B		exit
			
CW			CMP		R2,#0x01
			MOVEQ	R2,#0x08
			LSRNE	R2,#1
			B		exit
			
			;*******************
exit		LSL		R2,#16			
			MOV		R4,R2			;Update mask (upper 16 bits of R4)			
			ORR		R4,R3			;Write rotation bit again because previous command deleted it
			
			LDR		R1,=TIMER0_ICR	;Clear interrupt
			LDR		R2,[R1]
			ORR		R2, R2, #0x01
			STR		R2,[R1]
			
			LDR		R1,=TIMER0_CTL	;Enable timer
			LDR		R2,[R1]
			ORR		R2,R2,#0x03		;Set bit0 to enable and bit 1 to stall on debug
			STR		R2,[R1]
					
			BX		LR
			ENDP
			ALIGN
			END