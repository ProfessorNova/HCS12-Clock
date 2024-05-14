; export symbols
            XDEF   initLED, setLED, getLED, toggleLED

; import symbols
                                        ; (Not used here)

; include processor definitions (if necessary)
            INCLUDE 'mc9s12dp256.inc'

; RAM: global assembler data in RAM
.data: SECTION                          ; (Not used here)

; ROM: Constant data
.const: SECTION                         ; (Not used here)

; ROM: Assembler program code in RAM
.init: SECTION

; This subroutine initializes all required ports to drive the LEDs. At the end of this function all LEDs are turned off.
initLED:
    PSHD

    BSET DDRJ, #2                   ; Bit Set:   Port J.1 as output
    BCLR PTJ,  #2                   ; Bit Clear: J.1=0 --> Activate LEDs

endif
    MOVB #$FF, DDRB                 ; $FF -> DDRB:  Port B.7...0 as outputs (LEDs)

    PULD
    RTS

; This subroutine has an 8 bit calling parameter in register B. The bits in this parameter define, which of the 8 LEDs are to be turned on (1) or off (0).
setLED:
    PSHD

    STAB PORTB                          ; Set LEDs according to parameter

    PULD
    RTS

; This subroutine returns an 8 bit value in register B. The bits in this value define, which of the 8 LEDs are currently turned on (1) or off (0).
getLED:
    LDAB PORTB                          ; Get current LED status

    RTS

; This subroutine has an 8 bit calling parameter in register B. The bits define, which of the 8 LEDs shall be toggled.
toggleLED:
    PSHD

    EORB PORTB                          ; Toggle LEDs according to parameter
    STAB PORTB
    
    PULD
    RTS
