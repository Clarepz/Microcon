; file target ATmega128L-4MHz-STK300
; semaphores: r25

.equ DISTANCETRESH = 900/4

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt table ===
.org	0
	jmp	reset
.org 	ADCCaddr
	jmp	ADCCaddr_sra
.org	0x30

.include "irDistanceMacro.asm"
.include "printf.asm"
.include "uart.asm"	

reset:
	OUTI	DDRC,0xff		; configure portC to output
    LDSP	RAMEND			; set up stack pointer (SP)
    sei
	rcall	UART0_init
    IRSET
    rjmp main

main:
	
    DISTANCEREAD            ; read distance in b1:b0
    WAIT_MS 100
    PRINTF	UART0_putc		; print formatted
	.db	CR,CR,"CACA=",FHEX2,b,"=",FDEC2,b,"    ",0
    MOV2 a1,a0,b1,b0
    LSR2 a1,a0              ; print on leds
    LSR2 a1,a0
    out PORTC, a0

    cpi a0, DISTANCETRESH   ; chesk distance
    brsh wall
    rjmp main

wall:
    OUTI PORTC, 0xff
    WAIT_MS 200
    OUTI PORTC, 0x00
    WAIT_MS 200
    rjmp wall