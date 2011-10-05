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
 *	MODEWARMUP.ASM (Warm-up MODE routine: Measures the track for use in Race MODE)
 *
 */




; With 128 ADC clock downscale we can get a conversion rate of 125 KHz.
; Each ADC conversion takes 13*128=1664 cycles
; That is one save every 1 millisecond at the most (as long as the save procedure doesn't take longer than the conversion)



.def ADCCOUNT			= r21	;locally reserved
.def LASTTURNSTS		= r22	;locally reserved
.def TURNSTS			= r23	;locally reserved
.equ STRAIGHT			= 0
.equ LEFTTURN			= 1
.equ RIGHTTURN			= 2

;These can be adjusted to fine-tune performance:
.equ TRNTHRSLOW			= 119
.equ TRNTHRSHIGH		= 140

.equ ADCERRORMARG		= 10	;We need ADCERRORMARG number of ADC measurements going in the same "direction" to trigger a turn-event
								;even so, we still never save two of the same events in a row!

ModeWarmup:
	wdr		;Reset watchdog timer
	

	sbrs	MODE,MD_WARM
	rjmp	CheckMode				;If mode is no longer Auto (Warmup), go back and check
	sbrs	MODE,MD_SET
	rjmp	ModeWarmup_Settings		;If MD_SET bit is not set we want to configure settings




	
	;We wait for a conversion to be done (the first is triggered in ModeWarmup_Settings)
	ModeWarmup_ADC_Wait:
		sbic	ADCSRA,ADSC
		rjmp	ModeWarmup_ADC_Wait

	in		r16,ADCH			;Get data

	sbi		ADCSRA,ADSC			;Start new ADC conversion (each will take 13*divisor cpu cycles)


	;Check current ADC value against turn-thresholds
	cpi		r16,TRNTHRSHIGH
	brsh	ModeWarmup_Right

	cpi		r16,TRNTHRSLOW
	brlo	ModeWarmup_Left
	


	;If not going left or right, we are moving straight ahead
	ModeWarmup_Straight:

		sbrc	TURNSTS,STRAIGHT
		rjmp	ModeWarmup_Straight_FlagSet_ChkCount
														;if (FLAG != STRAIGHT){

		ModeWarmup_Straight_RstCount_SetFlag:
			
			clr		ADCCOUNT									;COUNT=0
			ldi		TURNSTS,(1<<STRAIGHT)						;FLAG = STRAIGHT
			cp		TURNSTS,LASTTURNSTS							;if (current TURNSTS = last TURNSTS){
			breq	ModeWarmup										;go back and get new reading, this is a duplicate event
			;cli												;} else {
			lds		r10,(ADNS_DATA+1)	;pos Hi2
			lds		r11,(ADNS_DATA+2)	;pos Hi1				;LOAD CURRENT POSITION
			lds		r12,(ADNS_DATA+3)	;pos Hi0
			lds		r13,(ADNS_DATA+4)	;pos Lo2				;COUNT++
			lds		r14,(ADNS_DATA+5)	;pos Lo1
			lds		r15,(ADNS_DATA+6)	;pos Lo0				;return and get new reading
			;sei
			inc		ADCCOUNT
			
			rjmp	ModeWarmup


		ModeWarmup_Straight_FlagSet_ChkCount:			;} else {

			cpi		ADCCOUNT,ADCERRORMARG						;if (COUNT = ADCERRORMARG){
			breq	ModeWarmup_Save									;go save readings
			brlo	ModeWarmup_Straight_FlagSet_IncCount		;} elseif (COUNT > ADCERRORMARG){
			rjmp	ModeWarmup										;return and get new reading

		ModeWarmup_Straight_FlagSet_IncCount:					;} else {

			inc		ADCCOUNT										;COUNT++
	
			rjmp	ModeWarmup										;return and get new reading

																;}
														;}




	ModeWarmup_Right:

		sbrc	TURNSTS,RIGHTTURN
		rjmp	ModeWarmup_Right_FlagSet_ChkCount


		ModeWarmup_Right_RstCount_SetFlag:
			
			clr		ADCCOUNT
			ldi		TURNSTS,(1<<RIGHTTURN)
			cp		TURNSTS,LASTTURNSTS
			breq	ModeWarmup_Detour
			;cli
			lds		r10,(ADNS_DATA+1)
			lds		r11,(ADNS_DATA+2)
			lds		r12,(ADNS_DATA+3)
			lds		r13,(ADNS_DATA+4)
			lds		r14,(ADNS_DATA+5)
			lds		r15,(ADNS_DATA+6)
			;sei
			inc		ADCCOUNT
			
			rjmp	ModeWarmup


		ModeWarmup_Right_FlagSet_ChkCount:

			cpi		ADCCOUNT,ADCERRORMARG
			breq	ModeWarmup_Save
			brlo	ModeWarmup_Right_FlagSet_IncCount
			rjmp	ModeWarmup

		ModeWarmup_Right_FlagSet_IncCount:

			inc		ADCCOUNT

			rjmp	ModeWarmup





	ModeWarmup_Detour:

		rjmp ModeWarmup		;breq will only get us so far







	ModeWarmup_Left:

		sbrc	TURNSTS,LEFTTURN
		rjmp	ModeWarmup_Left_FlagSet_ChkCount


		ModeWarmup_Left_RstCount_SetFlag:
			
			clr		ADCCOUNT
			ldi		TURNSTS,(1<<LEFTTURN)
			cp		TURNSTS,LASTTURNSTS
			breq	ModeWarmup_Detour
			;cli
			lds		r10,(ADNS_DATA+1)
			lds		r11,(ADNS_DATA+2)
			lds		r12,(ADNS_DATA+3)
			lds		r13,(ADNS_DATA+4)
			lds		r14,(ADNS_DATA+5)
			lds		r15,(ADNS_DATA+6)
			;sei
			inc		ADCCOUNT
			
			rjmp	ModeWarmup


		ModeWarmup_Left_FlagSet_ChkCount:

			cpi		ADCCOUNT,ADCERRORMARG
			breq	ModeWarmup_Save
			brlo	ModeWarmup_Left_FlagSet_IncCount
			rjmp	ModeWarmup
	
		ModeWarmup_Left_FlagSet_IncCount:

			inc		ADCCOUNT

			rjmp	ModeWarmup





	ModeWarmup_Save:	
		st		Z+,r10		;Saving position
		st		Z+,r11
		st		Z+,r12
		st		Z+,r13
		st		Z+,r14
		st		Z+,r15
		st		Z+,TURNSTS	;..and TURNSTS

		inc		ADCCOUNT	;Increase count as to stop saving more of the "same" turn-states

		mov		LASTTURNSTS,TURNSTS		;Remember what this turn was

		;Test to make sure we don't overflow the memory if something unexpected happens
		ldi		r18,high($400)
		cpi		ZL,low($400)		;300 bytes is 300/7=57 events (=28 turns) - that should be plenty to go on
		cpc		ZH,r18
		brsh	ModeWarmup_Error_EvtTblOvrflw

		rjmp	ModeWarmup



		ModeWarmup_Error_EvtTblOvrflw:
			;Saving table end (current pointer value) adress at designated adress
			sts		EVTTBL_ENDHI,ZH
			sts		EVTTBL_ENDLO,ZL

			ldi		r16,0x31
			call	Error
			call	Debug_GetEvtTblEnds
			call	Debug_GetEvtTbl
			call	Die





rjmp	ModeWarmup










;Warm up mode settings
ModeWarmup_Settings:

	sbrs	MODE,MD_WARM
	rjmp	CheckMode

	;Empty the ADC result register and start new ADC conversion
	in		r16,ADCH
	sbi		ADCSRA,ADSC

	;Start motor
	ldi		r16,185
	motor	forward,r16

	;Init TURNSTS and ADCCOUNT
	clr		TURNSTS
	clr		ADCCOUNT
	clr		LASTTURNSTS

	;Setting Z pointer for use in ModeWarmup
	ldi 	ZH,high(EVTTBL)
	ldi		ZL,low(EVTTBL)


	;Set settings flag
	ldi	r16,(1<<MD_SET)
	or	MODE,r16

rjmp	ModeWarmup









;	-------------------
;	CURRENTLY NOT USED:
;	-------------------

/*

	;We wait for a conversion to be done (the first is triggered in ModeWarmup_Settings)
	ModeWarmup_ADC_Wait:
		sbic	ADCSRA,ADSC
		rjmp	ModeWarmup_ADC_Wait

	in		r16,ADCH			;Get data

	sbi		ADCSRA,ADSC			;Start new ADC conversion (each will take 13*divisor cpu cycles)


	;Check current ADC value against turn-thresholds
	cpi		r16,TRNTHRSHIGH
	brsh	ModeWarmup_Right

	cpi		r16,TRNTHRSLOW
	brlo	ModeWarmup_Left
	

	;If not going left or right, we are moving straight ahead:

	ModeWarmup_Straight:

		sbrc	TURNSTS,STRAIGHT
		rjmp	ModeWarmup_Straight_FlagSet_ChkCount
														;if (FLAG != STRAIGHT){

		ModeWarmup_Straight_RstCount_SetFlag:
			
			clr		ADCCOUNT								;COUNT=0
			ldi		TURNSTS,(1<<STRAIGHT)					;FLAG = STRAIGHT
			;cli
			lds		r10,(ADNS_DATA+1)	;pos Hi2
			lds		r11,(ADNS_DATA+2)	;pos Hi1
			lds		r12,(ADNS_DATA+3)	;pos Hi0
			lds		r13,(ADNS_DATA+4)	;pos Lo2
			lds		r14,(ADNS_DATA+5)	;pos Lo1
			lds		r15,(ADNS_DATA+6)	;pos Lo0			;LOAD CURRENT POSITION
			;sei
			inc		ADCCOUNT								;COUNT++
			
			rjmp	ModeWarmup								;return and get new reading


		ModeWarmup_Straight_FlagSet_ChkCount:			;} else {

			cpi		ADCCOUNT,ADCERRORMARG						;if (COUNT = ADCERRORMARG){
			breq	ModeWarmup_Save									;save values
			brlo	ModeWarmup_Straight_FlagSet_IncCount		;} elseif (COUNT > ADCERRORMARG){
			rjmp	ModeWarmup										;return and get new reading

		ModeWarmup_Straight_FlagSet_IncCount:					;} else {

			inc		ADCCOUNT										;COUNT++
	
			rjmp	ModeWarmup										;return and get new reading

																;}
														;}



	ModeWarmup_Right:

		sbrc	TURNSTS,RIGHTTURN
		rjmp	ModeWarmup_Right_FlagSet_ChkCount


		ModeWarmup_Right_RstCount_SetFlag:
			
			clr		ADCCOUNT
			ldi		TURNSTS,(1<<RIGHTTURN)
			;cli
			lds		r10,(ADNS_DATA+1)
			lds		r11,(ADNS_DATA+2)
			lds		r12,(ADNS_DATA+3)
			lds		r13,(ADNS_DATA+4)
			lds		r14,(ADNS_DATA+5)
			lds		r15,(ADNS_DATA+6)
			;sei
			inc		ADCCOUNT
			
			rjmp	ModeWarmup


		ModeWarmup_Right_FlagSet_ChkCount:

			cpi		ADCCOUNT,ADCERRORMARG
			breq	ModeWarmup_Save
			brlo	ModeWarmup_Right_FlagSet_IncCount
			rjmp	ModeWarmup

		ModeWarmup_Right_FlagSet_IncCount:

			inc		ADCCOUNT

			rjmp	ModeWarmup






	ModeWarmup_Left:

		sbrc	TURNSTS,LEFTTURN
		rjmp	ModeWarmup_Left_FlagSet_ChkCount


		ModeWarmup_Left_RstCount_SetFlag:
			
			clr		ADCCOUNT
			ldi		TURNSTS,(1<<LEFTTURN)
			;cli
			lds		r10,(ADNS_DATA+1)
			lds		r11,(ADNS_DATA+2)
			lds		r12,(ADNS_DATA+3)
			lds		r13,(ADNS_DATA+4)
			lds		r14,(ADNS_DATA+5)
			lds		r15,(ADNS_DATA+6)
			;sei
			inc		ADCCOUNT
			
			rjmp	ModeWarmup


		ModeWarmup_Left_FlagSet_ChkCount:

			cpi		ADCCOUNT,ADCERRORMARG
			breq	ModeWarmup_Save
			brlo	ModeWarmup_Left_FlagSet_IncCount
			rjmp	ModeWarmup
	
		ModeWarmup_Left_FlagSet_IncCount:

			inc		ADCCOUNT

			rjmp	ModeWarmup







	ModeWarmup_Save:	
		st		Z+,r10		;Saving position
		st		Z+,r11
		st		Z+,r12
		st		Z+,r13
		st		Z+,r14
		st		Z+,r15
		st		Z+,TURNSTS	;..and TURNSTS

		inc		ADCCOUNT	;Increase count as to stop saving more of the "same" turn-states


		;Test to make sure we don't overflow the memory if something unexpected happens
		ldi		r18,high($360)
		cpi		ZL,low($360)		;300 bytes is 300/7=57 events (=28 turns) - that should be plenty to go on
		cpc		ZH,r18
		brsh	ModeWarmup_Error_EvtTblOvrflw

		rjmp	ModeWarmup



		ModeWarmup_Error_EvtTblOvrflw:
			;Saving table end (current pointer value) adress at designated adress
			sts		EVTTBL_ENDHI,ZH
			sts		EVTTBL_ENDLO,ZL

			ldi		r16,0x31
			call	Error
			call	Debug_GetEvtTblEnds
			call	Debug_GetEvtTbl
			call	Die






rjmp	ModeWarmup



*/



/*


	;***********************
	;* BEGIN MEAN ADC CALC *
	;***********************

	;r16=counter
	;r19=divisor (same as counter)
	;r17=ADCH load
	;r15=0 (for addition)
	;r24:r25=addition and division keep
	;r20=temp to roll in to
	;r29:r28=result

	ModeWarmup_MeanADC:
		
		ldi		r16,6	;<- This is the number of measurements to gather the mean value from. Max 255
		clr		r15
		clr		r20
		clr		r25
		clr		r24
		clr		r28
		clr		r29
		inc		r28
		mov		r19,r16

		;while count>0 add new ADC value to r25:r24
		ModeWarmup_MeanADC_Loop:
			
			sbis	ADCSRA,ADIF
			rjmp	ModeWarmup_MeanADC_Loop		;Wait for updated ADC value

			in		r17,ADCH		;Load it

			;sbi		ADCSRA,ADIF		;Writing a logic "1" to the ADIF flag clears it

			add		r24,r17
			adc		r25,r15			;Add the loaded ADC value to r25:r24

			dec		r16				;Decrease counter value

			brne	ModeWarmup_MeanADC_Loop
		
			cli	;Disabling interrupt and loading ADNS pos here to get coherent values	
			lds		r9,(ADNS_DATA+1)	;pos Hi2
			lds		r10,(ADNS_DATA+2)	;pos Hi1
			lds		r11,(ADNS_DATA+3)	;pos Hi0
			lds		r12,(ADNS_DATA+4)	;pos Lo2
			lds		r13,(ADNS_DATA+5)	;pos Lo1
			lds		r14,(ADNS_DATA+6)	;pos Lo0
			sei	

		;elseif counter =0, divide r25:r24 by r19
			
			ModeWarmup_MeanADC_DivA:
				clc
				rol		r24
				rol		r25
				rol		r20
				brcs	ModeWarmup_MeanADC_DivB
				cp		r20,r19
				brcs	ModeWarmup_MeanADC_DivC
			ModeWarmup_MeanADC_DivB:
				sub		r20,r19
				sec
				rjmp	ModeWarmup_MeanADC_DivD
			ModeWarmup_MeanADC_DivC:
				clc
			ModeWarmup_MeanADC_DivD:
				rol		r28							;low result
				rol		r29							;high result
				brcc	ModeWarmup_MeanADC_DivA


	;-----------------------
	;*  END MEAN ADC CALC  *
	;-----------------------

*/








/*
	cpi		r28,TRNTHRSHIGH
	brsh	ModeWarmup_ADC_Send
	cpi		r28,TRNTHRSLOW
	brlo	ModeWarmup_ADC_Send

	rjmp	ModeWarmup


	ModeWarmup_ADC_Send:
		sbis	UCSRA,UDRE
		rjmp	ModeWarmup_ADC_Send
	out		UDR,r28

	delay	1/50
	rjmp	ModeWarmup
*/








/*
	;Check current ADC value
	ModeWarmup_ReadADC:
	
	delay	1/100

	in		r16,ADCH			;We can use r28 here to get the mean value as calculated
	cpi		r16,TRNTHRSHIGH
	brsh	ModeWarmup_ADC_Send
	cpi		r16,TRNTHRSLOW
	brlo	ModeWarmup_ADC_Send

	rjmp	ModeWarmup


	ModeWarmup_ADC_Send:
		sbis	UCSRA,UDRE
		rjmp	ModeWarmup_ADC_Send
	out		UDR,r16


	rjmp	ModeWarmup

*/
