; irDistanceMacro.asm

; === interrupt service routines==
ADCCaddr_sra:
	;read mesured distance
	in	b0,ADCL				; read low byte first
	in	b1,ADCH				; store 2 MSB
	reti
	
; === initialization (reset) ====
.macro IRSET
	OUTI	ADCSR,(1<<ADEN)+(1<<ADIE)+6 ; AD Enable, AD int. enable, PS=CK/64	
	OUTI	ADMUX,3			; select channel irdistance
.endmacro

.macro DISTANCEREAD
	sbi	ADCSR,ADSC			; start conversion
.endmacro

.macro DISTANCECOMPARE
	MOV2 a1,a0,b1,b0
    LSR2 a1,a0              ; reformat
    LSR2 a1,a0
    cpi a0, DISTANCETRESH   ; check distance
.endmacro