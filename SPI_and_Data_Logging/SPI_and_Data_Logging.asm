$MODDE2

org 0000H
   ljmp MyProgram

MISO   EQU  P0.0 
MOSI   EQU  P0.1 
SCLK   EQU  P0.2
CE_ADC EQU  P0.3

FREQ   EQU 33333333
BAUD   EQU 115200
T2LOAD EQU 65536-(FREQ/(32*BAUD))


DSEG at 30H

x:       	ds 2
y:      	ds 2
bcd:		ds 3
temperature1: ds 1
temperature2: ds 1

BSEG

mf:     dbit 1

CSEG

$include(math16.asm)

; Look-up tables
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H        ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H        ; 4 TO 9
    
myASCII:
	DB 30H, 31H, 32H, 33H, 34H			; 0 TO 4
	DB 35H, 36H, 37H, 38H, 39H			; 4 TO 9
	DB 088H, 083H, 0C6H, 0A1H, 086H, 0FFH	; A TO F
        

SendString:
	mov dptr, #myASCII
	; Display Digit 1 ( Backwards because bits are recieved least to most significant )
    mov A, bcd+0
    swap a
    anl a, #0fh
    movc A, @A+dptr
    lcall putchar
	; Display Digit 0
    mov A, bcd+0
    anl a, #0fh
    movc A, @A+dptr
    lcall putchar
    mov a, #'\r'
    lcall putchar
    mov a, #'\n'
    lcall putchar
    ret

Wait1Sec: 
	mov R2, #180 
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
	djnz R1, L2
	djnz R2, L3
    ret

INIT_SPI:
    orl P0MOD, #00000110b ; Set SCLK, MOSI as outputs
    anl P0MOD, #11111110b ; Set MISO as input
    clr SCLK              ; For mode (0,0) SCLK is zero
	ret

InitSerialPort:
	clr TR2 ; Disable timer 2
	mov T2CON, #30H ; RCLK=1, TCLK=1 
	mov RCAP2H, #high(T2LOAD)  
	mov RCAP2L, #low(T2LOAD)
	setb TR2 ; Enable timer 2
	mov SCON, #52H
	ret
	
DO_SPI_G:
	push acc
    mov R1, #0            ; Received byte stored in R1
    mov R2, #8            ; Loop counter (8-bits)
DO_SPI_G_LOOP:
    mov a, R0             ; Byte to write is in R0
    rlc a                 ; Carry flag has bit to write
    mov R0, a
    mov MOSI, c
    setb SCLK             ; Transmit
    mov c, MISO           ; Read received bit
    mov a, R1             ; Save received bit in R1
    rlc a
    mov R1, a
    clr SCLK
    djnz R2, DO_SPI_G_LOOP
    pop acc
    ret

LCD_command:
        mov LCD_DATA, A
        clr LCD_RS
        nop
        nop
        setb LCD_EN        ;Enable pulse should be at least 230 ns
        nop
        nop
        nop
        nop
        nop
        nop
        clr LCD_EN
        ljmp Wait40us

LCD_put:
        mov LCD_DATA, A
        setb LCD_RS
        nop
        nop
        setb LCD_EN        ;Enable pulse should be at least 230 ns
        nop
        nop
        nop
        nop
        nop
        nop
        clr LCD_EN
        ljmp Wait40us

ClearScreen:                ;Clears screen
        mov a, #01H 
        lcall LCD_command        
        mov R1, #40
        lcall Clr_loop
        ret

Clr_loop:
        lcall Wait40us
        djnz R1, Clr_loop
        ret        

WriteTemp:
		lcall ClearScreen
		mov a, #80H
        lcall LCD_command
        mov a, #'T'
        lcall LCD_put
        mov a, #'E'
        lcall LCD_put
        mov a, #'M'
        lcall LCD_put
        mov a, #'P'
        lcall LCD_put
        mov a, #'E'
        lcall LCD_put
        mov a, #'R'
        lcall LCD_put
        mov a, #'A'
        lcall LCD_put
        mov a, #'T'
        lcall LCD_put
        mov a, #'U'
        lcall LCD_put
        mov a, #'R'
        lcall LCD_put
        mov a, #'E'
        lcall LCD_put
        mov a, #':'
        lcall LCD_put
        mov a, #' '
        lcall LCD_put
        ret
        
CheckDesiredTemp:  
	  lcall ClearDisplay      
      clr c
      mov a, bcd+0
      ;add a, #1
      mov b, temperature1+0
      subb a, b
      jc M10
      lcall Heat_off
      sjmp M9
