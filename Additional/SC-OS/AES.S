
.set xl,26
.set xh,27
.set yl,28
.set yh,29
.set zl,30
.set zh,31
.set sph,0x3e
.set spl,0x3d
.set ramend,0x45f

.set XL,26
.set XH,27
.set YL,28
.set YH,29
.set ZL,30
.set ZH,31

//******************************************
//********** Add Round Key *****************
//********** X: state address **************
//********** Y: RoundKey address ***********
//*** used registers : r16, r17, r18 *******
//******************************************

AddRoundKey:

ldi r18, 16

loop:

ld r16, X
ld r17, Y+

eor r16, r17

st X+, r16

dec r18

brne loop
clr r18
clr r17
clr r16

ret

//********** End Add Round Key *************

//******************************************
//********** Sub Bytes *********************
//********** X: state address **************
//*** used registers : r16, r17, Z *********
//******************************************

SubBytes:

	ldi r18, 16

loop1:
ld r17,X
rcall Sbox
st X+, r17
dec r18
brne loop1
clr r18	

ret

//********** End Sub Bytes *****************

//******************************************
//********** Sbox **************************
//********** r17: input ********************
//********** r17: Sbox(input) **************
//*** used registers : r17, Z **************
//******************************************

Sbox:

ldi ZL, lo8(Sbox_Table)
ldi ZH, hi8(Sbox_Table)

add ZL, r17
clr r17
adc ZH, r17

lpm r17, Z

ret

Sbox_Table:
.word 0x7c63
.word 0x7b77
.word 0x6bf2
.word 0xc56f
.word 0x0130
.word 0x2b67
.word 0xd7fe
.word 0x76ab
.word 0x82ca
.word 0x7dc9
.word 0x59fa
.word 0xf047
.word 0xd4ad
.word 0xafa2
.word 0xa49c
.word 0xc072
.word 0xfdb7
.word 0x2693
.word 0x3f36
.word 0xccf7
.word 0xa534
.word 0xf1e5
.word 0xd871
.word 0x1531
.word 0xc704
.word 0xc323
.word 0x9618
.word 0x9a05
.word 0x1207
.word 0xe280
.word 0x27eb
.word 0x75b2
.word 0x8309
.word 0x1a2c
.word 0x6e1b
.word 0xa05a
.word 0x3b52
.word 0xb3d6
.word 0xe329
.word 0x842f
.word 0xd153
.word 0xed00
.word 0xfc20
.word 0x5bb1
.word 0xcb6a
.word 0x39be
.word 0x4c4a
.word 0xcf58
.word 0xefd0
.word 0xfbaa
.word 0x4d43
.word 0x8533
.word 0xf945
.word 0x7f02
.word 0x3c50
.word 0xa89f
.word 0xa351
.word 0x8f40
.word 0x9d92
.word 0xf538
.word 0xb6bc
.word 0x21da
.word 0xff10
.word 0xd2f3
.word 0x0ccd
.word 0xec13
.word 0x975f
.word 0x1744
.word 0xa7c4
.word 0x3d7e
.word 0x5d64
.word 0x7319
.word 0x8160
.word 0xdc4f
.word 0x2a22
.word 0x8890
.word 0xee46
.word 0x14b8
.word 0x5ede
.word 0xdb0b
.word 0x32e0
.word 0x0a3a
.word 0x0649
.word 0x5c24
.word 0xd3c2
.word 0x62ac
.word 0x9591
.word 0x79e4
.word 0xc8e7
.word 0x6d37
.word 0xd58d
.word 0xa94e
.word 0x566c
.word 0xeaf4
.word 0x7a65
.word 0x08ae
.word 0x78ba
.word 0x2e25
.word 0xa61c
.word 0xc6b4
.word 0xdde8
.word 0x1f74
.word 0xbd4b
.word 0x8a8b
.word 0x3e70
.word 0x66b5
.word 0x0348
.word 0x0ef6
.word 0x3561
.word 0xb957
.word 0xc186
.word 0x9e1d
.word 0xf8e1
.word 0x1198
.word 0xd969
.word 0x948e
.word 0x1e9b
.word 0xe987
.word 0x55ce
.word 0xdf28
.word 0xa18c
.word 0x0d89
.word 0xe6bf
.word 0x6842
.word 0x9941
.word 0x0f2d
.word 0x54b0
.word 0x16bb

