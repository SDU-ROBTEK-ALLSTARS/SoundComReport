/*
 *	This file is a part of the "Pole Position" Scalextric Toy Car program, a 2. semester project (Robot Systems Engineering)
 *
 *	Copyright (C) 2011 Rudi Hansen, Kim Schwaner, Niels Høgh, Kelvin Pagels, Faculty of Engineering, University of Southern Denmark
 *
 *	"Pole Position" is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/*
 *	MAIN.ASM (global definitions, reset/boot routine, gathering point for all other files to assemble)
 *
 */


;********************************
;BEGIN GLOBAL DEFINITIONS
;
.include "m32Adef.inc"

;Mode register and bit designations
.def MODE = r8
.equ MD_DEF = 0
.equ MD_WARM = 1
.equ MD_RACE = 2
.equ MD_PREWARM = 3
.equ MD_PRERACE = 4
.equ MD_SET = 7		;Settings flag

;USART COUNTER/BUFFER
.equ RXCOUNT = $60		;Receive counter register
.equ TXCOUNT = $61		;Transmit counter register
.equ USART_RX_1 = $62
.equ USART_RX_2 = $63
.equ USART_TX_1 = $64
.equ USART_TX_2 = $65
.equ USART_TX_3 = $66

;Memory manipulation pointer address (see memory macro + telegram instruction)
.equ MEMLO = $67
.equ MEMHI = $68

;Where ADNS_DATA is in memory space
.equ ADNS_DATA = $70
.equ ADNS_DATA_LAST = ADNS_DATA + 7; Data from last data poll
.equ ADNS_PIN_NCS = 2;


.equ SPEED_CALC = $90


;EVTTBL start in memory space
.equ EVTTBL = $100

;We save EVTTBL end address just before EVTTBL itself
.equ EVTTBL_ENDHI = EVTTBL-1
.equ EVTTBL_ENDLO = EVTTBL-2

;We save DRVTBL end address just before the EVTTBL end address
.equ DRVTBL_ENDHI = EVTTBL-3
.equ DRVTBL_ENDLO = EVTTBL-4
.equ DRVTBL_STRTHI = EVTTBL-5
.equ DRVTBL_STRTLO = EVTTBL-6

;END DEFINITIONS
;********************************



;********************************
;MACROS
;
.include "macros.asm"

;END MACROS
;********************************



;********************************
;RESET/INTERRUPT VECTOR ADDRESSES
;
.org 0x0000	jmp	RESET			;Reset
.org 0x0002	jmp	EXT_INT0		;IRQ0
.org 0x0004	jmp	EXT_INT1		;IRQ1
.org 0x0006	jmp	EXT_INT2		;IRQ2
.org 0x0008	jmp	TIM2_COMP		;Timer2 Compare
.org 0x000A	jmp	TIM2_OVF		;Timer2 Overflow
.org 0x000C	jmp	TIM1_CAPT		;Timer1 Capture
.org 0x000E	jmp	TIM1_COMPA		;Timer1 CompareA
.org 0x0010	jmp	TIM1_COMPB		;Timer1 CompareB
.org 0x0012	jmp	TIM1_OVF		;Timer1 Overflow
.org 0x0014	jmp	TIM0_COMP		;Timer0 Compare
.org 0x0016	jmp	TIM0_OVF		;Timer0 Overflow
.org 0x0018	jmp	SPI_STC			;SPI Transfer Complete
.org 0x001A	jmp	USART_RXC		;USART RX Complete
.org 0x001C	jmp	USART_UDRE		;UDR Empty
.org 0x001E	jmp	USART_TXC		;USART TX Complete
.org 0x0020	jmp	ADC_CONV		;ADC Conversion Complete
.org 0x0022	jmp	EE_RDY			;EEPROM Ready
.org 0x0024	jmp	ANA_COMP		;Analog Comparator
.org 0x0026	jmp	TWI				;Two-wire Serial Interface
.org 0x0028	jmp	SPM_RDY			;Store Program Memory Ready

;END VECTORS
;********************************



;********************************
;RESET
;Configuration before the main part of the program is reached.
;
RESET:
;Stack pointer
	ldi		r16,high(RAMEND)
	out		SPH,r16
	ldi		r16,low(RAMEND)
	out		SPL,r16

;Status LED ON (to be cleared when boot is succesful and then used as an error-signal)
	sbi		DDRC,1
	sbi		PORTC,1

;Motor PWM (TIMER2): Phase-Correct mode. No pre-scaling. Clear OC2 on compare match when up-counting. Set OC2 on compare match when downcounting.
	sbi		DDRD,7	;OC2 is Port D, pin 7

	ldi		r16,(1<<WGM20)|(1<<COM21)|(1<<CS20)
	out		TCCR2,r16

