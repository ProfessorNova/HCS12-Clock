;********************************************************************
; Module: led.asm
; Description: This module controls the initialization and manipulation
; of the LEDs.
;********************************************************************

; Export symbols
            XDEF   initLED, setLED, getLED, toggleLED

; Include processor definitions (if necessary)
            INCLUDE 'mc9s12dp256.inc'

; ROM: Assembler program code in RAM
.init: SECTION

;********************************************************************
; Public interface function: initLED ... Initializes all required ports 
; to drive the LEDs. At the end of this function all LEDs are turned off.
; Parameter: -
; Return:    -
initLED:
    PSHD

    BSET DDRJ, #2                   ; Bit Set:   Port J.1 as output
    BCLR PTJ,  #2                   ; Bit Clear: J.1=0 --> Activate LEDs

    MOVB #$FF, DDRB                 ; $FF -> DDRB:  Port B.7...0 as outputs (LEDs)

    PULD
    RTS

;********************************************************************
; Public interface function: setLED ... Sets the LEDs according to the parameter.
; Parameter: B - Bits in this parameter define which LEDs are turned on (1) or off (0).
; Return:    -
setLED:
    PSHD

    STAB PORTB                          ; Set LEDs according to parameter

    PULD
    RTS

;********************************************************************
; Public interface function: getLED ... Returns the current LED status.
; Parameter: -
; Return:    B - Bits define which LEDs are currently turned on (1) or off (0).
getLED:
    LDAB PORTB                          ; Get current LED status

    RTS

;********************************************************************
; Public interface function: toggleLED ... Toggles the LEDs according to the parameter.
; Parameter: B - Bits define which LEDs are toggled.
; Return:    -
toggleLED:
    PSHD

    EORB PORTB                          ; Toggle LEDs according to parameter
    STAB PORTB
    
    PULD
    RTS
