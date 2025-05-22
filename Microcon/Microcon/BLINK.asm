/*
 * BLINK.asm
 *
 *  Created: 21.05.2025 15:59:08
 *   Author: royer
 */ 
.include "macros.asm"
.include "definitions.asm"

reset:
	OUTI DDRC, 0xff 

main:
	ldi a0, 0xff 
	ldi a1, 0x00
	out PORTC, a1
	WAIT_MS 2000
	out PORTC, a0
	WAIT_MS 2000
	rjmp main
