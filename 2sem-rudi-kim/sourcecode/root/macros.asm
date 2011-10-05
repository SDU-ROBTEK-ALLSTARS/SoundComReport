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
 *	MACROS.ASM (macros handling different operations to easily re-use blocks of code)
 *
 */





;MOTOR
;Usage:
; motor [forward/reverse/short/stop],R
;The desired PWM duty cycle (OCR2) must be saved in a register R (16-31) before calling the macro,
; except when stopping or shorting in which case the second argument will be ignored

.equ stop = 0
.equ forward = 1
.equ reverse = 2
.equ short = 3

.macro motor
	.if @0==0			;stop
		push	r16
		clr		r16
		out		OCR2,r16
		cbi		PORTC,5
		sbi		PORTC,4
		pop		r16
	.elif @0==1			;forward
		out		OCR2,@1
		cbi		PORTC,5
		sbi		PORTC,4
	.elif @0==2			;reverse
		out		OCR2,@1
		cbi		PORTC,4
		sbi		PORTC,5
	.elif @0==3			;short
		push	r16
		ldi		r16,0xFF
		out		OCR2,r16
		sbi		PORTC,5
		sbi		PORTC,4
		pop		r16
	.else
		.error "Motor direction not defined correctly"
	.endif
.endmacro






;MEMORY
;
;Can read/write one byte of data to/from SRAM
;The adress which is to be read/written is set with sethi+setlo
;

.equ read = 1
.equ write = 4
.equ sethi = 2
.equ setlo = 3

.macro memory
	.if @0==1;read
		push	XH
		push	XL
			lds		XH,MEMHI
			lds		XL,MEMLO
			ld		@1,X+
		pop		XL
		pop		XH	
	.elif @0==4;write
		push	XH
		push	XL
			lds		XH,MEMHI
			lds		XL,MEMLO
			cpi		XL,$60				;A small check to ensure we don't write to addresses below $60
			brlo	MacroMemory_Error
			st		X+,@1
			rjmp	MacroMemory_Exit

			MacroMemory_Error:
			push	r16
			ldi		r16,0x60
			call	Error
			pop		r16

		MacroMemory_Exit:
		pop		XL
		pop		XH
	.elif @0==2;sethi
		sts		MEMHI,@1
	.elif @0==3;setlo
		sts		MEMLO,@1
	.else
		.error "Macro memory: Invalid argument"
	.endif
.endmacro




;DELAY (argument is in SECONDS (avoid using floating point))
;
;
;Will delay the program t*5+22 cycles
;
;
;Minimum delay: 1.69 us
;Maximum delay: 5.24 s
;
;
.macro delay
		
		.if @0>(524/100)
			
			.error "Maximum delay this macro can produce is 5.24 seconds"

		.elif @0<(169/10000)
			
			.error "Minimum delay this macro can produce is 1.69 microseconds"

		.else

			.set t=16000000*@0/5-22/5

			push	r16
			in		r16,SREG
			push	r16
			push	r17
			push	r18
				ldi		r16,byte1(t)
				ldi		r17,byte2(t)
				ldi		r18,byte3(t)
				delayMacroLoop:
				subi	r16,1
				sbci	r17,0
				sbci	r18,0
				brcc	delayMacroLoop
			pop		r18
			pop		r17
			pop		r16
			out		SREG,r16
			pop		r16

		.endif

.endmacro




.macro SendSingle
SendSingle:
	sbis	UCSRA,UDRE
	rjmp	SendSingle
	out		UDR,@0
.endmacro
