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
 *	COMM.ASM (interrupt-driven USART receive and transmit functions handling telegrams of 3 bytes)
 *
 */




;BEGIN INTERRUPT: ISR(USART_RXC)
;
; r19 = Counter (starts at 0x00)
; Other vars are local
;
; A telegram is 3 bytes long.
; When 3 bytes have been received they are stored in r16 (byte#1), r17 (byte#2)
; and r18 (byte#3) [only for local use] and some action will then be executed
;
USART_RXC:
	push	r16
	in		r16,SREG
	push	r16
	push	r19

	lds		r19,RXCOUNT

	;Check for overrun error
	sbic	UCSRA,DOR
	rjmp	USART_RXC_Error_DataOverRun

	;Decide action depending on counter value
	cpi		r19,0
	breq	USART_RXC_StoreByte1
	cpi		r19,1
	breq	USART_RXC_StoreByte2
	cpi		r19,2
	breq	USART_RXC_StoreByte3

	;case 'Error' ;(counter value is invalid - perhaps another function is messing with it?)
	USART_RXC_Error_Counter:
		ldi		r16,0x10		;passing r16 as argument to Error function
		call	Error
		clr		r19				;Resetting counter value after error call
		rjmp	USART_RXC_Exit

	USART_RXC_Error_DataOverRun:
		call	UsartFlush		;Flush the receive buffer
		ldi		r16,0x15
		call	Error			;then return error
		clr		r19				;and clear counter to resume normal function
		rjmp	USART_RXC_Exit

	;case 'StoreByte1'
	USART_RXC_StoreByte1:
		in		r16,UDR
		sts		USART_RX_1,r16
		inc		r19
		rjmp	USART_RXC_Exit

	;case 'StoreByte2'
	USART_RXC_StoreByte2:
		in		r16,UDR
		sts		USART_RX_2,r16
		inc		r19
		rjmp	USART_RXC_Exit

	;case 'StoreByte3'
	USART_RXC_StoreByte3:
		push	r18			;
		in		r18,UDR		;We store byte #3 directly in r18 as the execute case immediately follows

	;case 'Execute' (when 3 bytes have been stored)
	USART_RXC_Exec:
		push	r17
		push	ZH
		push	ZL

		;Fetching buffer data from SRAM
		lds		r17,USART_RX_2		;Byte #2
		lds		r16,USART_RX_1		;Byte #1


		;Check byte#2 to make sure we don't end up somewhere crazy when we later IJMP
		;ATM WE LIMIT TO 0x3F DIFFERENT COMMANDs - this can be extended if needed
		cpi		r17,0x3F
		brsh	USART_RXC_Exec_ErrorByte2

		;Check 1st byte
		cpi		r16,0x55
		breq	USART_RXC_Exec_SET
		cpi		r16,0xAA
		breq	USART_RXC_Exec_GET
		
		;1st byte "unknown" error
		USART_RXC_Exec_ErrorByte1:
			ldi		r16,0x11			;Error code
			call	Error
			rjmp	USART_RXC_Exec_Exit	;_Exec_Exit resets counter value and restores pushed registers

		;2nd byte "unknown" error
		USART_RXC_Exec_ErrorByte2:
			ldi		r16,0x12			;Error code
			call	Error
			rjmp	USART_RXC_Exec_Exit


		;We now point to an instruction table (in commactions.asm)
		;Initial pointer value is decided by byte#1, while offset (and thus specific instruction) is byte#2. Byte #3 is irrelevant at this point
		USART_RXC_Exec_SET:
			ldi		ZH,high(RX_SET_EVENTS)
			ldi		ZL,low(RX_SET_EVENTS)
			add		ZL,r17
			brcc	USART_RXC_Exec_SET_JUMP
			inc		ZH
			USART_RXC_Exec_SET_JUMP:
				ijmp
	
		USART_RXC_Exec_GET:
			ldi		ZH,high(RX_GET_EVENTS)
			ldi		ZL,low(RX_GET_EVENTS)
			add		ZL,r17
			brcc	USART_RXC_Exec_GET_JUMP
			inc		ZH
			USART_RXC_Exec_GET_JUMP:
				ijmp	
	
		;Remember that all instructions in the jump tables must end back here!


		;Exits the execute case
		USART_RXC_Exec_Exit:
		clr		r19			;Reset counter
		pop		ZL
		pop		ZH
		pop		r17			;
		pop		r18			;Restore regs


	USART_RXC_Exit:
	sts		RXCOUNT,r19	;Save the new counter value in mem

	pop		r19
	pop		r16
	out		SREG,r16
	pop		r16			;Restore r16 and SREG
reti
;END INTERRUPT







;FUNCTION: UsartTx(r16,r17,r18)
;
; Transmits a telegram of 3 bytes.
;
; This function is used in conjunction with the USART buffer-empty-interrupt "USART_UDRE" which will take over
; if the buffer is full, so that we can avoid wasted CPU time while waiting for the buffer to become empty
; 
; r16 = byte#1 (TYPE)
; r17 = byte#2 (COMMAND)
; r18 = byte#3 (DATA)
;
; TXCOUNT is used to keep track of how many bytes have been sent
;
UsartTx:
	push	r19
	in		r19,SREG
	push	r19

	lds		r19,TXCOUNT

	UsartTx_CheckSelfState:
	sbic	UCSRB,UDRIE		;If the buffer-empty-interrupt is enabled it means we're already
	rjmp	UsartTx_Busy	; transmitting, and we don't want to overwrite the previous telegram
		
	UsartTx_CheckBufferState:
		sbis	UCSRA,UDRE
		rjmp	UsartTx_BufferNotReady
	
	;If the buffer is ready to accept new data, we transmit as usual while going back to CheckBufferState after each byte has been moved to UDR
	UsartTx_BufferReady:
		cpi		r19,2
		breq	UsartTx_BufferReady_Transmit3
		cpi		r19,1
		breq	UsartTx_BufferReady_Transmit2
		cpi		r19,0
		breq	UsartTx_BufferReady_Transmit1

		;If all data somehow got sent without buffer wait-time, we clear counter and exit:
		clr		r19
		rjmp	UsartTx_Exit
		
		UsartTx_BufferReady_Transmit1:
		out		UDR,r16
		inc		r19
		rjmp	UsartTx_CheckBufferState
		UsartTx_BufferReady_Transmit2:
		out		UDR,r17
		inc		r19
		rjmp	UsartTx_CheckBufferState
		UsartTx_BufferReady_Transmit3:
		out		UDR,r18
		clr		r19
		rjmp	UsartTx_CheckBufferState

	;If the buffer is not ready, we save the bytes we still haven't sent in memory and exit while enabling the buffer-empty-interrupt
	UsartTx_BufferNotReady:
		cpi		r19,2
		breq	UsartTx_BufferNotReady_Save3
		cpi		r19,1
		breq	UsartTx_BufferNotReady_Save23
		cpi		r19,0
		breq	UsartTx_BufferNotReady_Save123

		;If here get here something is bad
		clr		r19
		rjmp	UsartTx_Exit


		UsartTx_BufferNotReady_Save123:
		sts		USART_TX_1,r16
		sts		USART_TX_2,r17
		sts		USART_TX_3,r18
		sbi		UCSRB,UDRIE
		rjmp	UsartTx_Exit

		UsartTx_BufferNotReady_Save23:
		sts		USART_TX_2,r17
		sts		USART_TX_3,r18
		sbi		UCSRB,UDRIE
		rjmp	UsartTx_Exit

		UsartTx_BufferNotReady_Save3:
		sts		USART_TX_3,r18
		sbi		UCSRB,UDRIE
		rjmp	UsartTx_Exit
	

	UsartTx_Busy:
	rjmp	UsartTx_Exit ;Temporary solution: If we're in the middle of a transmission, we ignore the UsartTx Call. Not pretty; needs fixing
	
	UsartTx_Exit:
	sts		TXCOUNT,r19

	pop		r19
	out		SREG,r19
	pop		r19
ret
;END FUNCTION




;BEGIN INTERRUPT: ISR(USART_UDRE)
;
; Transmits data - saved in data space by UsartTx - when the UDR becomes empty
;
; USART_UDRE may ONLY be enabled by UsartTx: If we need it for other stuff we'll have to hack it a bit
; 
;
USART_UDRE:
	push	r16
	in		r16,SREG
	push	r16	
	push	r17

	lds		r17,TXCOUNT

	cpi		r17,2
	breq	USART_UDRE_Transmit3
	cpi		r17,1
	breq	USART_UDRE_Transmit2
	
	USART_UDRE_Transmit1:
		lds		r16,USART_TX_1
		out		UDR,r16
		inc		r17
		rjmp	USART_UDRE_Exit
	USART_UDRE_Transmit2:
		lds		r16,USART_TX_2
		out		UDR,r16
		inc		r17
		rjmp	USART_UDRE_Exit
	USART_UDRE_Transmit3:
		lds		r16,USART_TX_3
		out		UDR,r16
		clr		r17
		cbi		UCSRB,UDRIE
		rjmp	USART_UDRE_Exit
	
	USART_UDRE_Exit:
	sts		TXCOUNT,r17
	pop		r17
	pop		r16
	out		SREG,r16
	pop		r16	
reti
;END INTERRUPT







;FUNCTION: UsartFlush
;
; Flushes the receive buffer
;
UsartFlush:
	push	r16

	UsartFlush_Loop:
	sbis	UCSRA,RXC
	rjmp	UsartFlush_Exit
	in		r16,UDR
	rjmp	UsartFlush_Loop

	UsartFlush_Exit:
	pop		r16
ret
;END FUNCTION








/*   OLD/UN-BUFFERED


;FUNCTION: UsartTx(r16, r17=00, r18)
;
; Transmits a telegram of 3 bytes
; 
; r16 = byte#1 (TYPE)
; r17 = byte#2 (COMMAND)
; r18 = byte#3 (DATA)
;
; If byte#2 (r17) is set to 0x00 only byte#1 (r16) will be sent
;
UsartTx:
	cpi		r17,0x00
	breq	UsartTx_Single
	UsartTx_SendByte1:
		sbis	UCSRA,UDRE
		rjmp	UsartTx_SendByte1
		out		UDR,r16
	UsartTx_SendByte2:
		sbis	UCSRA,UDRE
		rjmp	UsartTx_SendByte2
		out		UDR,r17
	UsartTx_SendByte3:
		sbis	UCSRA,UDRE
		rjmp	UsartTx_SendByte3
		out		UDR,r18
		rjmp	UsartTx_Exit
	UsartTx_Single:
		sbis	UCSRA,UDRE
		rjmp	UsartTx_Single
		out		UDR,r16
	UsartTx_Exit:
ret


*/
