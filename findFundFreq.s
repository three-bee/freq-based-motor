			AREA 	routines, CODE, READONLY
			THUMB

			;findFundFreq.s
			;Finds the fundamental frequency & its magnitude in fft results.
			;Then, updates R6-8 accordingly.
			
			;Outputs: R6 (updated TIMER0A interval load value)
			;		  R7 (max freq magnitude)
			;		  R8 (max freq response index, between 1-511)
			
			EXPORT	findFundFreq
findFundFreq	PROC
			PUSH	{R1-R3}
			
			LDR		R1,=0x20000400	;fft result address
			MOV		R5,#0
			MOV		R7,#0
			MOV		R8,#0	
			
contCalc	ADD		R5,#4
			LDRSH	R0,[R1,R5]		;load real part to R0
			ADD		R5,#2			;samplecount+2
			
			MOV		R2,R0			;look at sign bit and take 2s complement if negative
			ASR		R2,#12			
			CMP		R2,#0x0			
			MVNNE	R0,R0		
			ADDNE	R0,R0,#1
			
			MUL		R0,R0			;R0 = real^2
			
			LDRSH	R2,[R1,R5]		;load imag part to R2
			ADD		R5,#2			;samplecount+2
			
			MOV		R3,R2			;look at sign bit and take 2s complement if negative
			ASR		R3,#12			
			CMP		R3,#0x0	
			MVNNE	R2,R2
			ADDNE	R2,R2,#1
			
			MUL		R2,R2			;R2 = imag^2
			ADD		R0,R2			;R0 = real^2 + imag^2
			
			CMP		R0,R7
			MOVHI	R7,R0			;update max magnitude
			MOVHI	R8,R5			;update index
			SUBHI	R8,#4
			
			CMP		R5,#510			;only look at N/2 bins since transform is conjugate symmetric
			BHS		findFreq
			B		contCalc
			
findFreq	MOV		R0,#992
			MOV		R1,#510
			MOV		R2,#1000
			MUL		R0,R2			;992*100
			UDIV	R0,R1			;992000/510
			MUL		R0,R8			;992000/510 * some value between [0,510]
			
			;max(R0)=992000, min(R0)=7000 (calculated)
			;min(R6)=8000, max(R6)=63000 (empirical, by motor speed observation)
			;P1=(7000,63000) P2=(992000,8000)
			
			;Then line equation passing through P1&P2 yields (with approximations):
			;R6 = -R0/18 + 500 + 63000
			
			UDIV	R8,R0,R2		;Update R8 with the actual frequency value (7-992Hz)
			
			MOV		R1,#18			
			UDIV	R0,R1	
			MOV		R2,#63500
			SUB		R0,R2,R0		;R6 = R0/18 + 500 + 63000
			
			MOV		R6,R0
			
done		POP		{R1-R3}
			BX		LR
			ENDP
			ALIGN
			END