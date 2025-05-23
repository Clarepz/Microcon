; file target ATmega128L-4MHz-STK300

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; button on PORTD
; IR distance PORTF
; servo PORTB PIN 0,1 
; LED matrix PORTC PIN,0

;===Definition===
.equ DISTANCETRESH = 225
.equ ISPEED = 170


.equ turnSpeed  = 2
.equ turnTime   = 2000      ;ms
.equ offsetTime = 2000      ;ms

.def semaphore  = r22       ;d0
.def globalspeed = r23       ;c0

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
.org	0x30
;=== includes ===

.include "irDistanceMacro.asm"          ; uses b0-b1
.include "printf.asm"
.include "uart.asm"	
.include "lcd.asm"
.include "speedStandbyControl.asm"       ; uses c0
.include "Yann23cm.asm"
.include "servoClean.asm"
;================

reset:
    LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRC,0xff		; leds
	D_LED_INIT
	rcall	UART0_init
    rcall   LCD_init    
    rcall   SPEED_init      ;init speed control
    IRSET                   ;init le capteur de distance
	SERVOSETUP


    clr globalspeed
    clr semaphore

    sei
    rjmp standby

standby:
    rcall printSSleepy
    SERVO1WI 0    ;speed = 0
    SERVO2WI 0
    sbloop:
        sbrc semaphore, 0
        rjmp main
        rjmp sbLoop


main:
    cbr semaphore, 0
    rcall   printSHappy
	mainloop:
    DISTANCEREAD            ; read distance in b1:b0
    WAIT_MS 20

    PRINTF	UART0_putc		; print printDistance
	.db	CR,CR,"Distance=",FDEC2,b,"    ",0
	rcall LCD_home

	PRINTF LCD
	.db	CR,CR,"Distance=",FDEC2,b,"    ",0

    DISTANCECOMPARE
    brsh wall  

    ;set speed:
    SERVO1W globalSpeed     
    SERVO2W globalSpeed

    PRINTF	UART0_putc		; print speed
	.db	CR,CR,"Speed=",FDEC2,c,"    ",0
	rcall LCD_lf
	PRINTF	LCD		; print speed
	.db	CR,CR,"Speed=",FDEC2,c,"    ",0

    ;check if start stop button pressed:

    sbrc semaphore, 0
    rjmp standby

    rjmp mainloop


wall:

    rcall printSConcerned

    ;turn 90
    SERVO1WI turnSpeed
    SERVO2WI -turnSpeed
    WAIT_MS turnTime
    ;move offet
    SERVO1WI turnSpeed
    SERVO2WI turnSpeed

    clr w
    loop:
        DISTANCEREAD
        DISTANCECOMPARE
        brsh dead
        WAIT_MS offsetTime/10
        inc w
        cpi w,10
		breq PC+2
        rjmp loop
    ;turn 90
    SERVO1WI turnSpeed
    SERVO2WI -turnSpeed
    WAIT_MS turnTime
    rjmp    main
dead:
    rcall printSDead
    SERVO1WI 0
    SERVO2WI 0