//********** End Sbox **********************

//******************************************
//********** Shift Rows ********************
//********** X: state address **************
//*** used registers : r16, r17 ************
//******************************************

ShiftRows:

;2nd Row
adiw XL,1 ;A1
ld r16, X

adiw XL,4 ;A5
ld r17,X
sbiw XL,4
st X, r17
adiw XL,8 ;A9
ld r17,X
sbiw XL,4 ;A5
st X, r17
adiw XL,8 ;A13
ld r17,X
sbiw XL,4
st X, r17
adiw XL,4
st X,r16
sbiw XL,13

;3rd Row
adiw XL,2 ;A2
ld r16, X
adiw XL,8 ;A10
ld r17,X
st X,r16
sbiw XL,8
st X, r17
adiw XL,4 ;A6
ld r16,X
adiw XL,8 ;A14
ld r17,X
st X, r16
sbiw XL,8;A6
st X,r17
sbiw XL,6 ;A0

;4th row
adiw XL,3;A3
ld r16,X
adiw XL,12;A15
ld r17,X
sbiw XL,12;A3
st X,r17
adiw XL,4;A7
ld r17,X
st X,r16
adiw XL,4;A11
ld r16,X
st X,r17
adiw XL,4;A15
st X,r16
sbiw XL,15
clr r16
clr r17

;The state matrix now should look like this:
;A0  ,A4  ,A8  ,A12
;A5  ,A9  ,A13 ,A1
;A10 ,A14 ,A2  ,A6
;A15 ,A3  ,A7  ,A11

ret

//********** End Shift Rows ****************

//******************************************
//********** Mix Columns *******************
//********** X: state address **************
//********** Z: free memory address ********
//*** used registers : r16, r17, r18, 19 ***
//******************************************

; <insert your MixColumns code here>

Mult2:
	lsl r17
	brcc endmult2
	ldi r18,0x1b
	eor r17, r18

endmult2:
	clr r16
	ret

Mult3:
	mov r16, r17
	rcall Mult2
	eor r17,r16
	ret

MixOneColumn:
	ldi r18,0x00

	ld r17, X+
 	rcall Mult2
 	mov r18, r17
 	ld r17, X+
 	rcall Mult3
 	eor r18, r17
 	ld r17, X+
 	eor r18, r17
 	ld r17, X
 	eor r18, r17
 	st Z+, r18
 	clr r18

 	sbiw XL,3
 	ld r18, X+
 	ld r17, X+
 	rcall Mult2
 	eor r18, r17
 	ld r17, X+
 	rcall Mult3
 	eor r18, r17
 	ld r17, X
 	eor r18, r17
 	st Z+, r18
 	clr r18

	sbiw XL,3
 	ld r18, X+
 	ld r17, X+
 	eor r18, r17
 	ld r17, X+
 	rcall Mult2
 	eor r18, r17
 	ld r17,X
 	rcall Mult3
 	eor r18, r17
 	st Z+, r18

 	ldi r18,0x00

 	sbiw XL,3
 	ld r17, X+
 	rcall Mult3
 	eor r18, r17
 	ld r17, X+
 	eor r18, r17
 	ld r17, X+
 	eor r18, r17
 	ld r17, X
 	rcall Mult2
 	eor r18, r17
 	st Z, r18
 	clr r18

 	sbiw XL,3
 	sbiw ZL,3

 	;move the calculated value to the state
 	ld r18, Z+
 	st X+, r18
 	ld r18, Z+
 	st X+, r18
 	ld r18, Z+
 	st X+, r18
 	ld r18, Z
 	st X, r18

 	;return the pointer to its original value
 	sbiw ZL,3
 	sbiw XL,3
	ret

MixColumns:
	call	MixOneColumn
	adiw XL,4
	call	MixOneColumn
	adiw XL,4
	call	MixOneColumn
	adiw XL,4
	call	MixOneColumn
	
	ret
//********** End Mix Columns ***************

;-------------------------------------------
;AES Encrypt function
;The Plaintext (pointer address) is passed in registers (r24 (lo),r25 (hi))
;176 Byte long key value is passed using the registers (r22 (lo),r23 (hi))
;500 Byte free SRAM in registers (r20 (lo),r21 (hi))

.global	AES_enc
.type	AES_enc,@function
AES_enc:
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
	push r28
	push r29
	push r30
	push r31

	;The AES encryption source code begins here
	SBI	0x17,5
	SBI	0x17,7

	SBI	0x18,5
	SBI	0x18,7

	mov	ZL,r20		; Z=[r21 r20]
	mov	ZH,r21		;copy free memory address in Z reg

	clr	r16
	st	Z,r16		; freemem[0]=0

	mov	YL,r22		; Y=[r29 r28]
	mov	YH,r23		;copy roundkey address to Y reg

	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg
	rcall 	AddRoundKey

EncryptionLoop:
	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg
	rcall	SubBytes
	
	;...................................
	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg
	rcall	ShiftRows
	
	;...................................
	mov	ZL,r20		; Z=[r21 r20]
	mov	ZH,r21		;copy free memory address in Z reg
	ld	r16,Z		;load freemem[0]
	cpi	r16,0x09	;compare if loop counter equals 9 (the last round)
	breq	EncSkipMixColumn

	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg

	mov	ZL,r20		; Z=[r21 r20]
	mov	ZH,r21		;copy free memory address in Z reg

	adiw	ZL,0x01		;skip 1 first byte
	rcall	MixColumns
	;...................................

EncSkipMixColumn:
	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg
	call 	AddRoundKey
	
	mov	ZL,r20		; Z=[r21 r20]
	mov	ZH,r21		;copy free memory address in Z reg
	
	ld	r16,Z		;load freemem[0]
	inc	r16
	st	Z,r16

	cpi	r16,0x0a	;compare if loop counter equals 10 (the last round)
	brne	EncryptionLoop

	CBI	0x18,5
	CBI	0x18,7

	pop r31
	pop r30
	pop r29
	pop r28
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	clr r1
	ret

;end encrypt

//******************************************
//********** InSbox ************************
//********** r17: input ********************
//********** r17: Sbox(input) **************
//*** used registers : r17, Z **************
//******************************************

InSbox:
	ldi	ZL,lo8(InSboxTable)	; Z = [r31 r30]
	ldi	ZH,hi8(InSboxTable)	; Initialize Z-pointer to the InSboxTable

	add	ZL,r17
	clr	r17
	adc	ZH,r17 	; add r17 as input of the InSbox to the table pointer

	lpm	r17, Z 	; Load InSbox output to r17
	ret

InSboxTable:
	.word 0x0952
	.word 0xd56a
	.word 0x3630
	.word 0x38a5
	.word 0x40bf
	.word 0x9ea3
	.word 0xf381
	.word 0xfbd7
	.word 0xe37c
	.word 0x8239
	.word 0x2f9b
	.word 0x87ff
	.word 0x8e34
	.word 0x4443
	.word 0xdec4
	.word 0xcbe9
	.word 0x7b54
	.word 0x3294
	.word 0xc2a6
	.word 0x3d23
	.word 0x4cee
	.word 0x0b95
	.word 0xfa42
	.word 0x4ec3
	.word 0x2e08
	.word 0x66a1
	.word 0xd928
	.word 0xb224
	.word 0x5b76
	.word 0x49a2
	.word 0x8b6d
	.word 0x25d1
	.word 0xf872
	.word 0x64f6
	.word 0x6886
	.word 0x1698
	.word 0xa4d4
	.word 0xcc5c
	.word 0x655d
	.word 0x92b6
	.word 0x706c
	.word 0x5048
	.word 0xedfd
	.word 0xdab9
	.word 0x155e
	.word 0x5746
	.word 0x8da7
	.word 0x849d
	.word 0xd890
	.word 0x00ab
	.word 0xbc8c
	.word 0x0ad3
	.word 0xe4f7
	.word 0x0558
	.word 0xb3b8
	.word 0x0645
	.word 0x2cd0
	.word 0x8f1e
	.word 0x3fca
	.word 0x020f
	.word 0xafc1
	.word 0x03bd
	.word 0x1301
	.word 0x6b8a
	.word 0x913a
	.word 0x4111
	.word 0x674f
	.word 0xeadc
	.word 0xf297
	.word 0xcecf
	.word 0xb4f0
	.word 0x73e6
	.word 0xac96
	.word 0x2274
	.word 0xade7
	.word 0x8535
	.word 0xf9e2
	.word 0xe837
	.word 0x751c
	.word 0x6edf
	.word 0xf147
	.word 0x711a
	.word 0x291d
	.word 0x89c5
	.word 0xb76f
	.word 0x0e62
	.word 0x18aa
	.word 0x1bbe
	.word 0x56fc
	.word 0x4b3e
	.word 0xd2c6
	.word 0x2079
	.word 0xdb9a
	.word 0xfec0
	.word 0xcd78
	.word 0xf45a
	.word 0xdd1f
	.word 0x33a8
	.word 0x0788
	.word 0x31c7
	.word 0x12b1
	.word 0x5910
	.word 0x8027
	.word 0x5fec
	.word 0x5160
	.word 0xa97f
	.word 0xb519
	.word 0x0d4a
	.word 0xe52d
	.word 0x9f7a
	.word 0xc993
	.word 0xef9c
	.word 0xe0a0
	.word 0x4d3b
	.word 0x2aae
	.word 0xb0f5
	.word 0xebc8
	.word 0x3cbb
	.word 0x5383
	.word 0x6199
	.word 0x2b17
	.word 0x7e04
	.word 0x77ba
	.word 0x26d6
	.word 0x69e1
	.word 0x6314
	.word 0x2155
	.word 0x7d0c

//********** End InSbox ********************

//******************************************
//********** InSub Bytes *******************
//********** X: state address **************
//*** used registers : r16, r17, Z *********
//******************************************

InSubBytes:
	ldi	r16,0x10		;counter=16

InSubBytesLoop:
	ld	r17,X		;load state byte
	call	InSbox
	st	X+,r17		;store InSbox(state byte) in the same location and increment the address

	dec	r16
	brne	InSubBytesLoop
	ret

//********** End InSub Bytes ***************

//******************************************
//********** InShift Rows ******************
//********** X: state address **************
//*** used registers : r16, r17 ************
//******************************************

InShiftRows:
	ld	r16,X+		;dummy instruction to increment X pointer
	ld	r16,X		;load r16=state[1]

	adiw	XL,12		;X += 12 (X=13)
	ld	r17,X
	sbiw	XL,12		;X -= 12 (X=1)
	st	X,r17		; state[1]=state[13]

	adiw	XL,8		;X += 8 (X=9)
	ld	r17,X
	adiw	XL,4		;X += 4 (X=13)
	st	X,r17		; state[13]=state[9]

	sbiw	XL,8		;X -= 8 (X=5)
	ld	r17,X
	adiw	XL,4		;X += 4 (X=9)
	st	X,r17		; state[9]=state[5]
	
	sbiw	XL,4		;X -= 4 (X=5)
	st	X,r16		; state[5]=state[1] (r16)
	//..................................

	sbiw	XL,3		;X -= 3 (X=2)
	ld	r16,X		;load r16=state[2]

	adiw	XL,8		;X += 8 (X=10)
	ld	r17,X
	sbiw	XL,8		;X -= 8 (X=2)
	st	X,r17		; state[2]=state[10]

	adiw	XL,8		;X += 8 (X=10)
	st	X,r16		; state[10]=state[2] (r16)

	sbiw	XL,4		;X -= 4 (X=6)
	ld	r16,X		;load r16=state[6]

	adiw	XL,8		;X += 8 (X=14)
	ld	r17,X
	sbiw	XL,8		;X -= 8 (X=6)
	st	X,r17		; state[6]=state[14]

	adiw	XL,8		;X += 8 (X=14)
	st	X+,r16		; state[14]=state[6] (r16)
	//..................................

	ld	r16,X		;load r16=state[15]

	sbiw	XL,12		;X -= 12 (X=3)
	ld	r17,X
	adiw	XL,12		;X += 12 (X=15)
	st	X,r17		; state[15]=state[3]

	sbiw	XL,8		;X -= 8 (X=7)
	ld	r17,X
	sbiw	XL,4		;X -= 4 (X=3)
	st	X,r17		; state[3]=state[7]

	adiw	XL,8		;X += 8 (X=11)
	ld	r17,X
	sbiw	XL,4		;X -= 4 (X=7)
	st	X,r17		; state[7]=state[11]
	
	adiw	XL,4		;X += 4 (X=11)
	st	X,r16		; state[11]=state[15] (r16)
	ret

