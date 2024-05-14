; export symbols
        XDEF decToASCII

; Defines

; RAM: Variable data section
.data: SECTION

; ROM: Constant data
.const: SECTION

; ROM: Code section
.init: SECTION

decToASCII:

; Convert a integer value to ASCII
; Input: val: integer value in register D
;        string: pointer to location in RAM in register X

        PSHD
        PSHX
        PSHY

; test if val is >= 0
        CPD     #0
        BGE     isPositive

; if val < 0
        ; use stack so val is not overwritten
        PSHD
        LDAB    #'-'
        STAB    1,X+
        PULD
        COMA
        COMB
        ADDD    #1
        BRA     devisions

isPositive:
        PSHD
        LDAB    #' '
        STAB    1,X+
        PULD
        BRA     devisions

devisions:
        ; transfer the counter to Y
        TFR     X, Y
        ; (Q=>X, R=>D) = D / X
        LDX    #10000
        IDIV
        ; transfer X to D for addition
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    1,Y+
        PULD

        LDX     #1000
        IDIV
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    1,Y+
        PULD

        LDX     #100
        IDIV
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    1,Y+
        PULD

        LDX     #10
        IDIV
        ; store the remainder on Y
        PSHY
        TFR     D, Y
        TFR     X, D
        ADDD    #'0'
        ; switch index in X
        PULX
        STAB    1,X+

        ; restore the remainder in D
        TFR     Y, D
        ADDD    #'0'
        STAB    1,X+

        ; terminate the string
        LDAB    #0
        STAB    1,X+

        PULY
        PULX
        PULD
        RTS
