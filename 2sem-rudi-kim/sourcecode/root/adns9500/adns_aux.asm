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
 *	ADNS_AUX.ASM (ADNS9500 boot sequence, srom load, shutdown, fault detection)
 *
 */


ADNSconfig:

	; Prepare memory (empty)
	ldi		r16, 0x00;

	; Start loading memory pointer to Z
	ldi		ZL, low(ADNS_DATA); 
	ldi		ZH, high(ADNS_DATA); ; Now pointing at car speed
	st		Z+, r16 ; ADNS_DATA + 0
	st		Z+, r16 ; ADNS_DATA + 1
	st		Z+, r16 ; ADNS_DATA + 2
	st		Z+, r16 ; ADNS_DATA + 3
	st		Z+, r16 ; ADNS_DATA + 4
	st		Z+, r16 ; ADNS_DATA + 5
	st		Z, r16  ; ADNS_DATA + 6

	; Next memory area
	ldi		ZL, low(ADNS_DATA_LAST); 
	ldi		ZH, high(ADNS_DATA_LAST); ; Now pointing at car speed
	st		Z+, r16 ; ADNS_DATA_LAST+0
	st		Z+, r16 ; ADNS_DATA_LAST+1
	st		Z+, r16 ; ADNS_DATA_LAST+2
	st		Z+, r16 ; ADNS_DATA_LAST+3
	st		Z+, r16 ; ADNS_DATA_LAST+4
	st		Z+, r16 ; ADNS_DATA_LAST+5
	st		Z+, r16 ; ADNS_DATA_LAST+6
	st		Z+, r16 ; ADNS_DATA_LAST+7
	st		Z+, r16 ; ADNS_DATA_LAST+8
	st		Z+, r16 ; ADNS_DATA_LAST+9
	st		Z+, r16 ; ADNS_DATA_LAST+10
	st		Z+, r16 ; ADNS_DATA_LAST+11
	st		Z+, r16 ; ADNS_DATA_LAST+12
	st		Z+, r16 ; ADNS_DATA_LAST+13
	st		Z+, r16 ; ADNS_DATA_LAST+14
	st		Z, r16 ; ADNS_DATA_LAST+15 (Byte counter)


	;SPI
	ldi		r16,(1<<SPI2X)
	out		SPSR,r16
	ldi		r16,(1<<SPIE)|(1<<SPE)|(1<<MSTR)|(1<<CPOL)|(1<<CPHA)|(1<<SPR0)	;2 MHz SCKL
	out		SPCR,r16
	
		
	;Port config
	sbi		DDRB, 5				; MOSI
	cbi		DDRB, 6				; MISO
	sbi		PORTB, 6			; MISO (pullup ACTIVE)
	sbi 	DDRB, 7				; SCK
	sbi		DDRA,ADNS_PIN_NCS	; NSC output

	sbi		PORTA,ADNS_PIN_NCS	; NCS high initially

	delay	1/10

	wdr

ret