//********** End InShift Rows **************

//******************************************
//********** InMix Columns *****************
//********** X: state address **************
//********** Z: free memory address ********
//*** used registers : r16, r17, r18, 19 ***
//******************************************

Mult9:
	mov	r18,r17		;keep input value
	call	Mult2		;r17=Mult2(input)
	call	Mult2		;r17=Mult4(input)
	call	Mult2		;r17=Mult8(input)
	eor	r17,r18		;r17 XOR= input	(implementation of Mult9 = Mutl8 XOR input)
	ret

Multb:
	mov	r18,r17		;keep input value
	call	Mult2		;r17=Mult2(input)
	eor	r18,r17		;r18 XOR= Mult2(input) (implementation of Mult3 = Mutl2 XOR input)
	call	Mult2		;r17=Mult4(input)
	call	Mult2		;r17=Mult8(input)
	eor	r17,r18		;r17 XOR= input	(implementation of Multb = Mutl8 XOR Mult2 XOR input)
	ret

Multd:
	mov	r18,r17		;keep input value
	call	Mult2		;r17=Mult2(input)
	call	Mult2		;r17=Mult4(input)
	eor	r18,r17		;r18 XOR= Mult4(input) (implementation of Mult5 = Mutl4 XOR input)
	call	Mult2		;r17=Mult8(input)
	eor	r17,r18		;r17 XOR= input	(implementation of Multd = Mutl8 XOR Mult4 XOR input)
	ret

Multe:
	call	Mult2		;r17=Mult2(input)
	mov	r18,r17		;r18=Mult2(input)
	call	Mult2		;r17=Mult4(input)
	eor	r18,r17		;r18 XOR= Mult4(input) (implementation of Mult6 = Mutl4 XOR Mult2)
	call	Mult2		;r17=Mult8(input)
	eor	r17,r18		;r17 XOR= Mult6(input) (implementation of Multe = Mutl8 XOR Mult4 XOR Mult2)
	ret

InMixOneColumn:

	ld	r17,X+		;load state[0], X++
	call	Multe		;r17=Multe(state[0])
	mov	r19,r17		;r19=r17
	ld	r17,X+		;load state[1], X++
	call	Multb		;
	eor	r19,r17		;r19 XOR= Multb(state[1])
	ld	r17,X+		;load state[2], X++
	call	Multd		;
	eor	r19,r17		;r19 XOR= Multd(state[2])
	ld	r17,X		;load state[3]
	call	Mult9		;
	eor	r19,r17		;r19 XOR= Mult9(state[3])
	st	Z+,r19		;store the result[0] to Z[0] (free memory)

	sbiw	XL,3		; X -= 3 (to state[0])
	ld	r17,X+		;load state[0], X++
	call	Mult9		;r17=Mult9(state[0])
	mov	r19,r17		;r19=r17
	ld	r17,X+		;load state[1], X++
	call	Multe		;
	eor	r19,r17		;r19 XOR= Multe(state[1])
	ld	r17,X+		;load state[2], X++
	call	Multb		;
	eor	r19,r17		;r19 XOR= Multb(state[2])
	ld	r17,X		;load state[3]
	call	Multd		;
	eor	r19,r17		;r19 XOR= Multd(state[3])
	st	Z+,r19		;store the result[1] to Z[1] (free memory)

	sbiw	XL,3		; X -= 3 (to state[0])
	ld	r17,X+		;load state[0], X++
	call	Multd		;r17=Multd(state[0])
	mov	r19,r17		;r19=r17
	ld	r17,X+		;load state[1], X++
	call	Mult9		;
	eor	r19,r17		;r19 XOR= Mult9(state[1])
	ld	r17,X+		;load state[2], X++
	call	Multe		;
	eor	r19,r17		;r19 XOR= Multe(state[2])
	ld	r17,X		;load state[3]
	call	Multb		;
	eor	r19,r17		;r19 XOR= Multb(state[3])
	st	Z+,r19		;store the result[2] to Z[2] (free memory)

	sbiw	XL,3		; X -= 3 (to state[0])
	ld	r17,X+		;load state[0], X++
	call	Multb		;r17=Multb(state[0])
	mov	r19,r17		;r19=r17
	ld	r17,X+		;load state[1], X++
	call	Multd		;
	eor	r19,r17		;r19 XOR= Multd(state[1])
	ld	r17,X+		;load state[2], X++
	call	Mult9		;
	eor	r19,r17		;r19 XOR= Mult9(state[2])
	ld	r17,X		;load state[3]
	call	Multe		;
	eor	r19,r17		;r19 XOR= Multe(state[3])
	st	Z,r19		;store the result[3] to Z[3] (free memory)

	sbiw	XL,3		; X -= 3 (to state[0])
	sbiw	ZL,3		; Z -= 3 (to result[0])
	ld	r17,Z+
	st	X+,r17
	ld	r17,Z+
	st	X+,r17
	ld	r17,Z+
	st	X+,r17
	ld	r17,Z
	st	X+,r17

	sbiw	ZL,3		; Z -= 3 (to result[0])
	ret


