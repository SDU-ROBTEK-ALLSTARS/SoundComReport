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
 *	MODERACE.ASM (Race MODE routine)
 *
 */



ModeRace:
	wdr		;Reset watchdog timer

	;Test mode flag(s)		
	sbrs	MODE,MD_RACE
	rjmp	CheckMode			;If mode is no longer Auto (Race), go back and check
	sbrs	MODE,MD_SET
	rjmp	ModeRace_Settings	;If MD_SET bit is not set we want to configure settings



	nop



rjmp	ModeRace




;Race mode settings
ModeRace_Settings:

	sbrs	MODE,MD_RACE
	rjmp	CheckMode





	;Set settings flag
	ldi	r16,(1<<MD_SET)
	or	MODE,r16


rjmp	ModeRace


