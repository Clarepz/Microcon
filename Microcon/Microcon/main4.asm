.include "macros.asm"
.include "definitions.asm"



;======== table interupt =======
.org	0
	jmp	reset

.org OVF1addr
	rjmp overflow1

.org OC1Aaddr
	rjmp output_compare1a

.org OC1Baddr
	rjmp output_compare1b

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
	ldi a1, 200


;======== main ========
main:
	PRINTF LCD
	.db	CR,CR,"Content",FDEC2,b,"    ",0
	rcall printSHappy
	SERVO1WI 30    ;speed = 0
    SERVO2WI 30
	WAIT_MS 2000
	PRINTF LCD
	.db	CR,CR,"Duper",FDEC2,b,"    ",0
	rcall printSConcerned
	SERVO1W a1    ;speed = 0
    SERVO2W a1
	WAIT_MS 2000
	rjmp main