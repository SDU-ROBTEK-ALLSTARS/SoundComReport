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
 *	SPEEDCALCULATION.ASM (Routine to regulate PWM output depending on actual measured speed)
 *
 */




/*
Memory space for speedcalculation

SPEED_CALC+0			Desired speed
SPEED_CALC+1			reg_count
SPEED_CALC+2			linear regulation constant P <<< THIS IS A SIGNED BYTE!


Static variables
*/
.equ SPEED_regulation_interval = 10;


; SREG should be pushed before calling this command
; 
SpeedRegulation:
	push	r0; Multiplication result LOW
	push	r1; Multiplication result HIGH
	push	r16; STATUS REGISTER (NU, NU, NU, NU, NU, NU, NU, NU)
	push	r17; Current speed
	push 	r18; Desired speed 
	push	r19; Difference (Signed integer)
	push	r20; Temp PWM value
	push	r21; Linear regulation constant
	
	; Fetch current speed from mem
	lds			r17, ADNS_DATA+0
	
	; Fetch desired speed from mem
	lds			r18, SPEED_CALC+0

	; Temp PWM value from current PWM value
	in			r20, OCR2

	; Fetch linear regulation constant from mem
	lds			r21, SPEED_CALC+0

	; H-bridge status
	; Forward: PC4 = 1, PC5 = 0 
	; Reverse: PC4 = 0, PC5 = 1	
	; We need the direction of the h-bridge to shift into current PWM value to make it signed.
	; RULE FOR SIGNED VALUES: If MSB/D7 is 1 then the number is negative
	; We will assume that the h-bridge is in forward mode if PC4 = 1

	clc; Clear carry flag
	sbic		PORTC, 5 ; Skip if bit in IO is cleared,
	sec ;set carry flag (This will be skipped if PORTC5 = 0) (Forward)

	; Use this as the signed bit on pwm
	ror			r20
	; Now the temp PWM value is a signed integer wich indicated the cirection of the power applied from the motor.
	
	; Now we need to calculate the difference between the current speed and the desired speed
	; We dont need 8 bit precission, so we will bitshift down the values to 7 bit
	lsr		r17; 
	lsr		r18;

	; Subtract current speed from desired speed to find the difference
	mov		r19, r18; Copy r18 to r19
	sub		r19, r17; Desired speed - current speed

	; If desired_speed = 127 and current_speed = 0: Difference = 127
	; If desired_speed = 0 and current_speed = 127: Difference = -127

	; Now we need to multiply the linear regulation constant
	mul		r19, r21;

	; The result will be placed at r0, r1
	; We only need to use the highbyte of this result.
	; This highbyte shall be applied to the PWM.
.
	; r1 : -128 to 127
	; r20 : -128 to 127
	

	; Now the maximum speed difference is 128
	add		r20, r1;

	; Branch if overflow set
	brvs	SpeedRegulation_Overflow	

	rjmp	SpeedRegulation_Setvalues

	SpeedRegulation_Overflow:
	; Did we "overflow" or "underflow"?
	; If halfcarry is set it must have been an overflow

	brhs	SpeedRegulation_OOverflow; Branch if halfcarry is set
	; WE ARE HERE BECAUSE THERE WAS A NEGATIVE OVERFLOW
	; Set the value to the lowest possible
	ldi		r20, -128;

	rjmp	SpeedRegulation_Setvalues
	SpeedRegulation_OOverflow:
	; WE ARE HERE BECAUSE THERE WAS A POSITIVE OVERFLOW
	; Set the value to the highest possible
	ldi		r20, 127

	SpeedRegulation_Setvalues:
	; New PWM has been calculated. Now it only needs to be bit shiftet, so the signed bit can be set in the h-bridge.
	sec
	; rotate h-bridge status to carry
	rol		r20;
	
	brcs	SpeedRegulation_backward

	; H-bridge backward
	SpeedRegulation_Forward:
	cbi		PORTC, 5
	sbi		PORTC, 4

	rjmp	SpeedRegulation_Exit;

	SpeedRegulation_backward:
	; Forward H-bridge
	sbi		PORTC, 5
	cbi		PORTC, 4
	
	SpeedRegulation_Exit:

	;Set new PWM value
	out			OCR2, r20

	pop		r21;
	pop		r20;
	pop		r19
	pop		r18;
	pop		r17;
	pop		r16;
	pop		r1;
	pop		r0;
	ret;
