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
 *	DEBUG.ASM (functions for debugging and gathering information)
 *
 */






Debug_GetStackPointer:
	push	r16
	in		r16,SREG
	push	r16
	push	r17


	in		r17,SPH
	in		r16,SPL

	Debug_GetStackPointer_Send1:
		sbis	UCSRA,UDRE
		rjmp	Debug_GetEvtTblEnds_Send1
	out		UDR,r17
	Debug_GetStackPointer_Send2:
		sbis	UCSRA,UDRE
		rjmp	Debug_GetEvtTblEnds_Send2
	out		UDR,r16


	pop		r17
	pop		r16
	out		SREG,r16
	pop		r16	
ret





Debug_GetADNSTbl: ;returns ADNS data through UART   ** BEWARE: THIS TAKES A LOT OF CPU TIME**
	push	r16
	in		r16,SREG
	push	r16
	push	XH
	push	XL
	push	r24
	push	r25

	;Setting pointer at start of EVTTBL
	ldi 	XH,high(ADNS_DATA)
	ldi		XL,low(ADNS_DATA)

	;Set end address
	ldi		r25,high(ADNS_DATA)
	ldi		r24,low(ADNS_DATA)	
	adiw	r25:r24,22				;Rudi says the ADNS data package is 19 bytes long

	;Load data from data space and spam through UART until we've send the whole table:
	Debug_GetADNSTbl_Loop:
	;wdr
		ld		r16,X+
		Debug_GetADNSTbl_Loop_Send:
			sbis	UCSRA,UDRE
			rjmp	Debug_GetADNSTbl_Loop_Send
		out		UDR,r16
		
		;Compare END bytes with pointer value
		cp		r24,XL
		cpc		r25,XH
		brsh	Debug_GetADNSTbl_Loop

		;If X is the same or lower, we've got all the data we wanted

	Debug_GetADNSTbl_Exit:
	pop		r25
	pop		r24
	pop		XL
	pop		XH
	pop		r16
	out		SREG,r16
	pop		r16	
ret



Debug_GetEvtTbl: ;returns the whole EVTTBL (as recorded during MD_WARM) through UART   ** BEWARE: THIS TAKES A LOT OF CPU TIME**
	push	r16
	in		r16,SREG
	push	r16
	push	XH
	push	XL
	push	r24
	push	r25

	;Setting pointer at start of EVTTBL
	ldi 	XH,high(EVTTBL)
	ldi		XL,low(EVTTBL)

	;Get EVTTBL end address
	lds		r25,EVTTBL_ENDHI
	lds		r24,EVTTBL_ENDLO

	;If(end=0000 || end=EVTTBL){break operation}
	ldi		r16,high(EVTTBL)
	cpi		r24,low(EVTTBL)
	cpc		r25,r16
	breq	Debug_GetEvtTbl_NoData

	ldi		r16,0x00
	cpi		r24,0x00
	cpc		r25,r16
	breq	Debug_GetEvtTbl_NoData
	
	;Load data from data space and spam through UART until we've sent the whole table
	Debug_GetEvtTbl_Loop:
		wdr
		ld		r16,X+
		Debug_GetEvtTbl_Loop_Send:
			sbis	UCSRA,UDRE
			rjmp	Debug_GetEvtTbl_Loop_Send
			out		UDR,r16
		
		;Compare END bytes with pointer value
		cp		r24,XL
		cpc		r25,XH
		brne	Debug_GetEvtTbl_Loop
	rjmp	Debug_GetEvtTbl_Exit
	;If X is the same or lower, we've got all the data we wanted

	Debug_GetEvtTbl_NoData:
		ldi		r16,0x00
		Debug_GetEvtTbl_NoData_Send:
			sbis	UCSRA,UDRE
			rjmp	Debug_GetEvtTbl_NoData_Send
			out		UDR,r16	
		rjmp	Debug_GetEvtTbl_Exit

	Debug_GetEvtTbl_Exit:
	pop		r25
	pop		r24
	pop		XL
	pop		XH
	pop		r16
	out		SREG,r16
	pop		r16	
ret



Debug_GetEvtTblEnds:	;returns the EVTTBL_ENDHI and EVTTBL_ENDLO memory data through UART
	push	r24
	push	r25
	lds		r25,EVTTBL_ENDHI
	lds		r24,EVTTBL_ENDLO
	Debug_GetEvtTblEnds_Send1:
		sbis	UCSRA,UDRE
		rjmp	Debug_GetEvtTblEnds_Send1
		out		UDR,r25
	Debug_GetEvtTblEnds_Send2:
		sbis	UCSRA,UDRE
		rjmp	Debug_GetEvtTblEnds_Send2
		out		UDR,r24
	pop		r25
	pop		r24
ret




Debug_BurstADCVals:
	push	r16
	in		r16,SREG
	push	r16
	push	r17

	
	sbi		ADCSRA,ADSC

	ldi		r17,10

	Debug_BurstADCVals_NewConv:

		sbic	ADCSRA,ADSC
		rjmp	Debug_BurstADCVals_NewConv

		in		r16,ADCH

		sbi		ADCSRA,ADSC	


		Debug_BurstADCVals_Send:
			sbis	UCSRA,UDRE
			rjmp	Debug_BurstADCVals_Send

			out		UDR,r16

		dec		r17
		brne	Debug_BurstADCVals_NewConv


	pop		r17
	pop		r16
	out		SREG,r16
	pop		r16	
ret




Debug_GetDrvTbl:
	nop
ret
