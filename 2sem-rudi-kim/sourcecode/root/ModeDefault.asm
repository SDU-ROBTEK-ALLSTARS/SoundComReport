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
 *	MODEDEFAULT.ASM (Default MODE routine)
 *
 */



ModeDefault:
	wdr		;Reset watchdog timer
	
	;Test mode flag(s)
	sbrs	MODE,MD_DEF
	rjmp	CheckMode				;If mode is no longer Default, go back and check
	sbrs	MODE,MD_SET
	rjmp	ModeDefault_Settings	;If MD_SET bit is not set we want to configure settings
	
	


	;---- DA BOSS: MAKING SURE THE STACK IS NOT FCUKED WITH ----
	in		r16,SPL
	in		r17,SPH
	ldi		r18,low(RAMEND)
	ldi		r19,high(RAMEND)

	;is stackpointer at RAMEND?
	cp		r16,r18
	cpc		r17,r19
	;if equal:
	breq	ModeDefault
	;if not, error
	ldi		r16,0x66	;undocumented
	call	Error
	call	Die
	;-----------------------------------------------------------



rjmp	ModeDefault




;Default mode settings
ModeDefault_Settings:

	sbrs	MODE,MD_DEF
	rjmp	CheckMode	
	

	;When first entering default mode, stop motor:
	motor	stop




	;Set settings flag
	ldi	r16,(1<<MD_SET)
	or	MODE,r16


rjmp	ModeDefault
