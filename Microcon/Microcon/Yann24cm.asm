.include "macros.asm"
.include "definitions.asm"


.equ NBSERVO = 1
.equ SBOFFSET = 0b110110

.dseg
servoTable: .byte 2+nbServo		;lookup table of servo management
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
	ldi yh, high(servoTable)
	ldi yl, @0
	;lsl yl	
	adiw y, low(servoTable)
	ldi w, @1
	st y, w
.endmacro

;change the values of a servo in the lookUp table
.macro SERVOW		; nbr of the servo (starting at 0), value
	ldi yh, high(servoTable)
	ldi yl, @0
	;lsl yl
	adiw y, low(servoTable)
	mov w, @1
	st y, w
.endmacro

;setup servoTable with neutral values
.macro SERVOSETUP
	ldi	yl, low(servoTable)
	ldi	yh, high(servoTable)
	_LDI u, NBSERVO
	breq PC+5			;in case nbServo=0
	ldi w, 192
	st  y+, w
	dec u
	brne PC-3
	ldi w, SBOFFSET
	st y+, w
	ldi w,low(servoTable)
	st y, w
.endmacro





reset:
	LDSP RAMEND
	SERVOSETUP

	OUTI TIMSK, (1<<OCIE2)+(1<<TOIE2)
	OUTI TCCR2, (0<<CTC2)+3
	SERVOWI 0, 240

	OUTI DDRB, 0xff
	OUTI DDRC, 0xff
	sei

main:
	rjmp main









overflow2:




output_compare2:




