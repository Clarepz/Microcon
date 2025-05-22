
.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions
.def servochanel = r13
.def servocounter = r18


.set	initVal = 1
.equ	servoOffset=190


.macro SERVOW		; # of the servo (starting at 0), value
	ldi w, @1
	sts servoTable + @0, w
.endmacro



; === interrupt vector table ===
.org	0
	jmp	reset
.org	OC0addr					; timer 0 output compare match
	jmp	output_compare0
.org 	OVF0addr
	jmp overflow
.org	0x30

.include "printf.asm"
.include "UART.asm"



.dseg
servoTable: .byte 8		;lookup table of servo management
.cseg


;.macro SERVOWA		;value ;=write all servo
servowa:
	ldi zh, high(servoTable)
	ldi zl, low(servoTable)
	_LDI u, 10;@0
	clr w
	loop:
		st z+, u
		inc w
		cpi w, 8
		brne loop
		ret
;.endmacro


; === interrupt service routines ====
output_compare0:
	OUTI 	PORTB, 0x00

	in 		_sreg, SREG

	lsl 	servochanel
	inc		servocounter

	cpi 	servocounter, 10
	brlo	skip

	clr		servocounter
	_LDI		servochanel,	0b00000001
	skip:

	;ldi 	zh, high(servoTable)
	;mov 	zl, servocounter
	;adiw 	zl, low(servoTable)	
	;ld 		_w, z
	;out 	OCR0, _w

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
	
	OUTI	OCR0,initVal		; Output Compare reg 0
	
	OUTI	TIMSK,(1<<OCIE0)+(1<<TOIE0); enable outputcompar and overflow
	_LDI 	servochanel, 0b00000001
	clr 	servocounter
	;rcall SERVOWA ;10

	;rcall	UART0_init		; initialize UART
	sei							; set global interrupt
; === main program ===
main:
	;rcall output_compare0
	;SERVOW 0, 50+servoOffset
	;WAIT_MS 2000
	;SERVOW 0, -50+servoOffset
	;WAIT_MS 2000
	rjmp	main
