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
 *	UTILS.ASM (utility functions)
 *
 */



;FUNCTION: Error(r16)
;
;Takes r16 as argument (error code) and transmits it with byte #1 and #2 pre-set
;
;This is a seperate function to make it easy to modify functionality (ex: kill program on error)
;
;Error codes described in seperate documentation
;
Error:

	sbi		PORTC,1		;Light LED

	push	r18
	push	r17

	ldi		r18,0xBB
	ldi		r17,0x10
	Error_SendByte1:
		sbis	UCSRA,UDRE
		rjmp	Error_SendByte1
		out		UDR,r18
	Error_SendByte2:
		sbis	UCSRA,UDRE
		rjmp	Error_SendByte2
		out		UDR,r17
	Error_SendByte3:
		sbis	UCSRA,UDRE
		rjmp	Error_SendByte3
		out		UDR,r16

	pop		r17
	pop		r18

	cbi		PORTC,1		;Turn off LED

ret



;FUNCTION: Die(void)
;
;Disables interrupts, halts the motor and jams the program
;
Die:
	sbi		PORTC,1
	motor	stop
	Die_Here:
		nop
		rjmp Die_Here	;Watchdog will time out here
ret



;FUNCTION: Idle(void)
;
;Puts the microcontroller to sleep. It wakes up on interrupt
;
Idle:
	push	r16
	ldi		r16,(1<<SE)			;
	out		MCUCR,r16			;Enable sleep (idle mode)
	sleep						;Sleep now - waking on interrupt +4 cycles
	ldi		r16,(0<<SE)			;
	out		MCUCR,r16			;Disable sleep
	pop		r16
ret


