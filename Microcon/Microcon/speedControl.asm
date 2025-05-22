

; === interrupt service routines	
ext_int0:
	inc c0
    reti
ext_int1:
    dec c0
	reti
; === initialization (reset) ====
SPEED_init:
	OUTI	EIMSK,0b00000011 	; enable INT0/1
    OUTI    EICRA,0b00001111    ; set to flanc montant
    ret