

.include "macros.asm"
.include "definitions.asm"


.equ nbServo = 1
.equ servoROffset = 0b101100

.dseg
servoTable: .byte 12+nbServo		;lookup table of servo management
.cseg


.org	0
	jmp reset

.org OVF2addr
	rjmp overflow2

.org	0x30




;change the values of a servo in the lookUp table
.macro SERVOWI		; nbr of the servo (starting at 0), value
	ldi zh, high(2*servoTable)
	ldi zl, @0
	lsl zl
	adiw z, low(2*servoTable)
	ldi w, @1
	st z+, w
	neg w
	subi w, 1
	st z, w
.endmacro

;change the values of a servo in the lookUp table
.macro SERVOW		; nbr of the servo (starting at 0), value
	ldi zh, high(2*servoTable)
	ldi zl, @0
	lsl zl
	adiw z, low(2*servoTable)
	mov w, @1
	st z+, w
	neg w
	subi w, 1
	st z, w
.endmacro


reset:
	LDSP RAMEND
	call servoSetup

	OUTI TIMSK, (1<<OCIE2)
	OUTI TCCR2, (1<<CTC2)+3
	OUTI OCR2, 120
	SERVOWI 0, 200

	OUTI DDRB, 0xff
	OUTI DDRC, 0xff
	OUTI DDRD, 0x00

	sei


	



main:
	rjmp main


overflow2:
	in  _sreg, SREG
	push zl
	push zh	
	lds _w, 2*servoTable+11+nbServo		;w contient zl de OCR2
	mov zl, _w
	ldi zh, high(2*servoTable)
	ld _u, z		;u contient la valeur de OCR2				
	out OCR2, _u
	INC_CYC _w, low(2*servoTable), low(2*servoTable)+9+nbServo
	sts 2*servoTable+11+nbServo, _w
	lds _w, 2*servoTable+10+nbServo
	sbrs _w, 6		;skip if mode attente
	rjmp ecrit1		;si on est pas en mode attente	
	subi _w, -2		;rg++
sortieInterupt:
	sts 2*servoTable+10+nbServo, _w
	pop zh
	pop zl
	out SREG, _sreg
	reti
ecrit1:
	sbrc _w, 0			;skip if IWT=0 ~ WT=1
	rjmp ecrit0
	sbrc _w, 7			;skip si EOC=0
	ldi _w, servoROffset
	;write 1 sur port servo
	
	;OUTI PORTC, 0xff
	OUTI PORTB, 0xff
	;end of test
changeFlanc:
	subi _w, -1
	;update OCR2
	;end of test
	rjmp sortieInterupt
ecrit0:
	;write 0 sur port servo
	OUTI PORTB, 0b11000000
	;end of test
	cpi _w, servoROffset+nbServo
	brne PC+2
	ori _w, 0b01000000
	rjmp changeFlanc



servoSetup:
	ldi	zl, low(2*servoTable)
	ldi	zh, high(2*servoTable)
	ldi	a0, nbServo
	breq PC+7			;in case nbServo=0
	ldi w, 192
	st  z+, w
	ldi w, 64
	st z+, w
	dec a0
	brne PC-5
	ldi a0, 10-nbServo
	ldi w, 0xff
	st z+, w
	dec a0
	brne PC-3
	ldi w, 0b10000000
	st z+, w
	ldi w,low(2*servoTable)
	st z, w
	ret




