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
 *	ANA_COMP.ASM (the analog comparator interrupt routine)
 *
 */


ANA_COMP:						;Analog Comparator
	push	r16
	in		r16,SREG
	push	r16
	push	r17



	;Interrupt does different things depending on mode
	sbrc	MODE,MD_RACE
	rjmp	ANA_COMP_ModeRace
	sbrc	MODE,MD_WARM
	rjmp	ANA_COMP_ModeWarmup
	sbrc	MODE,MD_PREWARM
	rjmp	ANA_COMP_ModePreWarmup
	sbrc	MODE,MD_PRERACE
	rjmp	ANA_COMP_ModePreRace
	sbrc	MODE,MD_DEF
	rjmp	ANA_COMP_ModeDefault

	ANA_COMP_Error:
	ldi		r16,0x02
	call	Error
	call	Die






	ANA_COMP_ModeDefault:

		nop

		rjmp	ANA_COMP_Exit




	ANA_COMP_ModeRace:

		;Reset position

		rjmp	ANA_COMP_Exit




	ANA_COMP_ModeWarmup:

		;While in Warmup mode, crossing the finish line sets Pre-Race mode
		ldi		r16,(1<<MD_PRERACE)
		mov		MODE,r16


		rjmp	ANA_COMP_Exit




	ANA_COMP_ModePreWarmup:

		;While in Pre-warmup mode, crossing the finish line sets Warmup mode
		ldi		r16,(1<<MD_WARM)
		mov		MODE,r16


		rjmp	ANA_COMP_Exit


	ANA_COMP_ModePreRace:

		;While in Pre-Race mode, crossing the finish line sets Race mode
		ldi		r16,(1<<MD_RACE)
		mov		MODE,r16


		rjmp	ANA_COMP_Exit




	ANA_COMP_Exit:

	;DELAY: This will disable the comparator interrupt until Timer1 overflows (appr. 0.9 second)
	cbi		ACSR,ACIE

	in		r16,TIMSK
	ori		r16,(1<<TOIE1)
	out		TIMSK,r16

	ldi		r17,high(10000)
	ldi		r16,low(10000)
	out		TCNT1H,r17
	out		TCNT1L,r16		;The delay is: ((65535-(r17:r16))*prescale / Fosc)

	ldi		r16,(1<<TOV1)	;IMPORTANT IMPORTANT! If the TOV1 flag was already set (it seems to
	out		TIFR,r16		; get set when enabling TOIE1), we clear it here by writing logic 1 to it
	;END DELAY

	pop		r17
	pop		r16
	out		SREG,r16
	pop		r16
reti
