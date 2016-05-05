.text
.global IntE2wrt, IntE2read

.set EEARH,0x1F // EEARH EEPROM Address Register High-byte
.set EEARL,0x1E // EEARL EEPROM Address Register Low-byte
.set EEDR,0x1D  // EEDR EEPROM Data Register
.set EECR,0x1C  // EECR EEPROM Control Register


IntE2wrt:
; E2address  r25:r24 
; Byte Value (r23=0):r22

	out	EEARH,r25
	out	EEARL,r24		; copy E2address to E2address registers

	out	EEDR,r22		; copy E2data to E2data register
	
	sbi	EECR,2			; set mastre write enable bit (EEMWE)
	sbi	EECR,1			; set write enable bit (EEWE)

IntE2wrtWait:
	sbic	EECR,1
	jmp	IntE2wrtWait	; wait for finishing the write command

	cbi	EECR,2			; clear mastre write enable bit (EEMWE)

	ret

IntE2read:
; E2address  r25:r24 
; Output Byte Value r24

	out	EEARH,r25
	out	EEARL,r24		; copy E2address to E2address registers

	sbi	EECR,0			; set read enable bit (EERE)

IntE2readWait:
	sbic	EECR,0
	jmp	IntE2readWait	; wait for finishing the read command

	in	r24,EEDR

	ret
