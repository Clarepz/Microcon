

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions
.def servocounter = r12

; === interrupt vector table ===
.org	0
	jmp	reset
.org	OC0addr					; timer 0 output compare match
	jmp	output_compare0
.org 	OVF0addr
	jmp overflow
.org	0x30

; === interrupt service routines ====
.set	timer0 = 100


output_compare0:
	cpi 	servocounter, 8	 	 	
	brsh 	PC+2
	cbi 	PORTB, servocounter

	inc 	servocounter		
	sbrc 	servocounter, 2
	clr 	servocounter
	reti

overflow:
	cpi servocounter, 8
	brsh PC+2
	sbi	PORTB, servocounter
	reti

; === initialisation (reset) ===	
reset: 
	LDSP	RAMEND				; load stack pointer (SP)
	OUTI	DDRB,0xff			; portB = output
		
	OUTI	ASSR,  (1<<AS0)		; clock from TOSC1 (external)
	OUTI	TCCR0, (0<<CTC0)+6	;  CS0=6 CK	
	
	OUTI	OCR0,timer0-1		; Output Compare reg 0
	
	
	OUTI	TIMSK,(1<<OCIE0)+(1<<TOIE0); enable outputcompar and overflow
	clr 	servocounter

	sei							; set global interrupt
; === main program ===
main:
	rjmp	main