InMixColumns:
	call	InMixOneColumn
	call	InMixOneColumn
	call	InMixOneColumn
	call	InMixOneColumn
	ret

//********** End Mix Columns ***************

;-------------------------------------------
;AES decrypt begins here.
;The Plaintext pointer address passed in Registers (r24 (lo),r25 (hi))
;176 Byte Key pointer address passed in Registers (r22 (lo),r23 (hi))
;500 Byte free SRAM address in Registers (r20 (lo),r21 (hi))

.global	AES_dec
.type	AES_dec,@function
AES_dec:
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
	push r28
	push r29
	push r30
	push r31

	;Begin decrypt source code

	mov	ZL,r20		; Z=[r21 r20]
	mov	ZH,r21		;copy free memory address in Z reg

	clr	r16
	st	Z,r16		; freemem[0]=0

	mov	YL,r22		; Y=[r29 r28]
	mov	YH,r23		;copy roundkey address to Y reg
	adiw	YL,60		; Y += 60
	adiw	YL,60		; Y += 60 (Y += 120)
	adiw	YL,40		; Y += 40 (Y += 160) (start of the last round key)

	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg

	call 	AddRoundKey
	sbiw	YL,32		; Y -= 32 (the start of the before round key)

DecryptionLoop:
	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg
	call	InSubBytes
	;...................................

	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg
	call	InShiftRows
	;...................................

	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg
	call 	AddRoundKey
	sbiw	YL,32		; Y -= 32 (the start of the before round key)
	;...................................

	mov	ZL,r20		; Z=[r21 r20]
	mov	ZH,r21		;copy free memory address in Z reg
	
	ld	r16,Z		;load freemem[0]

	cpi	r16,0x09	;compare if loop counter equals 9 (the last round)
	breq	DecSkipInMixColumn

	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy plain/cipher address to X reg

	mov	ZL,r20		; Z=[r21 r20]
	mov	ZH,r21		;copy free memory address in Z reg
	adiw	ZL,0x01		;skip 1 first byte
	call	InMixColumns
	;...................................

DecSkipInMixColumn:
	mov	ZL,r20		; Z=[r21 r20]
	mov	ZH,r21		;copy free memory address in Z reg
	
	ld	r16,Z		;load freemem[0]
	inc	r16
	st	Z,r16

	cpi	r16,0x0a	;compare if loop counter equals 10 (the last round)
	brne	DecryptionLoop

	pop r31
	pop r30
	pop r29
	pop r28
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	clr r1
	ret

;end decrypt

;-------------------------------------------
RconTable:
	.word 0x1b36
	.word 0x4080
	.word 0x1020
	.word 0x0408
	.word 0x0102

;-------------------------------------------
;begin schedule_key
;Pointer to the original key in Registers (r24 (lo),r25 (hi))
;Pointer to 176 Byte expanded key in Registersr (r22 (lo),r23 (hi))
;Pointer to 500 Byte free SRAM in Registers (r20 (lo),r21 (hi))

