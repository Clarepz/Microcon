; file target ATmega128L-4MHz-STK300

; === interrupt service routines
ADCCaddr_sra:
	in	b0,ADCL				; read low byte first
	in	b1,ADCH				; store 2 MSB
	;sbr r25, 0b00000001 	; set semaphore
	reti
	
; === initialization (reset) ====
.macro IRSET
	OUTI	ADCSR,(1<<ADEN)+(1<<ADIE)+6 ; AD Enable, AD int. enable, PS=CK/64	
	OUTI	ADMUX,3			; select channel irdistance
.endmacro

.macro DISTANCEREAD
	;cbr r25, 0x01			; clear semaphore
	sbi	ADCSR,ADSC			; start conversion
	;sbrs r25, 0				; wait for semapho
.endmacro

.macro DISTANCECOMPARE
	MOV2 a1,a0,b1,b0
    LSR2 a1,a0              ; reformat
    LSR2 a1,a0
    cpi a0, DISTANCETRESH   ; check distance
.endmacro


