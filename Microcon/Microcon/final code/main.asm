; main.asm
; button on PORTD
; IR distance PORTF
; servo PORTB PIN 0,1 
; LED matrix PORTE PIN,1

;===Definition===
.equ distanceTresh = 225
.equ initSpeed = 30


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




;======== libraries =======

;global:
.include "macros.asm"
.include "definitions.asm"
.include "printf.asm"
;.include "uart.asm"	;for debug
.include "lcd.asm"

;custom;
.include "ServoTimer1.asm"
.include "irDistanceMacro.asm"          
.include "speedStandbyControl.asm"       
.include "ledMatrix.asm"




;======== reset =========

reset:
	LDSP RAMEND
	D_LED_INIT				;init led matrix 
	rcall   LCD_init		;init LCD
	SERVOSETUP				;init servo
    rcall   SPEED_init      ;init speed/standby control
    IRSET                   ;init distance sensor

    _LDI globalspeed, initSpeed		; init used global registers
    clr semaphore					

    sei
    rjmp standby

standby:
	clr semaphore
    rcall printSSleepy
    SERVO1WI 0    			;servo speed = 0
    SERVO2WI 0
    sbloop:
        PRINTF	LCD			;print speed
		.db	CR,CR,"Speed=",FDEC2,c,"        ",0
		;PRINTF	UART		;debug
		;.db LF,"sem=",FHEX2,c,"       ",0

        sbrc semaphore, 0 ;check pause button
		rjmp main
		rjmp sbloop

main:
	
	clr semaphore
	rcall   printSHappy

	mainloop:
	
	SERVO2W globalspeed   	;set speed
	mov b3, globalspeed
	neg b3
    SERVO1W b3


	PRINTF	LCD		;print speed
	.db	CR,"Speed=",FDEC2,c,"       ",0
	;PRINTF	UART		;debug
	;.db LF,"sem=",FHEX2,c,"       ",0
	
	DISTANCEREAD
	WAIT_MS 20
	;PRINTF UART		;debug
	;.db	CR,CR,"Distance=",FDEC2,b,"       ",0

	DISTANCECOMPARE ;compare distance
	brsh wall
	
	sbrc semaphore, 0 ;check pause button
    rjmp standby
	rjmp mainloop


wall:
	rcall printSConcerned

    ;turn 90
    SERVO1WI turnSpeed
    SERVO2WI turnSpeed
    WAIT_MS turnTime
    ;move to offet
    SERVO1WI -turnSpeed
    SERVO2WI turnSpeed
	WAIT_MS offsettime

	;check distance
	DISTANCEREAD		
	WAIT_MS 20
    DISTANCECOMPARE		
    brsh dead

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
