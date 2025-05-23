/*
 * testServo.asm
 *
 *  Created: 08.04.2025 18:23:15
 *   Author: royer
 */ 
 /* pin servo 1= B0		servo 2=B1
 */

.set NPoint = 6000		;range=+-2000



.macro SERVO1W	; entre -100 et +100
	;_LDI u, high(@0*20+NPoint)
	MULT4 @0
	mov w, @0
	MULT4 @0
	mov w, @0
	subi w, -NP

	OUT OCR1AH, u
	OUT OCR1AL, w
.endmacro

.macro SERVO2W	; entre -100 et +100
	_LDI u, high(@0*20+NPoint)
	ldi w, low(@0*20+NPoint)

	OUT OCR1BH, u
	OUT OCR1BL, w
.endmacro

.macro SERVO1WI	; entre -100 et +100
	_LDI u, high(@0*20+NPoint)
	ldi w, low(@0*20+NPoint)

	OUT OCR1AH, u
	OUT OCR1AL, w
.endmacro

.macro SERVO2WI	; entre -100 et +100
	_LDI u, high(@0*20+NPoint)
	ldi w, low(@0*20+NPoint)

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

.org OVF1addr
	rjmp overflow1
.org OC1Aaddr
	rjmp output_compare1a
.org OC1Baddr
	rjmp output_compare1b

.org 30


overflow1:
	ldi _w, 0xff
	out	PORTB, _w	;allumage du servo1 et 2
	reti

output_compare1a:
	in	_w, PORTB
	andi 0b0
	out	PORTB, _w	;Exctinction1
	reti

output_compare1b:
	in	_w, PORTB
	andi 0b01
	out	PORTB, _w	;Exctinction 2
	reti






