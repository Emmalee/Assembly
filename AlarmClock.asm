 ; Alarm Clock with 2 settable alarms, snooze, and LEDs and buzzer
; by Emmalee Roach 
; Displays seconds, minuts, and hours in HEX2 to HEX7 and AMPM in HEX0
; To set the time: flip SW0 and using KEY.3, KEY.2, KEY.1 to increment the Hours, Minutes, and Seconds.
; To set alarm 1: flip SW1 and using Key.3, Key,2, Key.1
; To disable alarm 1: flip SW2  
; To set alarm 2: flip SW3 and using Key.3, Key,2, Key.1
; To disable alarm 2: flip SW4
; To turn alarm off: flip SW5
; To snooze(increment current alarm by 10 minutes): flip SW6
; To set LEDs instead of buzzer: flip SW7
; To set LEDs and buzzer: flip SW8

$MODDE2

org 0000H
	ljmp myprogram
	
org 000BH
	ljmp ISR_timer0
	
DSEG at 30H
count10ms:    ds 1
count10ms_LED:ds 1
count10ms_alarm: ds 1
seconds:      ds 1
minutes:      ds 1
hours:        ds 1
AM_PM:        ds 1
alarm_hours:   ds 1
alarm_minutes: ds 1
alarm_seconds: ds 1
alarm_hours_2: ds 1
alarm_minutes_2: ds 1
alarm_seconds_2: ds 1
on_off:        ds 1
alarm1_snz:    ds 1
alarm2_snz:    ds 1
saved_hours:   ds 1
saved_minutes: ds 1
saved_seconds: ds 1
CSEG


; Look-up table for 7-segment displays
myLUT:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H
    DB 092H, 082H, 0F8H, 080H, 090H
    DB 0FFH ; All segments off

XTAL           EQU 33333333
FREQ           EQU 100
TIMER0_RELOAD  EQU 65538-(XTAL/(12*FREQ))

ISR_Timer0:
	; Reload the timer
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
    
    ; Save used register into the stack
    push psw
    push acc
    push dph
    push dpl
    
    jb SWA.0, ISR_Timer0_L0 ; Setting up time.  Do not increment anything
   
    
    ; Increment the counter and check if a second has passed
    inc count10ms
    mov a, count10ms
    cjne A, #100, ISR_Timer0_L0
    mov count10ms, #0
    
    mov a, seconds
    add a, #1
    da a
    mov seconds, a
    cjne A, #60H, ISR_Timer0_L0
    mov seconds, #0

    mov a, minutes
    add a, #1
    da a
    mov minutes, a
    cjne A, #60H, ISR_Timer0_L0
    mov minutes, #0

    mov a, hours
    add a, #1
    da a
    mov hours, a
    
    cjne a, #12H, L1              ;check if am/pm needs updating
    sjmp AMPM
    
L1: cjne A, #13H, ISR_Timer0_L0   ;check if time changes from 12 to 1 
    mov hours, #1
    
AMPM:                            ;update am/pm   
	cjne r7, #08H, AM  
PM:	
 	mov HEX0, #0CH
 	mov r7, #0CH
 	ljmp L1
AM:
 	mov HEX0, #08H
	mov r7, #08H

	    
ISR_Timer0_L0:

	; Update the display.  This happens every 10 ms
    
    jb SWA.1, ISR_Timer0_L2 ; Setting up alarm1
    jb SWA.3, ISR_Timer0_alarm2 ;Setting up alarm2  
    
	mov dptr, #myLUT

	mov a, seconds
	anl a, #0fH
	movc a, @a+dptr
	mov HEX2, a
	mov a, seconds
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX3, a

	mov a, minutes
	anl a, #0fH
	movc a, @a+dptr
	mov HEX4, a
	mov a, minutes
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX5, a

	mov a, hours
	anl a, #0fH
	movc a, @a+dptr
	mov HEX6, a
	mov a, hours
	jb acc.4, ISR_Timer0_L1
	mov a, #0A0H

ISR_Timer0_L1:
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX7, a
	ljmp ISR_TIMER0_L4