M10:  lcall Heat_on
M9:	  ret
            
ClearDisplay: 
	mov HEX0, #0FFH
	mov HEX1, #0FFH
	mov HEX2, #0FFH
	ret
	
Heat_on:
	mov HEX1, #0C0H
	mov HEX0, #2BH
	ret

Heat_off:
	mov HEX2, #0C0H
	mov HEX1, #0EH
	mov HEX0, #0EH
	ret
	
SetTemp:
	jb KEY.1, M3
    jnb KEY.1, $                                                        ;if KEY.1 is pressed, increment seconds
    mov a, temperature1
    add a, #1
    da a
    mov temperature1, a
    ;cjne A, #100H, M3
    ;mov temperature1, #0
M3: mov dptr, #myLUT
	; Display Digit 0
    mov A, temperature1
    anl a, #0fh
    movc A, @A+dptr
    mov HEX6, A
	; Display Digit 1
    mov A, temperature1
    swap a
    anl a, #0fh
    movc A, @A+dptr
    mov HEX7, A
    jb SWA.0, SetTemp
    ret
    
DisplayLCD:
    lcall WriteTemp
    mov dptr, #myASCII
    ; Display Digit 0
    mov A, bcd+0
    swap a
    anl a, #0fh
    movc A, @A+dptr
    lcall LCD_put
    ; Display Digit 1
    mov A, bcd+0
    anl a, #0fh
    movc A, @A+dptr
    lcall LCD_put
    ; Display Units
    mov a, #'C'
    lcall LCD_put
    ret

Wait40us:
    mov R0, #149
X1: 
    nop
    nop
    nop
    nop
    nop
    nop
    djnz R0, X1        ;9 machine cycles-> 9*30ns*149=40us
    ret

; Channel to read passed in register b
Read_ADC_Channel:
	mov b, #0
	clr CE_ADC
	mov R0, #00000001B ; Start bit:1
	lcall DO_SPI_G
	
	mov a, b
	swap a
	anl a, #0F0H
	setb acc.7 ; Single mode (bit 7).
	
	mov R0, a ;  Select channel
	lcall DO_SPI_G
	mov a, R1          ; R1 contains bits 8 and 9
	anl a, #03H
	mov R7, a
	
	mov R0, #55H ; It doesn't matter what we transmit...
	lcall DO_SPI_G
	mov a, R1    ; R1 contains bits 0 to 7
	mov R6, a
	setb CE_ADC
	ret

putchar:
    jnb TI, putchar
    clr TI
    mov SBUF, a
    ret
	
ConvertVoltage:
	mov x+1, R7
	mov x+0, R6
	
	; The temperature can be calculated as (ADC*500/1024)-273 (may overflow 16 bit operations)
	; or (ADC*250/512)-273 (may overflow 16 bit operations)
	; or (ADC*125/256)-273 (may overflow 16 bit operations)
	; or (ADC*62/256)+(ADC*63/256)-273 (Does not overflow 16 bit operations!)
	
	Load_y(62)
	lcall mul16
	mov R4, x+1
	
	mov x+1, R7
	mov x+0, R6
	
	Load_y(63)
	lcall mul16
	mov R5, x+1
	
	mov x+0, R4
	mov x+1, #0
	mov y+0, R5
	mov y+1, #0
	lcall add16
	
	Load_y(273)
	lcall sub16
	
	lcall hex2bcd
	lcall SendString
	;lcall Display 
	ret

MyProgram:
	mov sp, #07FH
	clr a
	mov LEDG,  a
	mov LEDRA, a
	mov LEDRB, a
	mov LEDRC, a
	orl P0MOD, #00111000b ; make all CEs outputs	
	setb CE_ADC
	mov Temperature1, #0
	lcall INIT_SPI
	lcall InitSerialPort
	
	setb LCD_ON
	clr LCD_EN                ;Default state of enable must be zero
	lcall Wait40us
	mov LCD_MOD, #0xff        ;Use LCD_DATA as output port
	clr LCD_RW                        ;Only writing to the LCD in this code.
	mov a, #0ch                        ;Display on command
	lcall LCD_command
	mov a, #38H                        ;8-bits interface, 2 lines, 5x7 characters
	lcall LCD_command
		
Forever:
	jnb SWA.0, M7
	lcall setTemp
M7:	lcall CheckDesiredTemp
	lcall Read_ADC_Channel	
	lcall ConvertVoltage
	lcall DisplayLCD
	lcall Wait1Sec
	sjmp Forever
END