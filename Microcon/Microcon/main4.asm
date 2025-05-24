.include "macros.asm"
.include "definitions.asm"
; button on PORTD
; IR distance PORTF
; servo PORTB PIN 0,1 
; LED matrix PORTE PIN,1

;===Definition===
.equ DISTANCETRESH = 225
.equ ISPEED = 0


.equ turnSpeed  = 80
.equ turnTime   = 2000      ;ms
.equ offsetTime = 2000      ;ms

.def semaphore  = r22       ;d0
.def globalspeed = r23      ;c0

; === interrupt table ===
.org	0
	jmp	reset


.org	30

.org OVF1addr
	rjmp overflow1

.org OC1Aaddr
	rjmp output_compare1a

.org OC1Baddr
	rjmp output_compare1b

;======== biblioth�ques =======




.include "servoDeYannLeBoss.asm"
.include "irDistanceMacro.asm"          ; uses b0-b1
.include "printf.asm"
.include "uart.asm"	
.include "lcd.asm"
;.include "speedStandbyControl.asm"       ; uses c0
.include "Yann23cm.asm"




;======== reset =========

reset:
	LDSP RAMEND
	D_LED_INIT
	rcall   LCD_init
	SERVOSETUP

	D_LED_INIT
  
    ;rcall   SPEED_init      ;init speed/standby control
    IRSET                   ;init le capteur de distance

    ldi globalspeed, ISPEED
    clr semaphore

    ;sei
    rjmp main
    ;rjmp standby


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