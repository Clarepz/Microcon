.include "macros.asm"
.include "definitions.asm"



;======== table interupt =======
.org	0
	jmp	reset


.org	30


;======== bibliothèques =======

.include "lcd.asm"
.include "Yann23cm.asm"
.include "printf.asm"
.include "servoDeYannLeBoss.asm"



;======== reset =========

reset:
	LDSP RAMEND
	D_LED_INIT
	rcall   LCD_init
	SERVOSETUP


;======== main ========
main:
	PRINTF LCD
	.db	CR,CR,"Content",FDEC2,b,"    ",0
	rcall printSHappy
	SERVO1WI 2    ;speed = 0
    SERVO2WI 2
	WAIT_MS 2000
	PRINTF LCD
	.db	CR,CR,"Duper",FDEC2,b,"    ",0
	rcall printSConcerned
	SERVO1WI 4    ;speed = 0
    SERVO2WI 4
	WAIT_MS 2000
	rjmp main