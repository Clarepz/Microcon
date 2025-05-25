/*
 * testServo.asm
 *
 *  Created: 08.04.2025 18:23:15
 *   Author: royer
 */ 
 /* pin servo 1= B0		servo 2=B1
 */

;neutral point ie. speed=0
.set NPoint = 4000		;range= 0-4000
.set NPoint2 = 4150		;Le offset du servo 2 n'est pas réglable



.macro SERVO1W	; signed reg
	;@0*16+NPoint
	push a0
	clr a0
	mov w, @0
	subi w, -128
	LSL2 a0, w
	LSL2 a0, w
	LSL2 a0, w
	LSL2 a0, w
	SUBI2 a0, w, -NPoint

	out OCR1AH, a0
	out OCR1AL, w
	pop a0
.endmacro

.macro SERVO2W	; signed reg
	;@0*16+NPoint
	push a0
	clr a0
	mov w, @0
	subi w, -128
	LSL2 a0, w
	LSL2 a0, w
	LSL2 a0, w
	LSL2 a0, w
	SUBI2 a0, w, -NPoint2

	out OCR1BH, a0
	out OCR1BL, w
	pop a0
.endmacro

.macro SERVO1WI	; entre -125 et 125
	_LDI u, high(@0*16+NPoint+2000)
	ldi w, low(@0*16+NPoint+2000)

	OUT OCR1AH, u
	OUT OCR1AL, w
.endmacro

.macro SERVO2WI	; entre -125 et 125
	_LDI u, high(@0*16+NPoint2+2000)
	ldi w, low(@0*16+NPoint2+2000)

	OUT OCR1BH, u
	OUT OCR1BL, w
.endmacro

.macro SERVOSETUP
	OUTI DDRB, 0xff

	OUTI TCCR1B, 1

	OUTI TIMSK,(1<<TOIE1)+(1<<OCIE1A)+(1<<OCIE1B)
	sei
.endmacro

overflow1:
	ldi _w, 0xff
	out	PORTB, _w	;set pins of servo1 et 2
	reti

output_compare1a:
	in	_w, PORTB
	andi _w, 0b11111110
	out	PORTB, _w	;clear pin of servo 1
	reti

output_compare1b:
	in	_w, PORTB
	andi _w, 0b11111101
	out	PORTB, _w	;clear pin of servo 2
	reti






