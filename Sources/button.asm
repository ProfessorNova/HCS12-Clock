; export symbols
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

checkButtons:
    PSHD

    BRCLR PTH,#$01,changeMode
    LDAB isSetMode
    CMPB #$01
    BEQ checkButtonsSetMode

    PULD
    RTS

changeMode:
    LDAB isSetMode
    EORB #$01
    STAB isSetMode
    ; toggle LED 7
    LDAB #$80
    JSR toggleLED
    JSR delay_0_5_sec ; so it doesn't toggle too fast

    PULD
    RTS

checkButtonsSetMode:
    BRCLR PTH,#$02,hourButton
    BRCLR PTH,#$04,minuteButton
    BRCLR PTH,#$08,secondButton

    PULD
    RTS

hourButton:
    JSR incHours
    JSR delay_0_5_sec

    PULD
    RTS

minuteButton:
    JSR incMinutes
    JSR delay_0_5_sec

    PULD
    RTS

secondButton:
    JSR incSeconds
    JSR delay_0_5_sec

    PULD
    RTS