ISR_TIMER0_L2:        ;display time when setting alarm1
	
	mov dptr, #myLUT
	
	
	mov a, alarm_seconds
	anl a, #0fH
	movc a, @a+dptr
	mov HEX2, a
	mov a, alarm_seconds
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX3, a

	mov a, alarm_minutes
	anl a, #0fH
	movc a, @a+dptr
	mov HEX4, a
	mov a, alarm_minutes
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX5, a

	mov a, alarm_hours
	anl a, #0fH
	movc a, @a+dptr
	mov HEX6, a
	mov a, alarm_hours
	jb acc.4, ISR_Timer0_L3
	mov a, #0A0H
	ljmp ISR_Timer0_L3
		
ISR_TIMER0_alarm2:        ;display time when setting alarm2
	
	mov dptr, #myLUT
	
	mov a, alarm_seconds_2
	anl a, #0fH
	movc a, @a+dptr
	mov HEX2, a
	mov a, alarm_seconds_2
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX3, a

	mov a, alarm_minutes_2
	anl a, #0fH
	movc a, @a+dptr
	mov HEX4, a
	mov a, alarm_minutes_2
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX5, a

	mov a, alarm_hours_2
	anl a, #0fH
	movc a, @a+dptr
	mov HEX6, a
	mov a, alarm_hours_2
	jb acc.4, ISR_Timer0_L3
	mov a, #0A0H

ISR_Timer0_L3:
	swap a
	anl a, #0fH
	movc a, @a+dptr
	mov HEX7, a
	
ISR_TIMER0_L4:
	
	jnb SWA.5,ISR_TIMER0_L5    ;check if off switch is triggered
	
	mov a, alarm1_snz         
	cjne a, #1, restore_2
	mov alarm_hours, saved_hours      ;when snooze is turned off alarm is reset to original value
	mov alarm_minutes, saved_minutes
	mov alarm_seconds, saved_seconds
	ljmp off
restore_2:
	mov alarm_hours_2, saved_hours
	mov alarm_minutes_2, saved_minutes
	mov alarm_seconds_2, saved_seconds
off:	
	mov LEDG, #0               ;turn off leds
	setb p0.1                  ;turn off buzzer
	mov r2, #0                 ;save off
	               

ISR_TIMER0_L5:

	mov a, r2              ;r2 is 1 if alarm has already gone off
	cjne a, #1, E1
	ljmp Buzz 
E1:		
	jb SWA.1, E2          ;do not sound alarm if in setting_alarm mode
	jb SWA.2, E2          ;do not sound alarm if disable switch on
	mov a, hours
	cjne a, alarm_hours, E2
	mov a, minutes 
	cjne a, alarm_minutes, E2
	mov a, seconds
	cjne a, alarm_seconds, E2
	mov a, r7
	mov b, r1
	cjne a, b, E2
	mov r2, #1                ;set r2 to 1 when alarm goes off
	mov alarm1_snz, #1        ;save alarm1 is on for snooze later
	ljmp Buzz
E2:		
	jb SWA.3, ending_ISR         ;do not sound alarm if in setting_alarm 2 mode
	jb SWA.4, ending_ISR         ;do not sound alarm if disable switch is on
	mov a, hours
	cjne a, alarm_hours_2, ending_ISR
	mov a, minutes 
	cjne a, alarm_minutes_2, ending_ISR
	mov a, seconds
	cjne a, alarm_seconds_2, ending_ISR
	mov a, r7
	mov b, r5
	cjne a, b, ending_ISR
	mov r2, #1                ;set r2 to 1 when alarm turns on
	mov alarm2_snz, #1        ;save alarm2 is on for snooze later

Buzz:
	jb SWA.6, Snooze   		   ;check if snooze switch is triggered 
	jb SWA.7, LED_option       ;check if LED option switch is triggered	
	
	inc count10ms_alarm
	mov a, count10ms_alarm     ;make alarm sound realistic by turning buzzer on/off
	cjne a, #20, alarming
	mov count10ms_alarm, #0
	ljmp end_ISR

alarming:	
	inc count10ms_alarm
	mov a, count10ms_alarm
	clr c
	subb a, #30
	jc ending_ISR
	cpl P0.1
	
	mov a, SWB
	jb acc.0, LED_option     ;check if LED and buzzer switch is triggered
	ljmp end_ISR