;USART settings
	ldi		r17,0
	ldi		r16,103
	out		UBRRH,r17
	out		UBRRL,r16			;103 decimal to set baud rate to 9600 cf. p. 151 ATMega32A datasheet

	ldi		r16,(1<<URSEL)|(1<<UCSZ1)|(1<<UCSZ0)
	out		UCSRC,r16			;Asynchronous operation. Parity mode disabled. 1-bit stop bit. 8-bit data.

	ldi		r16,(1<<RXCIE)|(1<<RXEN)|(1<<TXEN)
	out		UCSRB,r16			;Enable recieve complete interrupt. + Enable transmitter and reciever

;ADC settings
	ldi		r16,(1<<ADEN)|(1<<ADSC)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);|(1<<ADATE)
	out		ADCSRA,r16			;ADC enable, 125 KHz ADC clock, conversion start(this will initialize the ADC, making following conversions quicker)

	ldi		r16,(1<<ADLAR)		;
	out		ADMUX,r16			;Reference = Aref (5V), input=ADC0, left-adjusted

;TIMER0 (for ADNS)
	ldi		r16,(1<<CS02)		;256 Prescale, Normal mode
	out		TCCR0,r16			;

;TIMER1 (Comp. interrupt delay)
	ldi		r16,(1<<CS12)
	out		TCCR1B,r16			;Normal mode 256 prescale

;COMPARATOR (for optocoupler)
	ldi		r16,(1<<ACIS1)|(1<<ACIS0)|(1<<ACIE)
	out		ACSR,r16			;Interrupt on rising edge

;H-bridge pinouts
	sbi		DDRC,4				;
	sbi		DDRC,5				;Setting pinouts for H bridge

;Motor is stopped on reset
	motor	stop

;Delay 5 seconds to give us time to connect via bluetooth to ease debugging - we can disable this in a stable build
	delay	5

;Check if a watchdog reset occurred (do this before ADNS config)
	in		r16,MCUCSR
	sbrc	r16,WDRF
	rjmp	RESET_Watchdog
	rjmp	RESET_NormalOp	

	RESET_Watchdog:
	ldi		r16,(0<<WDRF)
	out		MCUCSR,r16		;Clear the watchdog reset flag
	ldi		r16,0x05
	call	Error			;Call error then resume operation
	rjmp	RESET_NormalOp

	RESET_NormalOp:

;Watchdog enable on a ~1 second time-out
	ldi		r16,(1<<WDE)|(1<<WDP2)|(1<<WDP1)
	out		WDTCR,r16

;Initialize EVTTBL+DRVTBL END-adresses and RX/TX-counter to 0x00
	ldi		r16,0x00
	sts		EVTTBL_ENDHI,r16
	sts		EVTTBL_ENDLO,r16
	sts		DRVTBL_ENDHI,r16
	sts		DRVTBL_ENDLO,r16
	sts		DRVTBL_STRTHI,r16
	sts		DRVTBL_STRTLO,r16
	sts		RXCOUNT,r16
	sts		TXCOUNT,r16

;ADNS sensor setup
	call	ADNSconfig		;SPI configuration for ADNS sensor and memory cleanup.
	call	adns_boot		;Boots the sensor and tests for faults

;Set MODE to default
	ldi		r16,(1<<MD_DEF)
	mov		MODE,r16

;Global interrupt enable
	sei

;Turn off status LED now we're done configuring
	cbi		PORTC,1

rjmp	Main

;END RESET
;********************************



;********************************
;INCLUDES
;
.include "adns9500/adns_spi.asm"
.include "adns9500/adns_aux.asm"
.include "adns9500/adns_run.asm"
.include "speedcalculation.asm"
.include "interrupts.asm"
.include "ana_comp.asm"
.include "comm.asm"
.include "commactions.asm"
.include "utils.asm"
.include "debug.asm"
.include "ModeDefault.asm"
.include "ModePreWarmup.asm"
.include "ModeWarmup.asm"
.include "ModeRace.asm"
.include "ModePreRace.asm"

;END INCLUDES
;********************************



Main:

	rjmp	CheckMode





CheckMode:

	ldi		r16,~(1<<MD_SET)	;When we change mode we want to re-adjust settings to that particular mode,
	and		MODE,r16			;thus the MD_SET (bit 7) is cleared while maintaining the rest of the MODE register
	
	sbrc	MODE,MD_RACE
	rjmp	ModeRace

	sbrc	MODE,MD_WARM
	rjmp	ModeWarmup

	sbrc	MODE,MD_PREWARM
	rjmp	ModePreWarmup

	sbrc	MODE,MD_PRERACE
	rjmp	ModePreRace

	sbrc	MODE,MD_DEF
	rjmp	ModeDefault


	;On error, do:
	ldi		r16,0x01		;error code
	call	Error
	call	Die



;Including ADNS firmware down here since it's quite large (3kbytes)
.include "adns9500/adns_firmware.asm"

