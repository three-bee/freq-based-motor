;EE447 TERM PROJECT
;BAHRI BATUHAN BILECEN
;2374635
;6 FEBRUARY 2022
;**************************		
			AREA	main, READONLY, CODE
			THUMB
			
			EXTERN arm_cfft_q15
			EXTERN arm_cfft_sR_q15_len256
				
			EXTERN init_PA_lcd
			EXTERN init_PB_motor
			EXTERN init_PE_mic
			EXTERN init_SysTick
			EXTERN init_Timer0A
			EXTERN init_PF_led_button
				
			EXTERN findFundFreq
			EXTERN updateLED
			EXTERN updateScreen
;**************************		
			EXPORT __main
__main		PROC
	
			MOV		R4,#0			;Motor flag register. 
									;R4[0] = Motor rotation flag. SW1 pressed -> 1, SW2 pressed -> 0
									;R4[31:16] = Motor rotation mask (16 bit) 
			MOVT	R4,#0x0001		;Move initial mask to R4[31:16]
			
			MOV		R5,#0			;samplecount
									;When 256 samples are taken, FFT is called
			
			MOV		R6,#63000		;TIMER0A initial interval load value
									;During the program execution, R6 will hold the load value and get updated
									;depending on the microphone input frequency inside findFundFreq subroutine
			
			MOV		R7,#0			;Fundamental frequency magnitude
			
			MOV		R8,#0			;Corresponding index to the fundamental frequency magnitude.
									;In findFundFreq subroutine, it is then changed to the actual frequency value (7-992Hz).
			
			MOV		R9,#0			;LCD-related register.
									;R9[8] = D/C flag, 1 if D
									;R9[3:0] = Data to be written to SSI_DR
			
			LDR		R10,=0x20000804 ;String addresses for R7 and R8 after passing through CONVRT subroutine.
			
			CPSID	I
			BL		init_PF_led_button
			BL		init_PB_motor
			BL		init_Timer0A
			BL		init_PE_mic
			BL		init_SysTick
			BL		init_PA_lcd
			CPSIE	I
;**************************
contSample	CMP		R5,#1020		;At each measurement write, samplecount += 4 (+2 for real, +2 for imag)
			BHS		computeFFT		;Then for 256 meausurements, 256*4 = 1028
			B		contSample		;R5 starts from 0, so jump to fft when 1028-8=1020
			
computeFFT	LDR		R0,=arm_cfft_sR_q15_len256
			LDR		R1,=0x20000400
			MOV		R2,#0
			MOV		R3,#1
			
			CPSID	I				;Interrupts inside cfft subroutine cause issues 
			BL		arm_cfft_q15
			CPSIE	I
			
			BL		findFundFreq
			BL		updateScreen
			BL		updateLED
			
			MOV32	R2,#1200000		;Delay
loop		SUBS	R2,#1
			BNE		loop	
			
			B		contSample
			
			ENDP
			ALIGN
			END