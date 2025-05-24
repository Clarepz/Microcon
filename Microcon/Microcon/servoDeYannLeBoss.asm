/*
 * testServo.asm
 *
 *  Created: 08.04.2025 18:23:15
 *   Author: royer
 */ 
 /* pin servo 1= B0		servo 2=B1
 */

.set NPoint = 4000		;range= 0-4000



.macro SERVO1W	; entre 0 et 255
	;@0*16+NPoint
	push a0
	clr a0
	mov w, @0
	LSL2 a0, w
	LSL2 a0, w
	LSL2 a0, w
	LSL2 a0, w
	SUBI2 a0, w, -NPoint

	out OCR1AH, a0
	out OCR1AL, w
	pop a0
.endmacro

.macro SERVO2W	; entre 0 et 255
	;@0*16+NPoint
	push a0
	clr a0
	mov w, @0
	LSL2 a0, w
	LSL2 a0, w
	LSL2 a0, w
	LSL2 a0, w
	SUBI2 a0, w, -NPoint

	out OCR1BH, a0
	out OCR1BL, w
	pop a0
.endmacro

.macro SERVO1WI	; entre 0 et 255
	_LDI u, high(@0*16+NPoint)
	ldi w, low(@0*16+NPoint)

	OUT OCR1AH, u
	OUT OCR1AL, w
.endmacro

.macro SERVO2WI	; entre 0 et 255
	_LDI u, high(@0*16+NPoint)
	ldi w, low(@0*16+NPoint)

	OUT OCR1BH, u
	OUT OCR1BL, w
.endmacro

.macro SERVOSETUP
	OUTI DDRB, 0xff

	OUTI TCCR1B, 1

	OUTI TIMSK,(1<<TOIE1)+(1<<OCIE1A)+(1<<OCIE1B)
	sei
.endmacro





;=== interruption table
/*
.org OVF1addr
	rjmp overflow1
.org OC1Aaddr
	rjmp output_compare1a
.org OC1Baddr
	rjmp output_compare1b
*/


overflow1:
	ldi _w, 0xff
	out	PORTB, _w	;allumage du servo1 et 2
	reti

output_compare1a:
	in	_w, PORTB
	andi _w, 0b11111110
	out	PORTB, _w	;Exctinction1
	reti

output_compare1b:
	in	_w, PORTB
	andi _w, 0b11111101
	out	PORTB, _w	;Exctinction 2
	reti






