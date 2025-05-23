/*
 * Yann23cm.asm
 *
 *  Created: 22.05.2025 16:52:00
 *   Author: royer
 */ 





; WS2812b4_WR0	; macro ; arg: void; used: void
; purpose: write an active-high zero-pulse to PD1
.macro	WS2812b4_WR0
	clr u
	sbi PORTE, 1
	out PORTE, u
	nop
	nop
	;nop	;deactivated on purpose of respecting timings
	;nop
.endm

; WS2812b4_WR1	; macro ; arg: void; used: void
; purpose: write an active-high one-pulse to PD1
.macro	WS2812b4_WR1
	sbi PORTE, 1
	nop
	nop
	cbi PORTE, 1
	;nop	;deactivated on purpose of respecting timings
	;nop
.endm

 .macro D_LED_INIT		;initialise la dalle led
	OUTI	DDRE,0x02
.endmacro


smileyHapppy: .db 0b00000000,0b00100100,0b00100100,0b00000000,0b01000010,0b00111100,0b00000000,0b00000000
smileyConcerned: .db 0b00000000,0b00100100,0b00100100,0b00000000,0b00111100,0b01000010,0b01000010,0b00111100
smileyDead: .db 0b00000000,0b01010101,0b00100010,0b01010101,0b00000000,0b00011100,0b00100010,0b00000000
smileySleepy: .db 0b00000000, 0b00000000, 0b01010101,0b00100010,0b00000000,0b00000000,0b00111000

;========= Sous Routines à appeler ===========

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

;uses w,u,a0,a1,a2 and print a dead smiley on leds
printSDead:
	ldi zl, low(2*smileyDead)
	ldi zh, high(2*smileyDead)
	rjmp remplissageEtEnvoie

printSSleepy:
	ldi zl, low(2*smileySleepy)
	ldi zh, high(2*smileySleepy)
	rjmp remplissageEtEnvoie

;========== Fin des Sous Routines à appeler =======




;========== Sous Routines exclusivent au fichier =========

;parameter : z and uses w,u,a0,a1,a2 print a shape pointed by z 
remplissageEtEnvoie:
	ldi yl, low(0x0400)
	ldi yh, high(0x0400)
	ldi w, 9	;compteur pour les bit
ligne:
	dec w
	breq envoie
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
	cbi PORTE, 1
	WAIT_US	50 	; 50 us are required, NO smaller works
ret