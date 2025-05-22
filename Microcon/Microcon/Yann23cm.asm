/*
 * Yann23cm.asm
 *
 *  Created: 22.05.2025 16:52:00
 *   Author: royer
 */ 

 ;a enlever apr�s test
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

.org 0x30

smileyHapppy: .db 0b00000000,0b00100100,0b00100100,0b00000000,0b01000010,0b00111100,0b00000000,0b00000000
smileyConcerned: .db 0b00000000,0b00100100,0b00100100,0b00000000,0b00111100,0b01000010,0b01000010,0b00111100


reset:
	LDSP	RAMEND			; Load Stack Pointer (SP)
	rcall	ws2812b4_init	; initialize 
	rjmp main

main:
	rcall printSHappy
	WAIT_MS 2000
	rcall printSConcerned
	WAIT_MS 2000
	rjmp main




;uses w,u,a0,a1,a2 and print a happpy smiley on leds
printSHappy:
	ldi zl, low(2*smileyHapppy)
	ldi zh, high(2*smileyHapppy)
	rjmp remplissageEtEnvoie

;uses w,u,a0,a1,a2 and print a concerned smiley on leds
printSConcerned:
	ldi zl, low(2*smileyConcerned)
	ldi zh, high(2*smileyConcerned)
	rjmp remplissageEtEnvoie

printSAngry




;parameter : z and uses w,u,a0,a1,a2 print a shape pointed by z 
remplissageEtEnvoie:
	ldi yl, low(0x0400)
	ldi yh, high(0x0400)
	ldi w, 9	;compteur pour les bit
ligne:
	dec w
	brne envoie
	ret 
	lpm u, z+	;contient l'info
	ldi a1, 8	;compteur pour les leds
pixel:
	sbrs u, 7
	rjmp noir

jaune :
	ldi	a0, 0x0f	; pixel jaune
	st	y+,a0
	ldi a0,0x0f
	st	y+,a0
	ldi	a0, 0x00
	st y+,a0

	lsl u
	dec a1
	breq ligne
	rjmp pixel

noir:
	ldi	a0, 0x00	; pixel noir
	st	y+,a0
	ldi a0, 0x00
	st	y+,a0
	ldi	a0, 0x00
	st y+,a0

	lsl u
	dec a1
	breq ligne
	rjmp pixel

envoie:
	ldi yl,low(0x0400)
	ldi yh,high(0x0400)
	_LDI r0,64
envoiePixel:

	ld a0, y+
	ld a1, y+	
	ld a2, y+

	cli
	rcall ws2812b4_byte3wr
	sei

	dec r0
	brne envoiePixel
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