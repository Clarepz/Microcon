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
.org INT0addr
    jmp ext_int0
.org INT1addr
	jmp	ext_int1
.org INT2addr
    jmp ext_int2
.org 	ADCCaddr
	jmp	ADCCaddr_sra
.org OVF1addr
	rjmp overflow1
.org OC1Aaddr
	rjmp output_compare1a
.org OC1Baddr
	rjmp output_compare1b

.org	0x30




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

    rcall   SPEED_init      ;init speed/standby control
    IRSET                   ;init le capteur de distance

    ldi globalspeed, ISPEED
    clr semaphore

    sei
    rjmp standby

;======== main ========

standby:
    rcall printSSleepy
    SERVO1WI 0    ;speed = 0
    SERVO2WI 0
    sbloop:
        PRINTF	LCD		; print speed
	    .db	CR,CR,"Speed=",FDEC,c,"    ",0

        sbrc semaphore, 0 ;  check if pause button pressed
        rjmp main
        rjmp sbLoop

main:
	SERVO1WI 20    	;set speed
    SERVO2WI 20
	PRINTF	LCD		;print speed
	    .db	LF,CR,"Speed=",FDEC,c,"    ",0

	DISTANCEREAD
	WAIT_MS 20
	PRINTF LCD		;print speed
	.db	CR,CR,"Distance=",FDEC2,b,"    ",0
	
	DISTANCECOMPARE
	brsh wall
	
	sbrc semaphore, 0
    rjmp standby
	
	rjmp main


wall:
	PRINTF LCD
	.db	CR,CR,"Duper",FDEC2,b,"    ",0
	rcall printSConcerned
	SERVO1WI turnSpeed   
    SERVO2WI 128+turnSpeed
	WAIT_MS 3000
	rjmp main