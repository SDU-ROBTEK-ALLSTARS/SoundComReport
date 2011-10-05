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
 *	BUILDDRVTBL.ASM
 *
 */




/*
 *	KIM TESTER KIM TESTER KIM TESTER KIM TESTER KIM TESTER 
 *	KIM TESTER KIM TESTER KIM TESTER KIM TESTER KIM TESTER 
 *
 */





;X-pointer for getting EVTTBL data

;Y-pointer for writing DRVTBL



.def	turnStsT	= r25
.def	posHiT		= r24
.def	posMidHiT	= r23
.def	posMidLoT	= r22
.def	posLoT		= r21

.def	turnStsB	= r20
.def	posHiB		= r19
.def	posMidHiB	= r18
.def	posMidLoB	= r17
.def	posLoB		= r16

.def	turnStsA	= r15
.def	posHiA		= r14
.def	posMidHiA	= r13
.def	posMidLoA	= r12
.def	posLoA		= r11


.def	calcDir		= r10
.equ	AtoB		= 1
.equ	BtoA		= 2


.equ	ActOffset	= 00000009



BuildDrvTbl:
	push	r16
	in		r16,SREG
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21
	push	r22
	push	r23
	push	r24
	push	r25
	push	r26
	push	r27
	push	r28
	push	r29
	push	r30
	push	r31
	push	r15
	push	r14
	push	r13
	push	r12
	push	r11
	push	r10
	

	clr		calcDir	;er du sikker Kim?

	;Point to EVTTBL and DRVTBL
	ldi		XH,high(EVTTBL)
	ldi		XL,low(EVTTBL)

	lds		YH,EVTTBL_ENDHI
	lds		YL,EVTTBL_ENDLO
	adiw	YH:YL,2				;DRVTBL gets positioned 2 bytes after EVTTBL end

	sts		DRVTBL_STRTHI,YH
	sts		DRVTBL_STRTLO,YL	;For future reference we write the DRVTBL starting address here




	;Initial load
	ld		posHiA,X+
	ld		posMidHiA,X+
	ld		posMidLoA,X+
	ld		posLoA,X+
	ld		turnStsA,X+

	ld		posHiB,X+
	ld		posMidHiB,X+
	ld		posMidLoB,X+
	ld		posLoB,X+
	ld		turnStsB,X+




		;calcDir: B to A


	mov		turnStsT,turnStsB

	sub		turnStsT,turnStsA

	cpi		turnStsT,0x01
	breq	BuildDrvTbl_StraightToLeftTurn
	cpi		turnStsT,0x03
	breq	BuildDrvTbl_StraightToRightTurn
	cpi		turnStsT,0xFF
	breq	BuildDrvTbl_LeftTurnToStraight
	cpi		turnStsT,0xFD
	breq	BuildDrvTbl_RightTurnToStraight	

	ldi		r16,0x40
	call	Error
	call	Die

	
	BuildDrvTbl_StraightToLeftTurn:

	BuildDrvTbl_StraightToRightTurn:



	BuildDrvTbl_LeftTurnToStraight:

	BuildDrvTbl_RightTurnToStraight:







	mov		posHiT,posHiB
	mov		posMidHiT,posMidHiB
	mov		posMidLoT,posMidLoB
	mov		posLoT,posLoB


	sub		posLoT,posLoA
	sbc		posMidLoT,posMidLoA
	sbc		posMidHiT,posMidHiA
	sbc		posHiT,posHiA

/*

.equ STRAIGHT = 0
.equ LEFTTURN = 1
.equ RIGHTTURN = 2

(bit# !!)

*/






	BuildDrvTbl_Exit:
	pop		r10
	pop		r11
	pop		r12
	pop		r13
	pop		r14
	pop		r15
	pop		r31
	pop		r30
	pop		r29
	pop		r28
	pop		r27
	pop		r26
	pop		r25
	pop		r24
	pop		r23
	pop		r22
	pop		r21
	pop		r20
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	out		SREG,r16
	pop		r16
ret
