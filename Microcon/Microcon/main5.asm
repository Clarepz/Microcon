.include "macros.asm"
.include "definitions.asm"
; button on PORTD
; IR distance PORTF
; servo PORTB PIN 0,1 
; LED matrix PORTE PIN,1

;===Definition===
.equ DISTANCETRESH = 225
.equ ISPEED = 30


.equ turnSpeed  = 30
.equ turnTime   = 1000      ;ms
.equ offsetTime = 1000      ;ms

.def semaphore  = r9       ;c1
.def globalspeed = r8      ;c0

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
.include "speedStandbyControl.asm"       ; uses c0
.include "Yann23cm.asm"




;======== reset =========

reset:
	LDSP RAMEND
	D_LED_INIT
	rcall   LCD_init
	SERVOSETUP

    rcall   SPEED_init      ;init speed/standby control
    IRSET                   ;init le capteur de distance

    _LDI globalspeed, ISPEED
    clr semaphore

    sei
    rjmp standby
	;rjmp main

;======== main ========

standby:
	clr semaphore
    rcall printSSleepy
    SERVO1WI 0    ;speed = 0
    SERVO2WI 0
    sbloop:
        PRINTF	LCD		;print speed
		.db	CR,CR,"Speed=",FDEC2,c,"        ",0
		;PRINTF	LCD
		;.db LF,"sem=",FHEX2,c,"       ",0

        sbrc semaphore, 0 ;check pause button
		rjmp main
		rjmp sbloop



main:
	
	clr semaphore
	rcall   printSHappy

	
	mainloop:
	;SERVO1WI -30*1.3   	;set speed
   ; SERVO2WI 30

	SERVO2W globalspeed   	;set speed
	mov b3, globalspeed
	neg b3
    SERVO1W b3


	PRINTF	LCD		;print speed
	.db	CR,"Speed=",FDEC2,c,"       ",0
	;PRINTF	LCD
	;.db LF,"sem=",FHEX2,c,"       ",0
	
	DISTANCEREAD
	WAIT_MS 20
	;PRINTF LCD		;print distance
	;.db	CR,CR,"Distance=",FDEC2,b,"       ",0

	DISTANCECOMPARE ;compare distance
	brsh wall
	
	sbrc semaphore, 0 ;check pause button
    rjmp standby
	rjmp mainloop


wall:
	/*PRINTF LCD
	.db	CR,CR,"Duper",FDEC2,b,"    ",0
	rcall printSConcerned
	SERVO1WI -turnSpeed   
    SERVO2WI turnSpeed
	WAIT_MS 3000
	rjmp main*/
	rcall printSConcerned

    ;turn 90
    SERVO1WI turnSpeed
    SERVO2WI turnSpeed
    WAIT_MS turnTime
    ;move to offet
    SERVO1WI -turnSpeed
    SERVO2WI turnSpeed
	WAIT_MS offsettime

	DISTANCEREAD
	WAIT_MS 20
    DISTANCECOMPARE
    brsh dead

    /*clr a0
    loop:
        DISTANCEREAD
        DISTANCECOMPARE
        brsh dead
        WAIT_MS offsetTime/10
        inc a0
        cpse a0,10
        rjmp loop*/

    ;turn 90
    SERVO1WI turnSpeed
    SERVO2WI turnSpeed
    WAIT_MS turnTime
    rjmp    main
dead:
    rcall printSDead
    SERVO1WI 0
    SERVO2WI 0
idle:
	rjmp idle
