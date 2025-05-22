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
	OUTI	DDRC,0xff		; configure portC to output
	rjmp RESET
    LDSP	RAMEND			; set up stack pointer (SP)
    
    sei
    IRSET
    rjmp main

main:
	;OUTI PORTC, 0x00
	;WAIT_MS 1000
	;OUTI PORTC, 0XFF
	;WAIT_MS 1000
	;rjmp main
    DISTANCEREAD
    LSR2 a1,a0
    LSR2 a1,a0
    com a0
    out PORTC, a0           ; show on led
    rjmp main
    
