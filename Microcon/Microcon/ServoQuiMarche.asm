

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions
.def servochanel = r8
.def servocounter = r9
.def servospeed1  =r10
.def servospeed2 = r11

.set	servoOffset = 190
.set	initVal = 20

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

; === interrupt service routines ====
output_compare0:
	OUTI 	PORTB, 0x00

	in 		_sreg, SREG

	lsl 	servochanel
	inc		servocounter

	_CPI 	servocounter, 10
	brlo	skip
	clr		servocounter
	_LDI		servochanel,	0b00000001
	skip:

	_cpi		servocounter, 4
	brlo	servo0_3
	out		OCR0, a0
	brsh	servo4_7
	servo0_3:
	out		OCR0, a1
	servo4_7:

	;sbrs	servocounter, 2
	;OUTI OCR0, 180
	;out		OCR0, a0
	;sbrc	servocounter, 2
	;OUTI OCR0, 200
	;out		OCR0, a1

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
	
	OUTI	OCR0,initVal+servoOffset		; Output Compare reg 0
	
	
	OUTI	TIMSK,(1<<OCIE0)+(1<<TOIE0); enable outputcompar and overflow
	_LDI 	servochanel, 0b00000001
	clr 	servocounter

	rcall	UART0_init		; initialize UART
	sei						; set global interrupt
; === main program ===
main:
	ldi	a1, 128
	ldi a0, 255
	;_LDI	servospeed1, 180
	;_LDI	servospeed2, 200
	WAIT_MS 1000
	;_LDI	servospeed1, 200
	;_LDI	servospeed2, 180
	ldi	a0, 190
	ldi a1, 190
	WAIT_MS 1000
	rjmp	main