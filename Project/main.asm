; file target ATmega128L-4MHz-STK300
; semaphores: r25

.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions

; === interrupt table ===
.org	0
	jmp	reset
.org 	ADCCaddr
	jmp	ADCCaddr_sra
.org	0x30

.include "irDistanceMacro.asm"

reset:
    LDSP	RAMEND			; set up stack pointer (SP)
    OUTI	DDRB,0xff		; configure portC to output
    sei
    IRSET
    rjmp main

main:
    DISTANCEREAD
    LSR2 a1,a0
    LSR2 a1,a0
    com a0
    out PORTC, a0           ; show on led
    rjmp main
    