LED_option:
	inc count10ms_LED
    mov a, count10ms_LED
    cjne a, #30, ending_ISR   ;turn on/off LEDS every 0.3 seconds
    mov count10ms_LED, #0
    cpl LEDG.0
    cpl LEDG.1
    cpl LEDG.2
    cpl LEDG.3
    cpl LEDG.4
    cpl LEDG.5
    cpl LEDG.6
    cpl LEDG.7

	ljmp end_ISR

ending_ISR:                 
	ljmp end_ISR
    

Snooze:	
	mov LEDG, #0               ;turn off leds
	setb p0.1                  ;turn off buzzer
	mov r2, #0                 ;save alarm off
	
	jb SWA.6, $                ;increment time when switch is switched off
	
	mov a, alarm1_snz         
	cjne a, #1, snz2           ;check if alarm 1/2 is on to know which to snooze 

	mov saved_hours, alarm_hours
	mov saved_minutes, alarm_minutes
	mov saved_seconds, alarm_seconds
	
	mov a, alarm_minutes       ;snooze alarm 1
	add a, #10H
	da a 
	mov alarm_minutes, a
	clr c
	subb a, #60H
	jc end_ISR               
	
	mov alarm_minutes, a

	mov a, alarm_hours
	add a, #1H
	da a
	mov alarm_hours, a
	cjne a, #12H, T2
    sjmp Snooze_AMPM
    	
T2: cjne a, #13H, end_ISR
    mov alarm_hours, #1H
	ljmp end_ISR

Snooze_AMPM:
	cjne r1, #08H, Snooze_AM  	
 	
 	mov HEX0, #0CH    ;set to pm
 	mov r1, #0CH
 	ljmp T2
Snooze_AM:
 	mov HEX0, #08H  ;set to am
	mov r1, #08H
	ljmp T2
	ljmp end_ISR
	
snz2:                               ;snooze alarm2

	mov saved_hours, alarm_hours_2
	mov saved_minutes, alarm_minutes_2
	mov saved_seconds, alarm_seconds_2
	
	mov a, alarm_minutes_2
	add a, #10H
	da a 
	mov alarm_minutes_2, a
	clr c
	subb a, #60H
	jc end_ISR               
	
	mov alarm_minutes_2, a

	mov a, alarm_hours_2
	add a, #1H
	da a
	mov alarm_hours_2, a
	cjne a, #12H, T2
    sjmp Snooze_AMPM_2
    	
H2: cjne a, #13H, end_ISR
    mov alarm_hours_2, #1H
	ljmp end_ISR
	
Snooze_AMPM_2:
	cjne r5, #08H, Snooze_AM  	
 	
 	mov HEX0, #0CH    ;set to pm
 	mov r5, #0CH
 	ljmp H2
Snooze_AM_2:
 	mov HEX0, #08H  ;set to am
	mov r5, #08H
	ljmp H2

end_ISR:
	; Restore used registers
	pop dpl
	pop dph
	pop acc
	pop psw    
	reti

Init_Timer0:	
	mov TMOD,  #00000001B ; GATE=0, C/T*=0, M1=0, M0=1: 16-bit timer
	clr TR0 ; Disable timer 0
	clr TF0
    mov TH0, #high(TIMER0_RELOAD)
    mov TL0, #low(TIMER0_RELOAD)
    setb TR0 ; Enable timer 0
    setb ET0 ; Enable timer 0 interrupt
    mov P0MOD, #00000011B ; P0.0, P0.1 are outputs.  P0.1 is used for testing Timer 2!
    ret

myprogram:
	mov SP, #7FH
	mov LEDRA,#0
	mov LEDRB,#0
	mov LEDRC,#0
	mov LEDG,#0
	
	mov seconds, #00H
	mov minutes, #00H
	mov hours, #12H
	
	mov alarm_seconds, #00H
	mov alarm_minutes, #00H
	mov alarm_hours, #12H
	
	mov alarm_seconds_2, #00H
	mov alarm_minutes_2, #00H
	mov alarm_hours_2, #12H
	
	mov alarm1_snz, #0
	mov alarm2_snz, #0
	
	mov HEX0, #08H  ;initialize clock to AM
	mov r7, #0CH    ;store AM/PM in R7
	mov r1, #08H    ;initalize alarm1 to am
	mov r5, #08H    ;initialize alarm2 to am
	mov r2, #0
	mov r4, #0
	lcall Init_Timer0
    setb EA  ; Enable all interrupts

