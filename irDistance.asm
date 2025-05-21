; file target ATmega128L-4MHz-STK300
; purpose button triggered ADC with semaphore

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt table ===
.org	0
	jmp	reset
.org 	ADCCaddr
	jmp	ADCCaddr_sra
	
.org	0x30
	
; === interrupt service routines
ADCCaddr_sra:
		
	in	a0,ADCL				; read low byte first
	in	a1,ADCH				; store 2 MSB
	;cpi a1,0b00000010		; compare value
	out PORTC, a1
	;brlo PC + 3			
	;ldi	r23,0x00			; clear boolean
	;reti			
	;ldi r23,0xff			; set the boolean
	reti					; ADIF cleared here
	;sbi	ADCSR,ADSC			; AD start conversion
	
; === initialization (reset) ====
reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portC to output
	OUTI	DDRC,0xff
	sei
	OUTI	ADCSR,(1<<ADEN)+(1<<ADIE)+6 ; AD Enable, AD int. enable, PS=CK/64	
	OUTI	ADMUX,3			; select channel irdistance
	sbi	ADCSR,ADSC			; start conversion
	rjmp	main			; jump ahead to the main program
	

; === main program ===
main:
	
	sbi	ADCSR,ADSC			; AD start conversion
	WAIT_MS 100				;
	;out r23, PORTC			;
	rjmp	main			; jump back to main
