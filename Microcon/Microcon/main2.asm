; file target ATmega128L-4MHz-STK300
; semaphores: r25
;===Definition===
.equ DISTANCETRESH = 225
.equ ISPEED = 170
; === interrupt table ===
.org	0
	jmp	reset
.org INT0addr
    jmp ext_int0
.org INT1addr
	jmp	ext_int1
.org 	ADCCaddr
	jmp	ADCCaddr_sra
.org	0x30
;=== includes ===
.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

.include "irDistanceMacro.asm"
.include "printf.asm"
.include "uart.asm"	
;.include "lcd.asm"
.include "speedControl.asm"
.include "Yann23cm.asm"
;================


reset:
    LDSP	RAMEND			; set up stack pointer (SP)
	OUTI	DDRC,0xff		; leds
	rcall	ws2812b4_init
    rcall   printSHappy
	rcall	UART0_init
    ;rcall   LCD_init    
    rcall   SPEED_init      ;init speed control
    IRSET                   ;init le capteur de distance
    sei
    rjmp main

main:
	
    DISTANCEREAD            ; read distance in b1:b0
    WAIT_MS 100
    PRINTF	UART0_putc		; print printDistance
	.db	CR,CR,"Distance=",FDEC2,b,"    ",0
    MOV2 a1,a0,b1,b0
    LSR2 a1,a0              ; print on leds
    LSR2 a1,a0
    out PORTC, a0

    cpi a0, DISTANCETRESH   ; check distance
    brsh wall           

    PRINTF	UART0_putc		; print speed
	.db	CR,CR,"Speed=",FDEC2,c,"    ",0
    ;PRINTF	LCD		; print speed
	.db	CR,CR,"Speed=",FDEC2,c,"    ",0
    
    rjmp main


wall:
    ;rcall LCD_uninit
    rcall printSConcerned
    WAIT_MS 500
    rcall printSDead
    WAIT_MS 1500
    rjmp wall