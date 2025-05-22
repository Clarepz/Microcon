/*
 * Yann23cm.asm
 *
 *  Created: 22.05.2025 16:52:00
 *   Author: royer
 */ 

 ;a enlever après test
 .include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions
;====== fin de zone





; WS2812b4_WR0	; macro ; arg: void; used: void
; purpose: write an active-high zero-pulse to PD1
.macro	WS2812b4_WR0
	clr u
	sbi PORTD, 1
	out PORTD, u
	nop
	nop
	;nop	;deactivated on purpose of respecting timings
	;nop
.endm

; WS2812b4_WR1	; macro ; arg: void; used: void
; purpose: write an active-high one-pulse to PD1
.macro	WS2812b4_WR1
	sbi PORTD, 1
	nop
	nop
	cbi PORTD, 1
	;nop	;deactivated on purpose of respecting timings
	;nop
.endm

.org 0
	jmp	reset

;.dseg
;.db 0b00000000,0b00100100,0b00100100,0b00000000,0b01000010,0b00111100,0b00000000,0b00000000
.org 0x30

reset:
	LDSP	RAMEND			; Load Stack Pointer (SP)
	rcall	ws2812b4_init	; initialize 
	rcall printSmileyHappy
	rjmp main

main:
	rjmp main



remplissage:
ldi	b0,17
ldi zl,low(0x0400)
	ldi zh,high(0x0400)
imgld_loop:
	ldi	a0, 0x0f	; pixel 1, light green
	st	z+,a0
	ldi a0,0x0f
	st	z+,a0
	ldi	a0, 0x00
	st z+,a0

	ldi	a0, 0x00	; pixel 2, light red
	st	z+,a0
	ldi a0,0x0f
	st	z+,a0
	ldi	a0, 0x00
	st z+,a0

	ldi	a0, 0x00	; pixel 3, light blue
	st	z+,a0
	ldi a0,0x00
	st	z+,a0
	ldi	a0, 0x0f
	st z+,a0

	ldi	a0, 0x00	; pixel 4, off
	st	z+,a0
	ldi a0,0x00
	st	z+,a0
	ldi	a0, 0x00
	st z+,a0

	dec b0
	brne imgld_loop
	ret






printSmileyHappy:
	rcall remplissage
	ldi zl,low(0x0400)
	ldi zh,high(0x0400)
	ldi w,64
loop:

	ld a0, z+
	;add a1,b1		; increase intensity (and color) until all white
	ld a1, z+		;>and high intensity, uncomment to use
	;add a1,b1
	ld a2,z+
	;add a2,b1

	cli
	rcall ws2812b4_byte3wr
	sei

	dec w
	brne loop
	rcall ws2812b4_reset
	ret












 ws2812b4_init:
	OUTI	DDRD,0x02
ret

; ws2812b4_byte3wr	; arg: a0,a1,a2 ; used: r16 (w)
; purpose: write contents of a0,a1,a2 (24 bit) into ws2812, 1 LED configuring
;     GBR color coding, LSB first
ws2812b4_byte3wr:

	ldi w,8
ws2b3_starta0:
	sbrc a0,7
	rjmp	ws2b3w1
	WS2812b4_WR0			; write a zero
	rjmp	ws2b3_nexta0
ws2b3w1:
	WS2812b4_WR1
ws2b3_nexta0:
	lsl a0
	dec	w
	brne ws2b3_starta0

	ldi w,8
ws2b3_starta1:
	sbrc a1,7
	rjmp	ws2b3w1a1
	WS2812b4_WR0			; write a zero
	rjmp	ws2b3_nexta1
ws2b3w1a1:
	WS2812b4_WR1
ws2b3_nexta1:
	lsl a1
	dec	w
	brne ws2b3_starta1

	ldi w,8
ws2b3_starta2:
	sbrc a2,7
	rjmp	ws2b3w1a2
	WS2812b4_WR0			; write a zero
	rjmp	ws2b3_nexta2
ws2b3w1a2:
	WS2812b4_WR1
ws2b3_nexta2:
	lsl a2
	dec	w
	brne ws2b3_starta2
	
ret

; ws2812b4_reset	; arg: void; used: r16 (w)
; purpose: reset pulse, configuration becomes effective
ws2812b4_reset:
	cbi PORTD, 1
	WAIT_US	50 	; 50 us are required, NO smaller works
ret