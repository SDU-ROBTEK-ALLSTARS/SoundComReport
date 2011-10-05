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
 *	ADNS_RUN.ASM (ADNS9500 spi transfer interrupt, timer overflow (sending burstcmd), updating position data)
 *
 */




;*****  SPI Transfer Complete  *****
SPI_STC:
	; Save SREG
	push 	r16;
	in		r16, SREG;
	push	r16
	push	r17; Byte count
	push	r18
	push	r30; Mem Pointer (z)
	push	r31; Mem Pointer (z)


	ADNS_SPI_ISR:
	; Read byte

	in		r16, SPDR	;Be aware that the first byte is a product of the transmitted command

	;Fetch byte count from mem (initially 0)
	lds		r17, ADNS_DATA_LAST+15; Byte counter

	; Load pointer
	ldi		ZL, low(ADNS_DATA_LAST)
	ldi		ZH, high(ADNS_DATA_LAST)

	; Add byte count to z
	ldi		r18,0
	add		ZL,r17;
	adc		ZH,r18

	; Save recieved value
	st			Z, r16;

	; Is this the first byte (the empty one recived while sending command)
	cpi			r17, 0
	breq		ADNS_SPI_ISR_TransmitbyteRecived

	; Is this the last byte from burst?
	cpi			r17, 14
	brne		ADNS_SPI_ISR_ReceiveNext; Bransh if not equal


	;If it is, then:
	sbi			PORTA, ADNS_PIN_NCS ; Pull high
	; How long does this pin have to be high to reset communications?
	; This pin needs to be high for at least tBEXIT = 500ns (500ns/(62,5ns/Clock) = 8 clocks)

	; We got the last byte. Update values

	call		ADNS_UpdateValues


	; ..and regulate PWM out
	call		SpeedRegulation



	; We need a delay before we start next motion burst. 
	; The sensor needs a least tBEXIT = 500ns before next motion burst, so this must be decided by how many readings we need pr. second
	; SO WE LEAVE THIS TO BE DEFINED LATER ON!!! <<<<
	; timer 0 is scaled by 256

	; Set timer 0
	ldi			r16, 7; (255-7)*256 = 63488; 63488 clocks * 62,5ns/clock = 3968000 ns= 0.003968 seconds
	out 		TCNT0, r16;

	; Enable timer
	in			r16,TIMSK
	ori			r16,(1<<TOIE0);
	out			TIMSK,r16
	ldi		r16,(1<<TOV0)	;Clearing the TOV0 interrupt flag by writing logic 1 to it! The flag seems
	out		TIFR,r16		;to be raised when setting TOIE0 and/or when writing to TCNT0

	; Enable comunications
	;cbi			PORTA, ADNS_PIN_NCS;
	;KIM: Moved this to TIM0_OVF so that the line is not active while waiting to send a new burst command

	; Done
	rjmp		ADNS_SPI_ISR_Exit
	

	ADNS_SPI_ISR_TransmitbyteRecived:
	; After first command is send, there needs to be a delay of tSRAD = 100us
	; 1 Clock = 0,0625us
	; 100/ 0,0623 = 1606 clocks
	; With 256 prescale the timer neds to be set at: 1606/256 = 7 

	; Set timer 0 with calculated value
	ldi			r16,(-7+255);
	out 		TCNT0, r16;

	; Enable timer interupt
	in			r16,TIMSK
	ori			r16,(1<<TOIE0);
	out			TIMSK,r16

	ldi		r16,(1<<TOV0)	;Clearing the TOV0 interrupt flag by writing logic 1 to it! The flag seems
	out		TIFR,r16		;to be raised when setting TOIE0 and/or when writing to TCNT0

	inc			r17 ; Increase byte count

	; Goto exit of interupt
	rjmp		ADNS_SPI_ISR_Exit

	ADNS_SPI_ISR_ReceiveNext:
	ldi 		r16, 0;
	out			SPDR, r16;
	inc			r17 ; Increase byte count



	ADNS_SPI_ISR_Exit:

	sts		ADNS_DATA_LAST+15, r17 ; Save new byte count

	sbis	SPCR,MSTR
	sbi		SPCR,MSTR		;If MRST mode got disabled because of LULZ then re-enable it

	pop 	r31;
	pop		r30;
	pop		r18
	pop		r17;
	pop		r16
	out 	SREG, r16;
	pop		r16;
	; Restore SREG
reti




