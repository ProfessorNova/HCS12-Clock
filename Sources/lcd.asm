;********************************************************************
; Module: lcd.asm
; Description: Simple LCD driver for Dragon12's 16x2 LCD.
;********************************************************************

; Export symbols
        XDEF initLCD, writeLine, delay_10ms

; Include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

; RAM: Variable data section
.data:  SECTION
reset_seq:
        ds.b 1
temp1:  ds.b 1

; ROM: Constant data
.const: SECTION

; Initialization command sequences
inidsp1:
  IFDEF  SIMULATOR
        dc.b 3          ; Number of commands
        dc.b $30        ; Reset char
        dc.b $30        ; Reset char
        dc.b $30        ; Reset char
  ELSE
        dc.b 2          ; Number of commands
        dc.b $33        ; Reset char
        dc.b $32        ; Reset char
  ENDIF

inidsp2:
        dc.b 4          ; Number of commands
  IFDEF  SIMULATOR
        dc.b $38        ; Command Function Set:    8 bit mode, 2 rows, 5 X 7 dot matrix
  ELSE
        dc.b $28        ; Command Function Set:    4 bit mode, 2 rows, 5 X 7 dot matrix
  ENDIF
        dc.b $0C        ; Command Display Control: display on, cursor off, non blinking
        dc.b $01        ; Command Clear display:   clear display memory, set cursor to home position
        dc.b $06        ; Command Entry Mode Set:  cursor increment, disable display shift

; Defines
ONE_MS:   equ   4000    ; 4000 x 250ns = 1 ms at 24 MHz bus speed
FIVE_MS:  equ   20000   ; 5 x above value
TEN_MS:   equ   40000   ; 10x above value
FIFTY_US: equ   200     ; 50 usecs = 200*250ns

LCD:      equ   PORTK   ; Port for LCD data bus
DATAMASK: equ   $3C     ; Bit 5...2 on LCD
REG_SEL:  equ   $01     ; Bit 0 on LCDCTRL: signal RS: 0=reg,    1=data

  IFDEF  SIMULATOR
        LCDCTRL:  equ   PORTA   ; Port LCD control signals
        ENABLE:   equ   $04     ; Bit 1 on LCDCTRL: signal E:  0=disable 1=enable,
  ELSE
        LCDCTRL:  equ   PORTK   ; Port LCD control signals
        ENABLE:   equ   $02     ; Bit 1 on LCDCTRL: signal E:  0=disable 1=enable,
  ENDIF

LCD_LINE0: equ   $80    ; LCD command: set cursor to begin of line 0 (Command Set Display Data RAM Address)
LCD_LINE1: equ   $C0    ; LCD command: set cursor to begin of line 1 (Command Set Display Data RAM Address)

; ROM: Code section
.init:  SECTION

;**************************************************************
; Public interface function: initLCD ... Initialize LCD (called once)
; Parameter: -
; Return:    -
initLCD:  pshd
          pshx

          jsr  delay_10ms

          movb #$ff, DDRK ; initialize port K as output
          movb #$00, LCDCTRL; ... and set to 0
  IFDEF  SIMULATOR        ; when running in debugger, vs. when running on real hardware
          movb #$ff, DDRA ; initialize port A as output
          movb #$00, LCD  ;   ... and set to 0
  ENDIF
          ldx  #inidsp1   ; x points to initialization command sequence 1
          movb #1, reset_seq; need more delay for first reset seq.

          jsr  sel_inst   ; --- output command sequence 1 ----
          ldab 0,x        ; get number of commands
          inx             ; x points to first command
inext1:   ldaa 0,x        ; get command
          jsr  outputByte ; initiate write pulse.
          inx             ; x points to next command
          jsr  delay_5ms  ; delay 5ms
          decb
          bne  inext1     ; if not last command, go to get next command
                          ; --- end of command sequence 1 ---

          ldx  #inidsp2   ; x points to initialization command sequence 2
          clr  reset_seq

          jsr  sel_inst     ; --- output command sequence 2 ---
          ldab 0,x          ; get number of commands
          inx               ; x points to first command
inext2:   ldaa 0,x          ; get command
          jsr  outputByte   ; initiate write pulse.
          inx               ; x points to next command
          decb
          bne  inext2       ; if not last command, go to get next command
          jsr  delay_5ms    ; delay 5ms
                            ; --- end of command sequence 2 ---
          pulx
          puld
          rts

