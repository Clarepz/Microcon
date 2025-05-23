

.set NPoint = 24


;===intialisation

.macro SERVOSETUP
	OUTI DDRB, 0xff

	OUTI ASSR, (0<<AS0)
	OUTI TCCR0, (1<<PWM0)+(0b10<<COM00)+5
	OUTI TCCR2, (1<<PWM2)+(0b10<<COM20)+5
.endmacro


.macro SERVO1W	; entre -5 et +5
	ldi w, NPoint+@0
	out OCR0, w
.endmacro

.macro SERVO2W	; entre -5 et +5
	ldi w, NPoint+@0
	out OCR2, w
.endmacro