.global	schedule_key
.type	schedule_key,@function
schedule_key:
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
	push r28
	push r29
	push r30
	push r31

	mov	ZL,r20		; Z=[r21 r20]
	mov	ZH,r21		;copy free memory address in Z reg

	mov	YL,r22		; Y=[r29 r28]
	mov	YH,r23		;copy roundkey address to Y reg

	mov	XL,r24		; X=[r27 r26]
	mov	XH,r25		;copy Key address to X reg

	ldi	r16,0x10		;counter=16

CopyKeyLoop:
	ld	r17,X+		;load key byte and (X++)
	st	Y+,r17		;store roundkey0 with key and (Y++)

	dec	r16
	brne 	CopyKeyLoop
;...........................................

	ldi	r16,40		;counter=40

GenerateRoundKeysLoop:
	movw	XL,YL		;copy X=Y (address)
;...........................................
	mov	r17,r16		; copy round counter
	andi	r17,3		; just two first bits of the round counter
	brne	GenerateRoundKeysNormal
	
GenerateRoundKeysSpecial:
	; comes here only when (round counter) % 4 == 0
	; Copy, RotWord, and Sbox together..
	sbiw	XL,3		; X -= 3 (three bytes before)
	ld	r17,X+
	call	Sbox
	st	Y+,r17		; Y+ = Sbox(X+)
	ld	r17,X+
	call	Sbox
	st	Y+,r17		; Y+ = Sbox(X+)
	ld	r17,X
	call	Sbox
	st	Y+,r17		; Y+ = Sbox(X)
	sbiw	XL,3		; X -= 3 (four bytes before)
	ld	r17,X
	call	Sbox
	st	Y,r17		; Y = Sbox(X)
	sbiw	YL,3		; Y -=3 (start of these four bytes)
	
	; Read Rcon.........................
	mov	r17,r16		; copy round counter
	lsr	r17			; r17 >> = 1
	lsr	r17			; r17 >> = 1   (r17 /= 4)
	dec	r17			; r17--
	ldi	ZL,lo8(RconTable)	; Z = [r31 r30]
	ldi	ZH,hi8(RconTable)	; Initialize Z-pointer to the RconTable
	add	ZL,r17
	clr	r17
	adc 	ZH,r17 		; add r17 as input of the RconTable to the table pointer
	lpm 	r17, Z 		; Load Rcon value to r17

	; XOR Rcon..........................
	ld	r18,Y		; load first byte of these four bytes
	eor	r18,r17		; Byte XOR = Rcon
	st	Y,r18		; store back the XORed result
	jmp	GenerateRoundKeysContinue

GenerateRoundKeysNormal:
	; Copy..............................	
	sbiw	XL,4		; X -= 4 (four bytes before)
	ld	r17,X+
	st	Y+,r17		; Y+ = X+
	ld	r17,X+
	st	Y+,r17		; Y+ = X+
	ld	r17,X+
	st	Y+,r17		; Y+ = X+
	ld	r17,X
	st	Y,r17		; Y = X
	sbiw	YL,3		; Y -= 3 (start of these four bytes)

GenerateRoundKeysContinue:
	; XOR with 16 bytes before round keys
	movw	XL,YL		;copy X=Y (address)
	sbiw	XL,16		; X -= 16 (16 bytes before)
	ld	r17,X+		; load X and X++
	ld	r18,Y		; load Y
	eor	r18,17		
	st	Y+,r18		; Y+ XOR= X
	ld	r17,X+		; load X and X++
	ld	r18,Y		; load Y
	eor	r18,17		
	st	Y+,r18		; Y+ XOR= X

	ld	r17,X+		; load X and X++
	ld	r18,Y		; load Y
	eor	r18,17		
	st	Y+,r18		; Y+ XOR= X

	ld	r17,X+		; load X and X++
	ld	r18,Y		; load Y
	eor	r18,17		
	st	Y+,r18		; Y+ XOR= X

	dec	r16
	breq 	GenerateRoundKeysEnd
	jmp	GenerateRoundKeysLoop

GenerateRoundKeysEnd:
	pop r31
	pop r30
	pop r29
	pop r28
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	clr r1
	ret

;end schedule_key
