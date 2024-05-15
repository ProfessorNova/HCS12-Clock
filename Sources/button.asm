;********************************************************************
; Module: button.asm
; Description: This module handles the button inputs and toggles 
; between normal and set mode. It also increments hours, minutes, 
; and seconds based on button presses.
;********************************************************************

; Export symbols
    XDEF checkButtons  

; Import symbols
    XREF isSetMode
    XREF toggleLED
    XREF delay_0_5_sec
    XREF incHours
    XREF incMinutes
    XREF incSeconds

; RAM: Variable data section
.data: SECTION

; ROM: Constant data
.const: SECTION

; ROM: Code section
.init: SECTION

; Include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

;********************************************************************
; Public interface function: checkButtons ... Checks button states
; and handles mode switching and time increments.
; Parameter: -
; Return:    -
; Note:      BRCLR needs to be changed to BRSET if program is used in Simulator
checkButtons:
    PSHD

    BRCLR PTH,#$01,changeMode   ; Check button for mode change
    LDAB isSetMode
    CMPB #$01
    BEQ checkButtonsSetMode     ; If in set mode, check set mode buttons

    PULD
    RTS

;********************************************************************
; Internal function: changeMode ... Toggles between normal and set mode.
; Parameter: -
; Return:    -
changeMode:
    LDAB isSetMode
    EORB #$01
    STAB isSetMode
    ; Toggle LED 7
    LDAB #$80
    JSR toggleLED
    JSR delay_0_5_sec ; Prevents fast toggling

    PULD
    RTS

;********************************************************************
; Internal function: checkButtonsSetMode ... Checks buttons in set mode
; and increments hours, minutes, or seconds.
; Parameter: -
; Return:    -
; Note:      BRCLR needs to be changed to BRSET if program is used in Simulator
checkButtonsSetMode:
    BRCLR PTH,#$02,hourButton
    BRCLR PTH,#$04,minuteButton
    BRCLR PTH,#$08,secondButton

    PULD
    RTS

;********************************************************************
; Internal function: hourButton ... Increments hours.
; Parameter: -
; Return:    -
hourButton:
    JSR incHours
    JSR delay_0_5_sec

    PULD
    RTS

;********************************************************************
; Internal function: minuteButton ... Increments minutes.
; Parameter: -
; Return:    -
minuteButton:
    JSR incMinutes
    JSR delay_0_5_sec

    PULD
    RTS

;********************************************************************
; Internal function: secondButton ... Increments seconds.
; Parameter: -
; Return:    -
secondButton:
    JSR incSeconds
    JSR delay_0_5_sec

    PULD
    RTS
