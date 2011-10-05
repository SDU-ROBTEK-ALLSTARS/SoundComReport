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
 *	INTERRUPTS.ASM (interrupt routines)
 *
 */



EXT_INT0:						;IRQ0
	reti
EXT_INT1:						;IRQ1
	reti
EXT_INT2:						;IRQ2
	reti
TIM2_COMP:						;Timer2 Compare
	reti
TIM2_OVF:						;Timer2 Overflow
	reti
TIM1_CAPT:						;Timer1 Capture
	reti
TIM1_COMPA:						;Timer1 CompareA
	reti
TIM1_COMPB:						;Timer1 CompareB
	reti
TIM1_OVF:						;Timer1 Overflow
	push	r16
	in		r16,SREG
	push	r16
	


	;Re-enabling comparator interrupt while disabling timer1 overflow interrupt
	in		r16,TIMSK
	andi	r16,~(1<<TOIE1)
	out		TIMSK,r16

	sbi		ACSR,ACIE
	;----------------


	pop		r16
	out		SREG,r16
	pop		r16	
reti



TIM0_COMP:						;Timer0 Compare
	reti


;TIM0_OVF: adns.asm

;SPI_STC: adns.asm

;USART_RXC: comm.asm

;USART_UDRE: comm.asm


USART_TXC:						;USART TX Complete
	reti
ADC_CONV:						;ADC Conversion Complete
	reti
EE_RDY:							;EEPROM Ready
	reti

;ANA_COMP	ana_comp.asm

TWI:							;Two-wire Serial Interface
	reti

SPM_RDY:						;Store Program Memory Ready
	reti