;**************************************************************
; Public interface function: writeLine ... Write zero-terminated string to LCD
; Parameter: X ... pointer to string
;            B ... row number (0 or 1)
; Return:    -
writeLine:
          pshd
          pshx

          pshb
          jsr  sel_inst   ; select instruction
          pulb
          cmpb #1
          beq writeLine1  ; first bug
writeLine0:
          ldaa #LCD_LINE0 ; set cursor to begin of line 0
          bra  wDo
writeLine1:
          ldaa #LCD_LINE1 ; set cursor to begin of line 1
wDo:      jsr  outputByte

          jsr  sel_data   ; select data

msg_out:                  ; output the message character by character
          ldab #16        ; max. 16 characters
next:     ldaa 0,x        ; get character
          decb
          cmpa #0         ; second bug (check for zero terminator)
          beq  fill_blank ; not more than 16 characters
          jsr  outputByte ; write character to LCD
          inx             ; continue with next character
          cmpb #0         ; third bug (check for 16 digits)
          beq  wEnd
          bra  next
fill_blank:
          ldaa #' '
          jsr outputByte
          cmpb #0         ; third bug (check for 16 digits)
          beq  wEnd
          decb
          bra  fill_blank
wEnd:     pulx
          puld
          rts

;**************************************************************
; Public interface function: delay_10ms
; Parameter: -
; Return:    -
 delay_10ms:
          pshx
          ldx  #TEN_MS
          bsr  del1
          pulx
          rts

;**************************************************************
; The rest are private functions

; Internal function: delay_5ms
; Parameter: -
; Return:    -
delay_5ms:
          pshx
          ldx  #FIVE_MS
          bsr  del1
          pulx
          rts

;**************************************************************
; Internal function: delay_50us
; Parameter: -
; Return:    -
delay_50us:
          pshx
          ldx  #FIFTY_US
          bsr  del1
          pulx
          rts

;**************************************************************
; Internal function: 250ns delay at 24MHz bus speed
; Parameter: X ... number of loops, i.e. multiples of 250ns
; Return:    -
del1:     dex                   ; 1 cycle
          inx                   ; 1 cycle
          dex                   ; 1 cycle
          bne   del1            ; 3 cylce
          rts

;**************************************************************
; Set R/S=1, i.e. prepare for outputting data
; Parameter: -
; Return:    -
sel_data: bset LCDCTRL, REG_SEL
          rts

;**************************************************************
; Set R/S=0, i.e. prepare for outputting commands
; Parameter: -
; Return:    -
sel_inst: bclr LCDCTRL, REG_SEL
          rts

;**************************************************************
; Output single byte, split into two nibbles, to LCD display
; Parameter: a ... byte (data or command) to send to display
; Return:    -
  IFDEF  SIMULATOR
outputByte:
          bset LCDCTRL, ENABLE  ; set E = 1, i.e. write data to LCD
          staa LCD
          bclr LCDCTRL, ENABLE  ; set E = 0 again
          jsr  delay_50us       ; delay 50us
          rts
  ELSE
outputByte:
          psha              ; save it temporarily

          anda #$f0         ; upper nibble --> A.5...2
          lsra
          lsra              ;

          bclr LCD, DATAMASK; output data to PORTK.5..2 without
          bset LCDCTRL, ENABLE  ; set E = 1, i.e. write data to LCD
          oraa LCD          ; changing other bits in PORTK
          staa LCD          ; write data to LCD
          bclr LCDCTRL, ENABLE  ; set E = 0 again
          jsr  delay_50us       ; delay 50us

          ldaa reset_seq
          beq  wrtpls
          jsr  delay_5ms    ; delay for reset sequence
;
wrtpls:   pula              ; get the temporarily saved value
          anda #$0F         ; lower nibble --> A.5...2
          lsla
          lsla

          bclr LCD, DATAMASK; output data to PORTK.5..2 without
          bset LCDCTRL, ENABLE  ; set E = 1, i.e. write data to LCD
          oraa LCD          ; changing other bits in PORTK
          staa LCD          ; write data to LCD
          bclr LCDCTRL, ENABLE  ; set E = 0 again
          jsr  delay_50us       ; delay 50us

          rts
  ENDIF
