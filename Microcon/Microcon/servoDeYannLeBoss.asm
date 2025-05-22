/*
 * testServo.asm
 *
 *  Created: 08.04.2025 18:23:15
 *   Author: royer
 */ 

.include "macros.asm"
.include "definitions.asm"

;=== interruption table
.org 0
	rjmp reset

.set pwm0_preset = 157
.set pwm0_compare = 24


;===intialisation

reset:
	LDSP RAMEND
	OUTI DDRB, 0xff
	OUTI DDRC, 0xff
	OUTI DDRD, 0x00

	OUTI ASSR, (0<<AS0)
	OUTI TCCR0, (1<<PWM0)+(0b10<<COM00)+5

	OUTI OCR0,pwm0_compare
	ldi r17, pwm0_compare

main:
	out OCR0,r17
	ldi r17, pwm0_compare		;store la valeur du pwm
	ldi r18, -4					;addition
	ldi r19, 8
	in r16, PIND
	out PORTC, r16

	loop:
	sbrs r16, 7
	add r17, r18
	inc r18
	lsl r16				;shift de r16 left
	dec r19
	breq main
	rjmp loop
