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
.include "printf.asm"
.include "uart.asm"	

reset:
	OUTI	DDRC,0xff		; configure portC to output
    LDSP	RAMEND			; set up stack pointer (SP)
	rcall	UART0_init
    sei
    IRSET
    rjmp main

main:
	
    DISTANCEREAD            ; read distance in b1:b0
    WAIT_MS 100
    PRINTF	UART0_putc		; print formatted
	.db	CR,CR,"CACA=",FHEX2,b,"=",FDEC2,b,"    ",0
    LSR2 b1,b0
    LSR2 b1,b0
    out PORTC, b0
    rjmp main