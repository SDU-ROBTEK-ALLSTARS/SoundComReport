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
 *	DRVACTIONS.ASM
 *
 */



/*
 *
 *	TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST
 *	TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST
 *	TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST
 */



;********************
;* BEGIN DRVACTIONS *
;********************




DrvActions_PreStraight:
DrvActions_Straight:



DrvActions_PreRight45:
DrvActions_Right45:

DrvActions_PreLeft45:
DrvActions_Left45:



DrvActions_PreRight90:
DrvActions_Right90:

DrvActions_PreLeft90:
DrvActions_Left90:



DrvActions_PreRight135:
DrvActions_Right135:

DrvActions_PreLeft135:
DrvActions_Left135:



DrvActions_PreRight180:
DrvActions_Right180:

DrvActions_PreLeft180:
DrvActions_Left180:



DrvActions_PreRight225:
DrvActions_Right225:

DrvActions_PreLeft225:
DrvActions_Left225:



DrvActions_PreRight270:
DrvActions_Right270:

DrvActions_PreLeft270:
DrvActions_Left270:





DrvActions_Error:

;********************
;* END DRVACTIONS *
;********************









;*************************
;* DRVACTIONS JUMP-TABLE *
;*************************

DRVACTIONS:
	rjmp	DrvActions_Error		;00

	rjmp	DrvActions_Straight		;01
	rjmp	DrvActions_Right45		;02
	rjmp	DrvActions_Left45		;03
	rjmp	DrvActions_Right90		;04
	rjmp	DrvActions_Left90		;05
	rjmp	DrvActions_Right135		;06
	rjmp	DrvActions_Left135		;07
	rjmp	DrvActions_Right180		;08
	rjmp	DrvActions_Left180		;09
	rjmp	DrvActions_Right225		;0A
	rjmp	DrvActions_Left225		;0B
	rjmp	DrvActions_Right270		;0C
	rjmp	DrvActions_Left270		;0D

	rjmp	DrvActions_Error		;0E
	rjmp	DrvActions_Error		;0F
	rjmp	DrvActions_Error		;10

	rjmp	DrvActions_PreStraight		;11
	rjmp	DrvActions_PreRight45		;12
	rjmp	DrvActions_PreLeft45		;13
	rjmp	DrvActions_PreRight90		;14
	rjmp	DrvActions_PreLeft90		;15
	rjmp	DrvActions_PreRight135		;16
	rjmp	DrvActions_PreLeft135		;17
	rjmp	DrvActions_PreRight180		;18
	rjmp	DrvActions_PreLeft180		;19
	rjmp	DrvActions_PreRight225		;1A
	rjmp	DrvActions_PreLeft225		;1B
	rjmp	DrvActions_PreRight270		;1C
	rjmp	DrvActions_PreLeft270		;1D

;*****************************
;* END DRVACTIONS JUMP-TABLE *
;*****************************