M0:
	mov HEX0, r7
	jb SWA.1, Alarm_setting       
	jb SWA.3, Alarm_2_setting
	jnb SWA.0, M0
	ljmp set_time

Alarm_setting:	
	mov HEX0, r1                ;update am/pm for alarm1

Updating_alarm:	
	
	jnb SWA.1, M0
	
	jb KEY.3, N1
    jnb KEY.3, $
    mov a, alarm_hours
	add a, #1
	da a
	mov alarm_hours, a
	
	cjne a, #12H, K2              ;check if am/pm needs updating
    sjmp Set_AMPM_alarm        
    	 
K2: cjne A, #13H, N1              ;check if time changes from 12-1
    mov alarm_hours, #1
	ljmp N1
	
Set_AMPM_alarm:
	cjne r1, #08H, Set_AM_alarm  	
 	
 	mov HEX0, #0CH    ;set to pm
 	mov r1, #0CH
 	ljmp K2
Set_AM_alarm:
 	mov HEX0, #08H  ;set to am
	mov r1, #08H
	ljmp K2

N1:	
	jb KEY.2, N2
    jnb KEY.2, $
    mov a, alarm_minutes
	add a, #1
	da a
	mov alarm_minutes, a
    cjne A, #60H, N2
    mov alarm_minutes, #1

N2:	
	jb KEY.1, N3
	jnb KEY.1, $
	mov a, alarm_seconds
	add a, #1
	da a
	mov alarm_seconds, a
    cjne A, #60H, N3
    mov alarm_seconds, #1

N3:	
	ljmp Updating_alarm
	
	
Alarm_2_setting:	
	mov HEX0, r5         ;save alarm2 am/pm in r5

Updating_alarm_2:	
	
	jnb SWA.3, M0
	
	jb KEY.3, I1
    jnb KEY.3, $
    mov a, alarm_hours_2
	add a, #1
	da a
	mov alarm_hours_2, a
	
	cjne a, #12H, Y2
    sjmp Set_AMPM_alarm_2
    	
Y2: cjne A, #13H, I1
    mov alarm_hours_2, #1
	ljmp I1
	
Set_AMPM_alarm_2:
	cjne r5, #08H, Set_AM_alarm_2  	
 	
 	mov HEX0, #0CH    ;set to pm
 	mov r5, #0CH
 	ljmp Y2
Set_AM_alarm_2:
 	mov HEX0, #08H  ;set to am
	mov r5, #08H
	ljmp Y2

I1:	
	jb KEY.2, I2
    jnb KEY.2, $
    mov a, alarm_minutes_2
	add a, #1
	da a
	mov alarm_minutes_2, a
    cjne A, #60H, N2
    mov alarm_minutes_2, #1

I2:	
	jb KEY.1, I3
	jnb KEY.1, $
	mov a, alarm_seconds_2
	add a, #1
	da a
	mov alarm_seconds_2, a
    cjne A, #60H, I3
    mov alarm_seconds_2, #1

I3:	
	ljmp Updating_alarm_2


	
Set_Time:
	jb KEY.3, M1
    jnb KEY.3, $
    mov a, hours
	add a, #1
	da a
	mov hours, a
	
	cjne a, #12H, L2
    sjmp Set_AMPM
    	
L2: cjne A, #13H, M1
    mov hours, #1
	ljmp M1
	
Set_AMPM:
	cjne r7, #08H, Set_AM  	
 	
 	mov HEX0, #0CH    ;set to pm
 	mov r7, #0CH
 	ljmp L2
Set_AM:
 	mov HEX0, #08H  ;set to am
	mov r7, #08H
	ljmp L2

M1:	
	jb KEY.2, M2
    jnb KEY.2, $
    mov a, minutes
	add a, #1
	da a
	mov minutes, a
    cjne A, #60H, M2
    mov minutes, #1

M2:	
	jb KEY.1, M3
	jnb KEY.1, $
	mov a, seconds
	add a, #1
	da a
	mov seconds, a
    cjne A, #60H, M3
    mov seconds, #1

M3:	
	ljmp M0


END

