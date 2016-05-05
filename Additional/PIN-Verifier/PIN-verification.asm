;==========================================================
;Implementation of PIN verification on AVR Microcontroller
; with CardParameter Update function
; Author			: Mehari G. Msgna
; Date Modified		: November 10, 2013
; Version			: 1.0
; Last Modified		: November 10, 2008
; Platform			: AVR (ATMega163)
; Working Frequency	: 4 MHz
; E-Mail			: Mehari.Msgna.2011@live.rhul.ac.uk
;==========================================================
.include "m163def.inc"
;
; PIN verification with Card parameter update
; Define Registers
;
.def Res1 = R2
.def Res2 = R3
.def Res3 = R4
.def Res4 = R5

.def m1LSB = R16
.def m1MSB = R17
.def m2LSB = R18
.def m2MSB = R19
.def tmp = R20

;Program memory
.cseg
.org 0x0000

	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16
	clr r16

	;Basic Block One
	;Reference PIN (Y) and Provided PIN (X)
	ldi YH, high(Reference_PIN<<1)
	ldi YL, low(Reference_PIN<<1)
	mov XL, R24
	mov XH, R25

	ld r21, Y+
	ld r22, X
	cp r21, r22
	brne FAIL

	;First Update (Copy the Signature)
	ldi ZH, high(Signatures<<1)
	ldi ZL, low(Signatures<<1)
	ldi XH, high(CardParameter)
	ldi XL, low(CardParameter)

	lpm r10, Z+
	st X+, r10
	lpm r10, Z+
	st X, r10
	sbiw XL, 0x01

	;Second Basic Block
	mov XL, R24
	mov XH, R25
	adiw XL, 0x01
	clr R10
	adc XH, R10

	ld r21, Y+
	ld r22, X
	cp r21, r22
	brne FAIL


	;Second Update
	ldi ZH, high(Signatures<<1)
	ldi ZL, low(Signatures<<1)
	adiw ZL, 2
	call CardParameterUpdate

	;Third Basic Block
	mov XL, R24
	mov XH, R25
	adiw XL, 0x02
	clr R10
	adc XH, R10

	ld r21, Y+
	ld r22, X
	cp r21, r22
	brne FAIL


	;Third update
	ldi ZH, high(Signatures<<1)
	ldi ZL, low(Signatures<<1)
	adiw ZL, 4
	call CardParameterUpdate

	;Forth Basic Block
	mov XL, R24
	mov XH, R25
	adiw XL, 0x03
	clr R10
	adc XH, R10

	ld r21, Y+
	ld r22, X
	cp r21, r22
	brne FAIL

	;Fourth Update
	ldi ZH, high(Signatures<<1)
	ldi ZL, low(Signatures<<1)
	adiw ZL, 6
	call CardParameterUpdate
FAIL: ;TODO-Clear Registers
	
	;Fifth Update
	ldi ZH, high(Signatures<<1)
	ldi ZL, low(Signatures<<1)
	adiw ZL, 8
	call CardParameterUpdate
	
	;Send the Updated Parameter
	ldi R23, high(CardParameter)
	ldi R22, low(CardParameter)

endCU: rjmp endCU


;=================================================
;         Card Parameter Update Function         ;
;=================================================
CardParameterUpdate:
	; Multiply [(X:X+) with (Z:Z+)]
	; (R5:R4:R3:R2) the output of the multiplication
	ldi XH, high(CardParameter)
	ldi XL, low(CardParameter)
	
	;Multiplicand (R17:R16)
	ld R17, X+
	ld R16, X

	;Multiplier (R19:R18)
	lpm R19, Z+
	lpm R18, Z
	
	;R20 ZERO register used in computstion
	clr R20 		;clear for carry operations
	mul R17, R19 ; Multiply MSBs
	mov R4, R0 	; copy to MSW Result
	mov R5, R1
	mul R16, R18 ; Multiply LSBs
	mov R2, R0 	; copy to LSW Result
	mov R3, R1
	mul R17, R18 ; Multiply 1M with 2L
	add R3, R0 	; Add to Result
	adc R4, R1
	adc R5, R20 	; add carry
	mul R16, R19 ; Multiply 1L with 2M
	add R3, R0 	; Add to Result
	adc R4, R1
	adc R5, R20
	;END Multiply

	;Compute Modulo N.
	;Divisor (R7:R6)
	ldi ZH, high(N<<1)
	ldi ZL, low(N<<1)
	lpm r7, Z+
	lpm r6, Z

	;Remainder (R11:R10:R9:R8)
	DIV3216:
		clr r12
		ldi r22,33

		sub r8, r8
		clr r9
		clr r10
		clr r11

		LOOP:
			rol r2
			rol r3
			rol r4
			rol r5

			dec r22
			breq DONE

			rol r8
			rol r9
			rol r10
			rol r11

			sub r8, r6
			sbc r9, r7
			sbc r10, r12
			sbc r11, r12

			brcc SKIP

			add r8, r6
			adc r9, r7
			adc r10, r12
			adc r11, r12

			clc

			rjmp LOOP

			SKIP:
				sec
				rjmp LOOP
	DONE:
		;Return the new 16 bit remainder (R9:R8)
		st X, r8
		sbiw XL, 0x01
		st X, r9
	ret
	;Modulus end

;PIN Reference
Reference_PIN:
.db 0x37, 0x31, 0x34, 0x33

;RSA Modulo
N:
.db 0x05, 0x4D

;Basic Block Signatures
Signatures:
.db 0x23,0x45
.db 0x67,0x34
.db 0xAC,0x46
.db 0x99,0xFE
.db 0x09,0xF4

.dseg
CardParameter: .byte 2	;16 bit modulo output
Remainder: .byte 4		;Holds 32 product intially and the 16 bit remainder
