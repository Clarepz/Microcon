; file	servo1.asm   target ATmega128L-4MHz-STK300
; purpose servo motor control from potentiometer
; module: M3, output port: PORTF
; module: M4, P7 servo Futaba S3003, output port: PORTB
.include "macros.asm"		; macro definitions
.include "definitions.asm"	; register/constant definitions

reset:
	LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRB,0xff		; configure portB to output
	
	jmp	main			; jump ahead to the main program
	

main:	
	OUTI PORTB, 0xff
	WAIT_US	2000
	OUTI PORTB, 0b11000000
	WAIT_US 18000
	rjmp main
			
