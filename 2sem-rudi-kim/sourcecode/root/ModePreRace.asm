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
 *	MODEPRERACE.ASM (Pre-race MODE routine)
 *
 */



ModePreRace:
	wdr		;Reset watchdog timer

	;Test mode flag(s)		
	sbrs	MODE,MD_PRERACE
	rjmp	CheckMode				;If mode is no longer Auto (Pre Race), go back and check
	sbrs	MODE,MD_SET
	rjmp	ModePreRace_Settings	;If MD_SET bit is not set we want to configure settings



	nop



rjmp	ModePreRace




;Race mode settings
ModePreRace_Settings:

	sbrs	MODE,MD_PRERACE
	rjmp	CheckMode


	;Store end of EVTTBL as gathered during Warmup mode
	sts		EVTTBL_ENDHI,ZH
	sts		EVTTBL_ENDLO,ZL


	;Debug/test
	motor	stop
	delay	5/10
	call	Debug_GetEvtTblEnds
	call	Debug_GetEvtTbl
	;----------
	


	;Set settings flag
	ldi	r16,(1<<MD_SET)
	or	MODE,r16


rjmp	ModePreRace


