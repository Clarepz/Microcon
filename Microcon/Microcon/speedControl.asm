

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