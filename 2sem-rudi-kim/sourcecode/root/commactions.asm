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
 *	COMMACTIONS.ASM (actions to be executed on specific combinations of telegrams recieved)
 *
 */



;--------------------------------------------
; "SET" type jump table
;--------------------------------------------
RX_SET_EVENTS:
	rjmp	USART_RXC_Exec_ErrorByte2		;00
	rjmp	SET_MEM_LO
	rjmp	SET_MEM_HI
	rjmp	SET_MEM_Write
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	SET_WD_Reset
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_Exit
	rjmp	SET_Reverse						;09
	rjmp	USART_RXC_Exec_ErrorByte2		;0A
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;0F
	rjmp	SET_Start						;10
	rjmp	SET_Stop
	rjmp	SET_ModeAuto
	rjmp	SET_ModeDefault
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;19
	rjmp	USART_RXC_Exec_ErrorByte2		;1A
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;1F
	rjmp	USART_RXC_Exec_ErrorByte2		;20
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;29
	rjmp	USART_RXC_Exec_ErrorByte2		;2A
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;2F
	rjmp	USART_RXC_Exec_ErrorByte2		;30
	rjmp	USART_RXC_Exec_ErrorByte2		;31
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;39
	rjmp	USART_RXC_Exec_ErrorByte2		;3A
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;3F
;--------------------------------------------
; "GET" type jump table
;--------------------------------------------
RX_GET_EVENTS:
	rjmp	USART_RXC_Exec_ErrorByte2		;00
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	GET_MEM_Read
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	GET_OCR2						;09
	rjmp	USART_RXC_Exec_ErrorByte2		;0A
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;0F
	rjmp	USART_RXC_Exec_ErrorByte2		;10
	rjmp	USART_RXC_Exec_ErrorByte2		;11
	rjmp	GET_Mode
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;19
	rjmp	USART_RXC_Exec_ErrorByte2		;1A
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	GET_BurstADCVals
	rjmp	GET_EVTTBLEND
	rjmp	GET_EVTTBL
	rjmp	GET_ADNSTBL						;1F
	rjmp	USART_RXC_Exec_ErrorByte2		;20
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;29
	rjmp	USART_RXC_Exec_ErrorByte2		;2A
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;2F
	rjmp	USART_RXC_Exec_ErrorByte2		;30
	rjmp	USART_RXC_Exec_ErrorByte2		;31
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;39
	rjmp	USART_RXC_Exec_ErrorByte2		;3A
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2
	rjmp	USART_RXC_Exec_ErrorByte2		;3F

;--------------------------------------------
; "SET" type jump targets/instructions
;--------------------------------------------
SET_MEM_HI:
	memory	sethi,r18
	rjmp	USART_RXC_Exec_Exit
SET_MEM_LO:
	memory	setlo,r18
	rjmp	USART_RXC_Exec_Exit
SET_MEM_Write:
	memory	write,r18
	rjmp	USART_RXC_Exec_Exit
SET_Reverse:
	motor	reverse,r18
	rjmp	USART_RXC_Exec_Exit
SET_Start:
	motor	forward,r18
	rjmp	USART_RXC_Exec_Exit
SET_Stop:
	motor	stop
	rjmp	USART_RXC_Exec_Exit
SET_ModeAuto:
	ldi		r16,(1<<MD_PREWARM)
	mov		MODE,r16
	rjmp	USART_RXC_Exec_Exit
SET_ModeDefault:
	ldi		r16,(1<<MD_DEF)
	mov		MODE,r16
	rjmp	USART_RXC_Exec_Exit
SET_WD_Reset:
	call	Die		;Watchdog will kill the program here
	rjmp	USART_RXC_Exec_Exit
;--------------------------------------------
; "GET" type jump targets/instructions
;--------------------------------------------
GET_Mode:
	ldi		r16,0xBB
	ldi		r17,0x12
	mov		r18,MODE
	call	UsartTx
	rjmp	USART_RXC_Exec_Exit
GET_MEM_Read:
	memory	read,r18
	ldi		r16,0xBB
	ldi		r17,0x04
	call	UsartTx
	rjmp	USART_RXC_Exec_Exit
GET_ADNSTBL:
	call	Debug_GetADNSTbl
	rjmp	USART_RXC_Exec_Exit
GET_EVTTBL:
	call	Debug_GetEvtTbl
	rjmp	USART_RXC_Exec_Exit
GET_EVTTBLEND:
	call	Debug_GetEvtTblEnds
	rjmp	USART_RXC_Exec_Exit
GET_OCR2:
	ldi		r16,0xBB
	ldi		r17,0x09
	in		r18,OCR2
	call	UsartTx
	rjmp	USART_RXC_Exec_Exit	
GET_BurstADCVals:
	call	Debug_BurstADCVals
	rjmp	USART_RXC_Exec_Exit	