;*****  ADSN BOOT  *****
adns_boot:

	
	;Reset SPI port
	spi_reset
	
	

	;Write 0x5A to Power-Up register

	ldi				r16,(0x3A)|(0x80)		;Power-up register address (set 1 as MSB to write)
	adns_spi_send	r16

	ldi				r16,0x5A				;Command to reset
	adns_spi_send	r16

	delay			100/1000				;Wait 100ms for ADNS9500 to power up



	;Read register 0x02-0x06

	ldi				r16,0x02

	adns_boot_read_regs:
		
		adns_spi_send	r16

		delay			100/1000000			;wait tSRAD (100us) after first byte was sent

		adns_spi_recv	r17					;We're not using the read data, but we have to put it somewhere

		delay			20/1000000			;tSRW/tSRR


	inc				r16
	cpi				r16,0x07
	brlo			adns_boot_read_regs		;Run while r16 < 0x07



	;Check connection by reading ProductID and inverse ProductID

	ldi				r16,0x00				;ProductID
	adns_spi_send	r16
	
	delay			100/1000000				;tSRAD

	adns_spi_recv	r17

	delay			20/1000000				;tSRW/tSRR

	ldi				r16,0x3F				;Inverse ProductID
	adns_spi_send	r16
	
	delay			100/1000000				;tSRAD

	adns_spi_recv	r18

	delay			20/1000000				;tSRW/tSRR


	;Test if productID and inverse productID are consistents

	com				r17
	cp				r17,r18
	breq			adns_boot_ok_spicomm
	

		adns_boot_error_spicomm:

			ldi		r16,0x22
			call	Error
			call	Die

		ret
	

	adns_boot_ok_spicomm:



	;SROM load
	call	adns_upload_srom

	;Read SROM register
	ldi				r16,0x2A				;SROM ID
	adns_spi_send	r16
	
	delay			100/1000000				;tSRAD

	adns_spi_recv	r17

	delay			20/1000000				;tSRW/tSRR

	;Check SROM ID
	cpi				r17,ADNS_FIRMWARE_ID
	breq			adns_boot_error_ok_srom
	
		adns_boot_error_srom:
			
			ldi		r16,0x23
			call	Error
			call	Die


	adns_boot_error_ok_srom:

	;Enable LASER
	ldi				r16,(0x20)|(0x80)		;Write to laser control register
	adns_spi_send	r16

	ldi				r16,0x00				;Clear Force_Disabled
	adns_spi_send	r16

	delay			200/1000000				;tSWR + 60us



	;Get motion register
	ldi				r16,0x02				;Motion register
	adns_spi_send	r16
	
	delay			100/1000000				;tSRAD

	adns_spi_recv	r16

	delay			20/1000000				;tSRW/tSRR


	;and check for errors
	sbrc			r16,6
	rjmp			adns_boot_error_motion	

	sbrs			r16,5
	rjmp			adns_boot_error_laser



	;SROM CRC check
	ldi				r16,(0x13)|(0x80)		;Write to SROM_Enable
	adns_spi_send	r16

	ldi				r16,0x15				;0x15 starts CRC computation in the sensor (returns 0x00 if sensor is not running on SROM)
	adns_spi_send	r16

	delay			10/1000					;Wait 10ms

	ldi				r16,0x26				;Read upper data out
	adns_spi_send	r16

	delay			100/1000000				;tSRAD

	adns_spi_recv	r18						;Store the high byte of CRC sum in r18
	
	delay			20/1000000				;tSRW/tSRR

	ldi				r16,0x25				;Read lower data out
	adns_spi_send	r16

	delay			100/1000000				;tSRAD

	adns_spi_recv	r17						;Store the low byte of CRC sum in r17

	delay			20/1000000				;tSRW/tSRR


	;Compare read CRC to the known one
	cpi				r17,low(ADNS_FIRMWARE_CRC)
	brne			adns_boot_error_crc
	cpi				r18,high(ADNS_FIRMWARE_CRC)
	brne			adns_boot_error_crc



	;Send burst command and exit
	ldi				r16,0x50
	out				SPDR,r16

ret



;Boot errors
adns_boot_error_motion:

	ldi		r16,0x20
	call	Error
	call	Die

ret

adns_boot_error_laser:

	ldi		r16,0x21
	call	Error
	call	Die

ret

adns_boot_error_crc:

	ldi		r16,0x24
	call	Error
	call	Die

ret




;***** SROM UPLOAD *****
adns_upload_srom:

	spi_reset

	;Select the 3kbytes SROM at Configuration_IV register
	ldi				r16,(0x39)|(0x80)
	adns_spi_send	r16
	ldi				r16,(1<<1)
	adns_spi_send	r16
	
	;tSWW
	delay			120/1000000

	;Write 0x1D to SROM_Enable register
	ldi				r16,(0x13)|(0x80)
	adns_spi_send	r16
	ldi				r16,0x1D
	adns_spi_send	r16

	;Wait one frame
	delay			300/1000000

	;Write 0x18 to SROM_Enable register to start download
	ldi				r16,(0x13)|(0x80)
	adns_spi_send	r16
	ldi				r16,0x18
	adns_spi_send	r16

	;tSWW
	delay			120/1000000

	wdr

	;Write to SROM_Load_Burst
	ldi				r16,(0x62)|(0x80)
	adns_spi_send	r16
	delay			15/1000000

	;Read firmware from program memory and load it onto ADNS9500
	ldi				ZH,high(adns9500_srom_91<<1)
	ldi				ZL,low(adns9500_srom_91<<1)
	ldi				r25,high(adns9500_srom_91_end<<1)
	ldi				r24,low(adns9500_srom_91_end<<1)


	;Load program memory and send it until we reach the end of SROM data
	adns_upload_srom_loop:
		lpm				r16,Z+
		adns_spi_send	r16
		delay			15/1000000
		cp				ZL,r24
		cpc				ZH,r25
		brlo			adns_upload_srom_loop

	;Pull NCS high and wait 200us, then return
	sbi				PORTA,ADNS_PIN_NCS
	delay			200/1000000
	cbi				PORTA,ADNS_PIN_NCS
	delay			5/1000000

ret



;***** ADNS SHUTDOWN *****
adns_shutdown:
ret
