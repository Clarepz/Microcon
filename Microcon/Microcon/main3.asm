; file target ATmega128L-4MHz-STK300


; button on PORTD
; IR distance PORTF
; servo PORTB PIN 0,1 
; LED matrix PORTC PIN,0

;===Definition===
.equ DISTANCETRESH = 225
.equ ISPEED = 170

.equ servoZero  = 190
.equ turnSpeed  = 10
.equ turnTime   = 2000      ;ms
.equ offsetTime = 2000      ;ms

.def semaphore  = r12       ;d0
.def globalspeed = r8       ;c0

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
.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

.include "irDistanceMacro.asm"          ; uses b0-b1
.include "printf.asm"
.include "uart.asm"	
.include "lcd.asm"
.include "speedStanbyControl.asm"       ; uses c0
.include "Yann23cm.asm"
;================

reset:
    LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRC,0xff		; leds
	rcall	ws2812b4_init
	rcall	UART0_init
    rcall   LCD_init    
    rcall   SPEED_init      ;init speed control
    IRSET                   ;init le capteur de distance


    clr globalspeed
    clr semaphore

    sei
    rjmp standby

standby:
    rcall printSSleepy
    SERVOWI 0, servoZero    ;speed = 0
    SERVOWI 1, servoZero
    sbloop:
        sbrc semaphore
        rjmp main
        rjmp sbLoop


main:
    cbr semaphore
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
    ldi    a0, globalspeed
    ADDI   a0, servoZero
    SERVOW 0 , a0     
    SERVOW 1 , a0

    PRINTF	UART0_putc		; print speed
	.db	CR,CR,"Speed=",FDEC2,c,"    ",0
	rcall LCD_lf
	PRINTF	LCD		; print speed
	.db	CR,CR,"Speed=",FDEC2,c,"    ",0

    ;check if start stop button pressed:

    sbrc semaphore
    rjmp standby

    rjmp mainloop


wall:

    rcall printSConcerned

    ;turn 90
    SERVOWI 0, servoZero+turnSpeed
    SERVOWI 1, servoZero-turnSpeed
    WAIT_MS turnTime
    ;move offet
    SERVOWI 0, servoZero+turnSpeed
    SERVOWI 1, servoZero+turnSpeed

    clr w
    loop:
        DISTANCEREAD
        DISTANCECOMPARE
        brsh dead
        WAIT_MS offsetTime/10
        inc w
        cpse w,10
        rjmp loop
    ;turn 90
    SERVOWI 0, servoZero+turnSpeed
    SERVOWI 1, servoZero-turnSpeed
    WAIT_MS turnTime
    rjmp    main
dead:
    rcall printSDead
    SERVOWI 0, servoZero
    SERVOWI 1, servoZero

