

.include "macros.asm"
.include "definitions.asm"


.equ NBSERVO = 2
.equ SBOFFSET = 0b110110

.dseg
servoTable: .byte 12+nbServo		;lookup table of servo management
.cseg


.org	0
	jmp reset

.org	OVF2addr
	rjmp overflow2

.org OC2addr
	rjmp output_compare2

.org	0x30




;change the values of a servo in the lookUp table
.macro SERVOWI		; nbr of the servo (starting at 0), value
	ldi zh, high(2*servoTable)
	ldi zl, @0
	lsl zl
	adiw z, low(2*servoTable)
	ldi w, @1
	st z+, w
.endmacro

;change the values of a servo in the lookUp table
.macro SERVOW		; nbr of the servo (starting at 0), value
	ldi zh, high(2*servoTable)
	ldi zl, @0
	lsl zl
	adiw z, low(2*servoTable)
	mov w, @1
	st z+, w
.endmacro


reset:
	LDSP RAMEND
	call servoSetup

	OUTI TIMSK, (1<<OCIE2)+(1<<TOIE2)
	OUTI TCCR2, (0<<CTC2)+3
	OUTI OCR2, 120
	SERVOWI 0, 240
	SERVOWI 1, 30

	OUTI DDRB, 0xff
	OUTI DDRC, 0xff
	OUTI DDRD, 0x00
	OUTI PORTB, 0xff
	OUTI DDRA, 0xff

	sei


	



main:
	rcall output_compare2
	rcall overflow2
	rcall output_compare2
	rcall overflow2
	rcall overflow2
	rcall overflow2
	rcall overflow2
	rcall overflow2
	rcall overflow2
	rcall overflow2
	rcall overflow2
	rcall overflow2
	rjmp main


overflow2:
	in  _sreg, SREG
	push zl
	push zh
	push a0	
	lds _w, 2*servoTable+NBSERVO
	sbrs _w, 6
	;write1 zone
	subi _w, SBOFFSET
	sbrc _w, 0
	OUTI PORTB, 0xff
	sbrc _w, 1
	OUTI PORTA, 0xff
	;end of test
	lds _w, 2*servoTable+NBSERVO
	subi _w, -1	;SB+1
	sbrs _w, 7			;skip si EOC=1
	rjmp suite
	ldi _w, SBOFFSET
	in a0,TIMSK		;on peut pas utiliser _u car <r16
	ori a0, 0b01000000
	out TIMSK, a0
suite:
	sts 2*servoTable+NBSERVO, _w	;sortie
	pop a0
	pop zh
	pop zl
	out SREG, _sreg
	reti


output_compare2:
	in  _sreg, SREG
	push zl
	push zh	
	push a0
	lds _w, 2*servoTable+1+nbServo		;w contient zl de OCR2
	mov zl, _w
	ldi zh, high(2*servoTable)
	ld _u, z		;u contient la valeur de OCR2				
	out OCR2, _u
	INC_CYC _w, low(2*servoTable), low(2*servoTable)+NBSERVO-1
	sts 2*servoTable+1+NBSERVO, _w
	lds _w, 2*servoTable+NBSERVO ;w contient state byte
	;en cours
	OUTI PORTB, 0x00
	OUTI PORTA, 0x00
	;en cours
	ldi w, SBOFFSET+NBSERVO-1
	cpi _w, SBOFFSET+NBSERVO-1
	brne step2	;step=nbServo ?
	in a0,TIMSK		;on peut pas utiliser _u car <r16
	andi a0, 0b10111111
	out TIMSK, a0
	ori _w, 0b01000000	;WB=1
step2:
	sts 2*servoTable+NBSERVO, _w	;sortie
	pop a0
	pop zh
	pop zl
	out SREG, _sreg
	reti



servoSetup:
	ldi	zl, low(2*servoTable)
	ldi	zh, high(2*servoTable)
	ldi	a0, NBSERVO
	breq PC+5			;in case nbServo=0
	ldi w, 192
	st  z+, w
	dec a0
	brne PC-3
	ldi w, SBOFFSET
	st z+, w
	ldi w,low(2*servoTable)
	st z, w
	ret




