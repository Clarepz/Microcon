

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions
.def servochanel = r13
.def servocounter = r19

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
	in 		_sreg, SREG

	OUTI 	PORTB, 0x00

	lsl 	servochanel
	inc		servocounter

	cpi 	servocounter, 10
	brlo	PC+3
	clr		servocounter,
	ldi		servochanel	0b00000001


	cpi 	servocounter, 8
	brlo	PC+3
	clr 	servochanel 


	out		SREG, _sreg
	reti

overflow:
	out 	PORTB, servochanel
	
	reti

; === initialisation (reset) ===	
reset: 
	LDSP	RAMEND				; load stack pointer (SP)
	OUTI	DDRB,0xff			; portB = output
		
	;OUTI	ASSR,  (1<<AS0)		; clock from TOSC1 (external)
	OUTI	TCCR0, (0<<CTC0)+3	;  CS0=6 CK	
	
	OUTI	OCR0,timer0-1		; Output Compare reg 0
	
	
	OUTI	TIMSK,(1<<OCIE0)+(1<<TOIE0); enable outputcompar and overflow
	_LDI 	servochanel, 0b00000001
	clr 	servocounter

	sei							; set global interrupt
; === main program ===
main:
	rjmp	main