;*****  Timer0 Overflow  *****
TIM0_OVF:
	; Save SREG
	push 	r16;
	in		r16, SREG;
	push	r16;
	push	r17;

	ADNS_TIM0_OVF:
	
		; Are we here because of first or last byte?
		; Fetch byte count from mem
		lds			r17, ADNS_DATA_LAST+15; Byte counter

		cpi			r17, 14
		breq 		ADNS_TIM0_OVF_LastByte
		; This must be the transmit byte
		; Begin reception of bytes
		ldi			r16, 0x00;
		out			SPDR, r16;

		; End interupt
		rjmp		ADNS_TIM0_OVF_Exit

		ADNS_TIM0_OVF_LastByte:
		; Enable comunications
		cbi			PORTA, ADNS_PIN_NCS		;pull low
		nop
		nop
		nop
		nop
		; Send burst mode cmd to begin new transmission
		ldi			r16, 0x50;
		out			SPDR, r16;
		clr			r17
		sts			ADNS_DATA_LAST+15, r17 	;Reset bytecount


		ADNS_TIM0_OVF_Exit:
		; Disable this timer interupt
		in		r16,TIMSK
		andi	r16,~(1<<TOIE0)
		out		TIMSK,r16



	pop		r17;
	pop		r16;
	out 	SREG, r16;
	pop		r16;
	; Restore SREG
reti










;*****  UPDATE VALS  *****
ADNS_UpdateValues:
	; Use update speed and postiondata with new value

	push		r18; Temp
	push		r19; Motion low byte
	push		r20; Motion high byte
	push		r21; Pos High
	push		r22; Pos
	push		r23; Pos
	push		r24; Pos
	push		r25; Pos
	push		r26; Pos Low

	; Be aware that X begins at 27
	; First fetch last motion
	lds			r19, ADNS_DATA_LAST+3 ; Low
	lds			r20, ADNS_DATA_LAST+4 ; High

	; Update the speed
	; Right now the speed is equal to the motion since last update
	; If we need to multiply or add a constant to the speed, here will be the place!
	sts			ADNS_DATA+0, r20

	; Get last position from mem
	lds			r21, ADNS_DATA+1 ; High
	lds			r22, ADNS_DATA+2
	lds			r23, ADNS_DATA+3
	lds			r24, ADNS_DATA+4
	lds			r25, ADNS_DATA+5
	lds			r26, ADNS_DATA+6 ; Low
	
	; Used to add carry bute
	ldi			r18, 0;

	; Add low motion byte to position
	add		r26, r19; 1 clock
	adc		r25, r18 ; Add carry to next byte (1 cycle)
	adc		r24, r18 ; Add carry to next byte
	adc		r23, r18 ;
	adc		r22, r18 ;
	adc		r21, r18 ; Add carry to last byte

	;If we still have a carry, return overflow error
	brcs 	ADNS_UpdateValues_Error_OverflowLow


	; Add high motion byte to position
	add 	r25, r20;
	adc		r24, r18; Add carry to next byte
	adc		r23, r18; 
	adc		r22, r18; 
	adc		r21, r18; Add carry to last byte

	; If this makes overflow, the data in the register is invalid and we need to stop operations.
	brcs 	ADNS_UpdateValues_Error_OverflowHigh

	; Save the new position
	sts			ADNS_DATA+1, r21
	sts			ADNS_DATA+2, r22
	sts			ADNS_DATA+3, r23
	sts			ADNS_DATA+4, r24
	sts			ADNS_DATA+5, r25
	sts			ADNS_DATA+6, r26

	ADNS_UpdateValues_Exit:
	pop			r26;
	pop			r25;
	pop			r24;
	pop			r23;
	pop			r22;
	pop			r21;
	pop			r20;
	pop			r19;
	pop			r18;
ret;
	

	ADNS_UpdateValues_Error_OverflowLow:
		ldi		r16,0x23
		rjmp	ADNS_UpdateValues_Error_OverflowCall
	ADNS_UpdateValues_Error_OverflowHigh:
		ldi		r16,0x24
	ADNS_UpdateValues_Error_OverflowCall:
		call	Error
		;Reset position
		ldi		r16,0x00
		sts		ADNS_DATA+1,r16
		sts		ADNS_DATA+2,r16
		sts		ADNS_DATA+3,r16
		sts		ADNS_DATA+4,r16
		sts		ADNS_DATA+5,r16
		sts		ADNS_DATA+6,r16
	rjmp	ADNS_UpdateValues_Exit





