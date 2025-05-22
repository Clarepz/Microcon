; file	int0.asm   target ATmega128L-4MHz-STK300		
; purpose using INT0..INT3


; === interrupt table ===
.org	0x02
	jmp	ext_int0
.org	0x04
	jmp	ext_int1
; === interrupt service routines	
ext_int0:
	inc speed
    reti
ext_int1:
    dec speed
	reti
; === initialization (reset) ====
SPEED_init:
	OUTI	EIMSK,0b00000011 	; enable INT0/1
    ret