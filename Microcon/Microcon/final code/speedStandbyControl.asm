

; === interrupt service routines	
ext_int0:   ; + button clicked
	inc c0  ; inc speed
    reti
ext_int1:   ; - button clicked
    dec c0  ; dec speed
	reti
ext_int2:   ; pause button clicked
	sbr semaphore, 0
    reti

; === initialization (reset) ====
SPEED_init:
	OUTI   EIMSK,0b00000111 	; enable INT0/1/2
    ldi    w, 0b00111111
    sts    EICRA,w    ; set to flanc montant
    ret