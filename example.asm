
;====================================================================
; Main.asm file generated by New Project wizard
;
; Created:   Thu Jun 25 2015
; Processor: PIC18F1220
; Compiler:  MPASM (Proteus)
;====================================================================

;====================================================================
; DEFINITIONS
;====================================================================

#include p18f1220.inc                ; Include register definition file
        LIST
;==========================================================================
;  MPASM PIC18F1220 processor include
; 
;  (c) Copyright 1999-2012 Microchip Technology, All rights reserved
;==========================================================================

        LIST
        CONFIG OSC = INTIO2
        CONFIG WDT = OFF
        CONFIG WDTPS = 4096
        CONFIG MCLRE = ON       ; NO Access RA5
        CONFIG DEBUG = ON       ; NO Access RB6/RB7
        CONFIG LVP = OFF
               
;====================================================================
; VARIABLES
;====================================================================   

;global lResult,hResult, chanel_select, chanel_select_shift, valL, valH
;global outv, uCounter, retval

lResult res 1 ; equ 0x00
hResult res 1 ; equ 0x01
chanel_select res 1 ; equ 0x02
chanel_select_shift  res 1 ; equ 0x03
valL  res 1 ; equ 0x04
valH  res 1 ; equ 0x05
outv      res 1 ; equ 0x06
uCounter res 1 ; equ 0x07
retval  res 1 ; equ 0x08
;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

      ; Reset Vector
RST   code  0x0 
      goto  Start

;====================================================================
; CODE SEGMENT
;====================================================================

PGM   code
;Start
      ; Write your code here
;Loop  
      ;goto  Loop

;====================================================================
; MAIN LOOP
;====================================================================

Start
        movlw   b'11111111'
        movwf   OSCTUNE,W       
        bsf     OSCCON, 6
        bsf 	OSCCON, 5
        bsf 	OSCCON, 4
Begin
        movlw   d'1'            ; Used to determine the correct Port to select from
        call    ADC_Config      ; Configure the ADC to read from ADC Port
        call    ADC_Start_Conversion    ; Call the routine to start the conversion

CHECKSTAT       
        btfsc   ADCON0,GO
        goto 	CHECKSTAT
        call 	ADC_Get_Value
        call 	ADC_Split_8
        call 	DIG_PortB_Config
        call 	DIG_PortB_OUT
        goto 	Begin
        
;====================================================================
; CODE SEGMENT
;====================================================================


DIG_PortB_OUT
        movlw   b'00000000'
        movwf   outv,0
        movlw   b'10000000'
        movwf   chanel_select_shift,0
        movff   retval,uCounter
while_2
        tstfsz  uCounter ; while_2
        goto 	while_2_notzero
        goto 	while_2_zero
while_2_notzero
        movf    chanel_select_shift,0
        rlcf    chanel_select_shift,0
        btfss   STATUS,C ; if_3
        goto 	if_3_false
        goto 	if_3_true
if_3_true
        addlw   0x01
        goto 	if_3_end
if_3_false
        addlw   0x00
if_3_end
        movwf   chanel_select_shift,0
        iorwf   outv
        decf    uCounter,0
        movwf   uCounter
        goto 	while_2
while_2_zero
        movwf   outv, PORTB
        return

DIG_PortB_Config
        clrf    PORTB,0
        movlw   b'00000000'
        movwf   ADCON1,0
        movlw   b'00000000'
        movwf   TRISB,0
        return

ADC_Config      
        movwf   chanel_select
        clrf   	PORTA       ; Ensure PORTA is zero before we enable
                           ;  the port for the ADC input
        ;movlw  b'00000001'
        ;movwf  ADCON0
        movff   chanel_select,chanel_select_shift
        rlncf   chanel_select_shift,0
        rlncf   chanel_select_shift,0
        bcf     ADCON0, VCFG1
        bcf     ADCON0, VCFG0
        bcf     ADCON0, CHS2
        bcf     ADCON0, CHS1
        bcf     ADCON0, CHS0
        bsf     ADCON0, ADON
        movf    chanel_select_shift, W,0
        iorwf   ADCON0,0
        movwf   ADCON0,0
;       bsf             ADCON0, ADON     
        movff   chanel_select,chanel_select_shift
        movlw   b'10000000'
        movwf   retval,0
        
while_1
        tstfsz  chanel_select_shift ; test is flag is zero_1 skip next step if  zero
        goto    while_1_notzero
        goto    while_1_zero
while_1_notzero
        rlcf    W,0
        btfss   STATUS,C
        addlw   0x00
        addlw   0x01
        movwf   retval,0
        decf    chanel_select_shift,0
        goto 	while_1
while_1_zero
        rlcf    W,0
        btfss   STATUS,C
        addlw   0x00
        addlw   0x01
        movwf   retval,0

        ; Continue Process

        ;movlw  b'11111110'
        movff   retval, ADCON1          ; Turn on the ADC A0
        ;bsf    ADCON1,PCFG6
        ;bsf    ADCON1,PCFG5
        ;bsf    ADCON1,PCFG4
        ;bsf    ADCON1,PCFG3
        ;bcf    ADCON1,PCFG2
        ;bsf    ADCON1,PCFG1
        ;bcf    ADCON1,PCFG0    ; AD0 as AD input
        ;movlw  b'11111100'
        ;movwf   ADCON2
        bsf             ADCON2, ADFM
        bcf             ADCON2, ACQT2
        bcf             ADCON2, ACQT1
        bcf             ADCON2, ACQT0
        bcf             ADCON2, ADCS2
        bcf             ADCON2, ADCS1
        bcf             ADCON2, ADCS0
        return 

ADC_Start_Conversion
        bsf             ADCON0,GO
        return

ADC_Check_Conversion
        return
        
ADC_Get_Value
        movff   ADRESL,lResult
        movff   ADRESH,hResult
        clrwdt
        return
        
ADC_Split_8 
; if_2 = 0 true, else false
        btfsc   ADCON2, ADFM    
        goto    if_2_true; ADC_left_just; if right jsutified adfm = 1
        goto    if_2_false;ADC_right_just ; if left justified adfm = 0
if_2_true;      ADC_right_just
        ;       mask b'0000 0011' & hResult -> mValH
        movff   hResult, valH
        movf    valH,0  ; move uResult to W
        andlw   0x03    ; OR W(hResult) with the mask
        movwf   valH
        rlncf   valH,0          ; Rotate Left W(hResult)
        movwf   retval,0
        ;       mask b'1000 0000' & lResult -> mvalL
        movff   lResult, valL
        movf    valL,0  ; move lResult to W
        andlw   0x80    ; OR W(lResult) with the mask
        movwf   valL
        rlcf    valL            ; Rotate Left W(lResult)
        movf    valL,0
        btfss   STATUS,C
        addlw   0x00
        addlw   0x01
        iorwf   retval; or the high bit and low bit, put into retval
        goto 	if_2_end
if_2_false  ;ADC_left_just
        ;mask b'1110 0000'&ValH
        movf    hResult,W,0     ; move uResult to W
        andlw   b'11100000'     ; OR W(uResult) with the mask
        rlcf    W,0                     ; Rotate Left W(uResult) b'11000001'
        rlcf    W,0                     ; Rotate Left W(uResult) b'10000011'
        rlcf    W,0                     ; Rotate Left W(uResult) b'00000111'
        movwf   retval,0                ; Return the retval
if_2_end
        return
		END
