; file target ATmega128L-4MHz-STK300

; === interrupt service routines
ADCCaddr_sra:
	in	a0,ADCL				; read low byte first
	in	a1,ADCH				; store 2 MSB
	sbr r25, 0b00000001 	; set semaphore
	reti
	
; === initialization (reset) ====
.macro IRSET
	OUTI	ADCSR,(1<<ADEN)+(1<<ADIE)+6 ; AD Enable, AD int. enable, PS=CK/64	
	OUTI	ADMUX,3			; select channel irdistance
	ret
.endmacro

.macro DISTANCEREAD
	cbr r25, 0x00			; clear semaphore
	sbi	ADCSR,ADSC			; start conversion
	sbrs r25, 0				; wait for semaphor set
	rjmp PC-1
.endmacro


