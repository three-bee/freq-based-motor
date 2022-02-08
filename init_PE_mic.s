;GPIO_PORTE Registers
RCGCGPIO		EQU 	0x400FE608 ; GPIO clock register
PORTE_DEN	    EQU 	0x4002451C ; Digital Enable
PORTE_PCTL 		EQU 	0x4002452C ; Alternate function select
PORTE_AFSEL 	EQU 	0x40024420 ; Enable Alt functions
PORTE_AMSEL 	EQU 	0x40024528 ; Enable analog
PORTE_DIR		EQU		0x40024400 ; Direction register
	
;ADC Registers
RCGCADC 		EQU 	0x400FE638 ; ADC clock register
ADC0_ACTSS 		EQU 	0x40038000 ; Sample sequencer (ADC0 base address)
ADC0_IM 		EQU 	0x40038008 ; Interrupt select
ADC0_EMUX		EQU 	0x40038014 ; Trigger select
ADC0_PSSI 		EQU 	0x40038028 ; Initiate sample
ADC0_SSMUX3 	EQU 	0x400380A0 ; Input channel select
ADC0_SSCTL3 	EQU 	0x400380A4 ; Sample sequence control
ADC0_SSFIFO3 	EQU 	0x400380A8 ; Channel 3 results
ADC0_PC 		EQU 	0x40038FC4 ; Sample rate
ADC0_SAC		EQU		0x40038030 ; Sampling average control
;**************************
				AREA 	routines, CODE, READONLY
				THUMB

				EXPORT	init_PE_mic
init_PE_mic		PROC			
				PUSH	{R0, R1, LR}
				
				LDR 	R1, =RCGCGPIO
				LDR		R0, [R1]
				ORR 	R0, R0, #0x10 ; Enable port E CLK
				STR		R0, [R1]
				
				LDR 	R1, =RCGCADC ; Turn on ADC clock
				LDR 	R0, [R1]
				ORR 	R0, R0, #0x01 ; set bit 0 to enable ADC0 clock
				STR 	R0, [R1]
				
				NOP
				NOP
				NOP
				
				LDR 	R1, =PORTE_AFSEL
				LDR 	R0, [R1]
				ORR 	R0, R0, #0x08 ; set bit 3 to enable alt functions on PE3 
				STR 	R0, [R1]
				
				; PCTL does not have to be configured
				; since ADC0 is automatically selected when
				; port pin is set to analog.
				
				LDR 	R1, =PORTE_DEN
				LDR 	R0, [R1]
				BIC 	R0, R0, #0x08 ; clear bit 3 to disable digital on PE3
				STR 	R0, [R1]

				LDR 	R1, =PORTE_AMSEL
				LDR		R0, [R1]
				ORR 	R0, R0, #0x08 ; set bit 3 to enable analog on PE3
				STR 	R0, [R1]
				
				LDR 	R1, =PORTE_DIR
				LDR 	R0, [R1]
				BIC 	R0, R0, #0x08 ;clear bit 3 to set PE3 as input
				STR 	R0, [R1]
				;**************************
				LDR 	R1, =ADC0_ACTSS
				LDR 	R0, [R1]
				BIC 	R0, R0, #0x08 ; clear bit 3 to disable seq 3
				STR 	R0, [R1]

				LDR		R1, =ADC0_EMUX
				LDR 	R0, [R1]
				BIC 	R0, R0, #0xF000 ; clear bits 15:12 to select SOFTWARE
				STR 	R0, [R1] ; trigger

				LDR 	R1, =ADC0_SSMUX3
				LDR 	R0, [R1]
				BIC 	R0, R0, #0x000F ; clear bits 3:0 to select AIN0
				STR 	R0, [R1]

				LDR 	R1, =ADC0_SSCTL3
				LDR 	R0, [R1]
				ORR 	R0, R0, #0x06 ; set bits 2:1 (IE0, END0) IE0 is set since we want RIS to be set
				STR 	R0, [R1]

				LDR 	R1, =ADC0_PC
				LDR 	R0, [R1]
				ORR 	R0, R0, #0x01 ; set bits 3:0 to 1 for 125k sps
				STR 	R0, [R1]
				
				LDR		R1, =ADC0_SAC
				LDR		R0, [R1]
				MOV		R0, #0x04	;x16 hardware oversampling
				STR		R0,[R1]
				
				LDR 	R1, =ADC0_ACTSS
				LDR 	R0, [R1]
				ORR 	R0, R0, #0x08 ; set bit 3 to enable seq 3
				STR 	R0, [R1] ; sampling enabled but not initiated yet

				;Disable Interrupt
				;LDR 	R1, =ADC0_IM
				;LDR 	R0, [R1]
				;BIC 	R0, R0, #0x08 ; disable interrupt
				;STR 	R0, [R1]
				
				LDR 	R1,=ADC0_PSSI ; sample sequence initiate address
				LDR 	R0, [R1]
				ORR 	R0, R0, #0x08 ; set bit 3 for SS3
				STR 	R0, [R1]
						
				POP		{R0, R1, LR}
				BX		LR
				ENDP
				ALIGN
				END