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
 *	ADNS_SPI.ASM (functions to manage sending/recieving via SPI)
 *
 */




.macro	spi_reset

	sbi PORTA,ADNS_PIN_NCS	;Pull high

	nop
	nop
	nop
	nop
	nop

	cbi	PORTA,ADNS_PIN_NCS	;Pull low

	nop
	nop
	nop
	nop

.endmacro




.macro	adns_spi_send

		out		SPDR,@0		;Send the data from the macro argument register

		adns_spi_send_wait:
		sbis	SPSR,SPIF
		rjmp	adns_spi_send_wait

		push	r16
		in		r16,SPDR	;We are not using this
		pop		r16

.endmacro






.macro	adns_spi_recv

		push	r16

		ldi		r16,0x00

		out		SPDR,r16	;Send empty byte

		adns_spi_recv_wait:
		sbis	SPSR,SPIF
		rjmp	adns_spi_recv_wait

		pop		r16
	
		in		@0,SPDR		;Return the read data in macro argument register

.endmacro
