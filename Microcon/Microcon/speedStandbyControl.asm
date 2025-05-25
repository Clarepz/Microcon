

; === interrupt service routines	
ext_int0:
	inc c0
    reti
ext_int1:
    dec c0
	reti
ext_int2: ; pause button clicked
	inc c1
    ;_SBR semaphore, 0
    reti

; === initialization (reset) ====
SPEED_init:
	OUTI   EIMSK,0b00000111 	; enable INT0/1/2
    ldi    w, 0b00111111
    sts    EICRA,w    ; set to flanc montant
    ret