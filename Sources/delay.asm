; export symbols
            XDEF   delay_0_5_sec        ; Export the symbol delay_0_5_sec

; import symbols
                                        ; (Not used here)

; include processor definitions (if necessary)
            INCLUDE 'mc9s12dp256.inc'

; Defines
        SPEED:  EQU     2048                   ; Change this number to change counting speed

; RAM: global assembler data in RAM
.data: SECTION                          ; (Not used here)

; ROM: Constant data
.const:SECTION                          ; (Not used here)

; ROM: Assembler program code in RAM
.init: SECTION

delay_0_5_sec:
        PSHD
        PSHX
        PSHY

        LDX  #SPEED                      ; Delay loop to control toggle Frequency 
waitO:  LDY  #SPEED                      ; (Uses two nested counter loops with registers X and Y)
waitI:  DBNE Y, waitI                   ; --- Decrement Y and branch to waitI if not equal to 0
        DBNE X, waitO                   ; --- Decrement X and branch to waitO if not equal to 0

        PULY
        PULX
        PULD
        RTS