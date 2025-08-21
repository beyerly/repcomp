;-------------------------------------------------------------------------
;  GRU-10 BIOS v0.127
;-------------------------------------------------------------------------

 .org $8000

;-------------------------------------------------------------------------
;  HW addresses
;-------------------------------------------------------------------------

PORTB = $6000    ; VIA PORTB
PORTA = $6001    ; VIA PORTA
PORTBDDR = $6002 ; VIA PORTB Data Direction
PORTADDR = $6003 ; VIA PORTA Data Direction
PORTAPCR = $600C ; VIA PORTA PCR register
PORTAIFR = $600D ; VIA PORTA IFR register
PORTAIER = $600E ; VIA PORTA IRR register
AUXCTRL = $600B  ; VIA Auxilary Control Register

ACIA_DATA = $4000
ACIA_STATUS = $4001
ACIA_CMD = $4002
ACIA_CTRL = $4003

;-------------------------------------------------------------------------
;  Variables
;-------------------------------------------------------------------------

;-------------------
;  Zero Page
;-------------------
zp_str_ptr = $00   ; 2B, Pointer to message string
zp_app_ptr = $02   ; 2B. Pointer to current page beign transferred. L always 0, H is active page.


cmd_input_str   = $10           ; 2B
cmd_str_idx     = $12           ; 2B
cmd_tmp_str     = $14           ; 2B

GRUOS_INPUT_STR = $0200         ; input string buffer, 256B, Shared with wozmon!

;-------------------
;  WozMon stuff
;-------------------

XAML = $24 ;            Last "opened" location Low
XAMH = $25 ;            Last "opened" location High
STL  = $26 ;            Store address Low
STH  = $27 ;            Store address High
L    = $28 ;            Hex value parsing Low
H    = $29 ;            Hex value parsing High
YSAV = $2A ;            Used to see if hex value is given
MODE = $2B ;            $00=XAM, $7F=STOR, $AE=BLOCK XAM

;-------------------------------------------------------------------------
;  Constants
;-------------------------------------------------------------------------

BS     = $08 ;             Backspace key, arrow left key. Using BS, Wozmon used DF
CR     = $0D ;             Carriage Return. Note WozMon used 8D.
LF     = $0A ;             Line Feed.
ESC    = $1B ;             ESC key, Wozmon used 9B
PROMPT = $5C ;             Prompt character '\'

;-------------------
;  Non-Zero Page
;-------------------

RAMBASE = $0200 ; Start of usable RAM, right above SP

;-------------------
;  WozMon stuff
;-------------------

IN         = $0200 ; Input buffer, up to $027F

;-------------------
;  Other
;-------------------

SLEEP_CNTR = $1004 ; 2B, Counter for Sleep subroutine.
ACIA_TDRE  = $1006  ; 1B, Copy of ACIA Transmit Ready register, for interrupt handler
APP_SIZE   = $1008  ; 2B. Size of application in B. LH first.
APP_CNT    = $100A   ; 2B. Counter tracking how many B if app we've transferred
DISPLAY_CTRL = $100C  ; 1B. Display control. b0 = echo on display.
DISPLAY_CHAR_HT = $100D  ; 1B. For text mode, character height in pixels. Used for CR.
DISPLAY_CHAR_WT = $100E  ; 1B. For text mode, character width in pixels. Used for CR.
FG_COLOR_R = $100F   ; 1B Foreground color, Red
FG_COLOR_G = $1010   ; 1B Foreground color, Green
FG_COLOR_B = $1011   ; 1B Foreground color, Blue
BG_COLOR_R = $1012   ; 1B Background color, Red
BG_COLOR_G = $1013   ; 1B Background color, Green
BG_COLOR_B = $1014   ; 1B Background color, Blue

USER_APP   = $2000   ; Start address for user programms

;-------------------------------------------------------------------------
;  RA8889 LCD display;
;-------------------------------------------------------------------------

RA8889_CMD = $4400
RA8889_DAT = $4401

RA8889_SSR = $00
RA8889_CCR = $01
RA8889_MACR = $02
RA8889_ICR = $03
RA8889_MRWDP = $04

; PLLs
RA8889_MPLLC1 = $07
RA8889_MPLLC2 = $08

; Clocks
RA8889_SPLLC1 = $09
RA8889_SPLLC2 = $0A
RA8889_PPLLC1 = $05
RA8889_PPLLC2 = $06

; Display SDRAM
RA8889_SDRAR = $E0
RA8889_SDRMD = $E1
RA8889_SDR_REF_ITVL0 = $E2
RA8889_SDR_REF_ITVL1 = $E3
RA8889_SDRCR = $E4

RA8889_DPCR = $12
RA8889_PCSR = $13
RA8889_HDWR = $14
RA8889_HDWFTR = $15
RA8889_VDHR0 = $1A
RA8889_VDHR1 = $1B

RA8889_MPWCTR = $10
RA8889_AW_COLOR = $5E

RA8889_HNDR = $16
RA8889_HNDFTR = $17
RA8889_HSTR = $18
RA8889_HPWR = $19

RA8889_VNDR0 = $1C
RA8889_VNDR1 = $1D
RA8889_VSTR = $1E
RA8889_VPWR = $1F

RA8889_MISA0 = $20
RA8889_MISA1 = $21
RA8889_MISA2 = $22
RA8889_MISA3 = $23

RA8889_MIW0 = $24
RA8889_MIW1 = $25

RA8889_MWULX0 = $26
RA8889_MWULX1 = $27
RA8889_MWULX2 = $28
RA8889_MWULX3 = $29

RA8889_CVS_IMWTH0 = $54
RA8889_CVS_IMWTH1 = $55

RA8889_AWUL_X0 = $56
RA8889_AWUL_X1 = $57
RA8889_AWUL_Y0 = $58
RA8889_AWUL_Y1 = $59

RA8889_AW_WTH0 = $5A
RA8889_AW_WTH1 = $5B
RA8889_AW_HT0 = $5C
RA8889_AW_HT1 = $5D

RA8889_F_CURX0 = $63
RA8889_F_CURX1 = $64
RA8889_F_CURY0 = $65
RA8889_F_CURY1 = $66

RA8889_FGCR = $D2
RA8889_FGCG = $D3
RA8889_FGCB = $D4
RA8889_BGCR = $D5
RA8889_BGCG = $D6
RA8889_BGCB = $D7

RA8889_DCR1 = $76
RA8889_GTCCR = $3C
RA8889_BTCR = $3D


RA8889_BTE_CTRL0 = $90
RA8889_BTE_CTRL1 = $91
RA8889_BTE_COLR = $92
RA8889_S0_STR0 = $93
RA8889_S0_STR1 = $94
RA8889_S0_STR2 = $95
RA8889_S0_STR3 = $96
RA8889_S0_WTH0 = $97
RA8889_S0_WTH1 = $98
RA8889_S0_X0 = $99
RA8889_S0_X1 = $9A
RA8889_S0_Y0 = $9B
RA8889_S0_Y1 = $9C
RA8889_BTE_WTH0 = $B1
RA8889_BTE_WTH1 = $B2
RA8889_BTE_HIG0 = $B3
RA8889_BTE_HIG1 = $B4

RA8889_DT_WTH0 = $AB
RA8889_DT_WTH1 = $AC
RA8889_DT_X0 = $AD
RA8889_DT_X1 = $AE
RA8889_DT_Y0 = $AF
RA8889_DT_Y1 = $B0


RA8889_SSR_DEFAULT = $02

;-------------------------------------------------------------------------
;  RA8889 Values for 1024x600 LCD display, see
;-------------------------------------------------------------------------

RA8889_1024x600_HDWR  = $7F
RA8889_1024x600_HDWFTR = $00
RA8889_1024x600_VDHR0 = $57
RA8889_1024x600_VDHR1 = $02
RA8889_1024x600_MIW0 = $00
RA8889_1024x600_MIW1 = $04
RA8889_1024x600_HNDR = $02
RA8889_1024x600_HNDFTR = $06
RA8889_1024x600_HSTR = $19
RA8889_1024x600_HPWR = $01
RA8889_1024x600_VNDR0 = $0C
RA8889_1024x600_VNDR1 = $00
RA8889_1024x600_VSTR = $15
RA8889_1024x600_VPWR = $09
RA8889_1024x600_CVS_IMWTH0 = $00
RA8889_1024x600_CVS_IMWTH1 = $04
RA8889_1024x600_AW_WTH0 = $00
RA8889_1024x600_AW_WTH1 = $04
RA8889_1024x600_AW_HT0 = $58
RA8889_1024x600_AW_HT1 = $02

DEFAULT_CHAR_HEIGHT = $15

SET_BIT_0 = $01
SET_BIT_1 = $02
SET_BIT_2 = $04
SET_BIT_3 = $08
SET_BIT_4 = $10
SET_BIT_5 = $20
SET_BIT_6 = $40
SET_BIT_7 = $80

CLEAR_BIT_0 = $FE
CLEAR_BIT_1 = $FD
CLEAR_BIT_2 = $FB
CLEAR_BIT_3 = $F7
CLEAR_BIT_4 = $EF
CLEAR_BIT_5 = $DF
CLEAR_BIT_6 = $BF
CLEAR_BIT_7 = $7F


;-------------------------------------------------------------------------
;  Reset Vector
;-------------------------------------------------------------------------


reset:
    cld                 ;  Clear decimal arithmetic mode
    cli                 ; clear interrupt disable
    ldx #$ff
    txs                 ; init SP
    lda #$ff
    sta PORTBDDR        ; VIA Port B all outputs
    lda #$00
    sta PORTADDR        ; VIA Port A all inputs
    lda #00
    sta AUXCTRL         ; VIA PORT A latching disabled
    lda #01
    sta PORTAPCR        ; VIA PORT A CA1 to pos edge input from keyboard controller
    lda #82
    sta PORTAIER        ; Enable VIA CA1 interrupt for keyboard
    jsr config_keyboard
    
    lda #$00
    sta ACIA_STATUS     ; Reset ACIA
    lda #$1f
    sta ACIA_CTRL       ; 1 stop bit, 8b, Baud rate 19200
    lda #$0b
    sta ACIA_CMD        ; Odd parity, parity disabled, reveiver normal, Tirq and Rirq disabled, DTR not ready

    lda #$01
    sta ACIA_TDRE       ; iniit ACIA transmit data register as empty

    jsr display_init    ; Initialize LCD display
    jsr display_set_text_mode
    jsr display_blinking_cursor_on
    jsr display_on
    jsr clear_screen
    lda #$00              ; Set BG color black
    sta BG_COLOR_R
    sta BG_COLOR_G
    sta BG_COLOR_B
    jsr display_set_bg_color
    lda #$FF              ; Set FG white
    sta FG_COLOR_R
    sta FG_COLOR_G
    sta FG_COLOR_B
    jsr display_set_fg_color
    
    lda #$01                         ; Enable display echo
    sta DISPLAY_CTRL
    lda #DEFAULT_CHAR_HEIGHT
    sta DISPLAY_CHAR_HT


; Fall through to start

;-------------------------------------------------------------------------
;  Kernel
;-------------------------------------------------------------------------

start:
    jsr led_pattern         ; Flash LED to shwo we're booting
    ; Show boot message on serial (and display)
    ldx #<startup_message ;
    stx zp_str_ptr
    ldx #>startup_message
    stx zp_str_ptr+1
    jsr snd_str             ; Send Startup message to serial
    jsr snd_cr              ; newline
    jmp kernel              ; start main kernel loop!

;-------------------------------------------------------------------------
;  Main kernel loop
;  Scan for serial input and keyboard input.
;-------------------------------------------------------------------------

kernel:
    ldx #<boot_message ;
    stx zp_str_ptr
    ldx #>boot_message
    stx zp_str_ptr+1
    jsr snd_str            ; Send boot message to serial
;    jsr snd_cr             ; newline
    jmp gruos_start

gruos_start:
    jsr snd_cr             ; newline
    lda #<GRUOS_INPUT_STR       ; set cmd input string pointer, and string index pointers
    sta cmd_input_str
    lda #>GRUOS_INPUT_STR
    sta cmd_input_str + 1
    ldy #$00                    ; Set character index to 0
    jsr gruos_snd_prompt        ; Show prompt
gruos_kernel_loop:
    jsr get_char                ; read input 
    jsr send_char               ; echo on display/serial
    cmp #CR                     ; Is CR?
    beq gruos_cmd_parse         ; Yes, parse command
    sta (cmd_input_str), Y      ; Store char in input buffer
    iny                         ; Next character
    jmp gruos_kernel_loop
gruos_cmd_parse:                ; I have cmd in input buffer!
    cpy #$00
    beq gruos_start
    lda #$00
    sta (cmd_input_str), Y      ; Zero-terminate input string
    ldx #$00                    ; Set cmd index to 0
    ldy #$00                    ; Set character index to 0
gruos_cmd_parse_loop:           ; Select command[X] to compare with
    lda gruos_cmd_table_lo, X ; Low byte of address of cmd[X] string
    sta cmd_tmp_str
    lda gruos_cmd_table_hi, X ; Hi byte of address of cmd[X] string
    sta cmd_tmp_str + 1         ; cmd_tmp_str points to character of cmd[X] string
gruos_cmd_parse_char_loop:      ; Parse cmd[X]
    lda (cmd_tmp_str), Y        ; Load character[Y] of cmd[X] string
    cmp #$00                    ; Zero termination?
    beq gruos_cmd_match         ; Yes, we found a cmd match! X contains cmd index.
    cmp (cmd_input_str), Y      ; No match yet, compare with input character
    bne gruos_nxt_cmd           ; No character match, check next command
    iny                         ; Character match! Check next character of command
    jmp gruos_cmd_parse_char_loop
gruos_nxt_cmd:
    inx                         ; check match with next cmd
    cpx #GRUOS_NUM_CMDS         ; Did we check all cmds?
    beq gruos_syntax_error      ; Yes, command is unknown, syntax error!
    jmp gruos_cmd_parse_loop    ; No, check next command
gruos_cmd_match:
; For now, no argumetns yet, directly do command index X!
; Note we directly tie a cmd index to a command, may have to make this a lookup...
    jsr snd_cr
    txa
    cmp #$00                ; idx 0?
    beq jump_wozmon         ; yes, start wozmon
    cmp #$01                ; idx 1?
    beq jump_load_app       ; yes, start wozmon
    cmp #$02                ; idx 2?
    beq jump_exe_app        ; yes, start wozmon
    cmp #$03                ; idx 2?
    beq jump_list_app        ; yes, start wozmon
    ldx #<gruos_kernel_err     ; Should never happen! Index should exist...
    stx zp_str_ptr
    ldx #>gruos_kernel_err
    stx zp_str_ptr+1
    jsr snd_str             ; Send string to serail and display
    jmp gruos_kernel_loop   ; Try again...

jump_wozmon:                ; Absolute jump because brach is out of range.
    jmp wozmon
jump_load_app:              ; Absolute jump because brach is out of range.
    jmp load_app
jump_list_app:              ; Absolute jump because brach is out of range.
    jmp list_app
jump_exe_app:               ; Absolute jump because brach is out of range.
    jmp exe_app


gruos_syntax_error:
    jsr snd_cr
    ldx #<gruos_syn_err ;
    stx zp_str_ptr
    ldx #>gruos_syn_err
    stx zp_str_ptr+1
    jsr snd_str                 ; Send string to serail and display
    jmp gruos_start             ; Start over.

gruos_snd_prompt:
    ldx #<gruos_prompt               ;
    stx zp_str_ptr
    ldx #>gruos_prompt
    stx zp_str_ptr+1
    jsr snd_str                 ; Send string to serail and display
    rts


config_keyboard:
    lda PORTAIFR           ;  Clear status if any, ignore
    lda PORTA              ; We have a char, read from VIA PORT A
    cmp #$FA
    bne no_keyboard
    rts

no_keyboard:
    ldx #<kbd_err_msg ;
    stx zp_str_ptr
    ldx #>kbd_err_msg
    stx zp_str_ptr+1
    jsr snd_str        ; Send Startup message to serial
    jsr snd_cr         ; newline
    rts


;-------------------------------------------------------------------------
;  Simple pattern on LEDs on VIA, just for debug.
;-------------------------------------------------------------------------

led_pattern:
    pha              ; save A
    txa              ; X - > A
    pha              ; save X
    tya              ; Y - > A
    pha              ; save Y
    ldx #$8          ; shift 8 times
    lda #$1          ; start with right bit
    clc              ;  clear carry
led_pattern_loop:
    jsr led_out      ; send pattern
    rol A            ; left shift bit
    ldy #$FF         ; delay FFF, lsb
    sty SLEEP_CNTR
    ldy #$0F         ; delay FFF, msb
    sty SLEEP_CNTR + 1
    jsr sleep
    dex              ; count down
    bne led_pattern_loop ; repeat until shifted 8 times
    pla              ; restore Y
    tay              ; A -> Y
    pla              ; restore X
    tax              ; A -> X
    pla              ; restore A
    rts

;-------------------------------------------------------------------------
;  Simple pattern on LEDs on VIA, just for debug.
;-------------------------------------------------------------------------

led_pattern1:
    pha              ; save A
    txa              ; X - > A
    pha              ; save X
    tya              ; Y - > A
    pha              ; save Y
    ldx #$03          ; flash 3 times
led_pattern1_loop:
    lda #$FF         ; All on
    jsr led_out      ; send pattern
    ldy #$FF         ; delay 2FFF, lsb
    sty SLEEP_CNTR
    ldy #$2F         ; delay 2FFF, msb
    sty SLEEP_CNTR + 1
    jsr sleep
    lda #$00         ; All on
    jsr led_out      ; send pattern
    ldy #$FF         ; delay 2FFF, lsb
    sty SLEEP_CNTR
    ldy #$2F         ; delay 2FFF, msb
    sty SLEEP_CNTR + 1
    jsr sleep
    dex              ; count down
    bne led_pattern1_loop ; repeat until done
    pla              ; restore Y
    tay              ; A -> Y
    pla              ; restore X
    tax              ; A -> X
    pla              ; restore A
    rts


snd_str:
    jsr snd_str_display
    jsr snd_str_acia
    rts

;-------------------------------------------------------------------------
;  Send CR to serial and display
;-------------------------------------------------------------------------

snd_cr:
    pha              ; save A
    txa              ; X - > A
    pha              ; save X
    tya              ; Y - > A
    pha              ; save Y
    jsr snd_cr_display
    jsr snd_cr_acia
    pla              ; restore Y
    tay              ; A -> Y
    pla              ; restore X
    tax              ; A -> X
    pla              ; restore A
    rts

snd_cr_acia:
    lda #LF                 ; Send linefeed
    jsr send_char_acia
    lda #CR                 ; Send carriage return
    jsr send_char_acia
    rts

;-------------------------------------------------------------------------
;  Send 0-terminated string to serial, pointer at by $zp_str_ptr
;-------------------------------------------------------------------------

snd_str_acia:
    pha              ; save A
    tya              ; Y - > A
    pha              ; save Y
    ldy #$0          ; address counter
snd_str_acia_loop:
    lda (zp_str_ptr), y    ; load character
    beq snd_str_acia_done  ; if 0, end of string, so done
    jsr send_char_acia     ; send current char in A to serial
    iny                    ; next charachter
    jmp snd_str_acia_loop
snd_str_acia_done:
    pla              ; restore Y
    tay              ; A -> Y
    pla              ; restore A
    rts

;-------------------------------------------------------------------------
;  Execute code at $USER_APP. Only singel page code snippets
;-------------------------------------------------------------------------


exe_app:
    ldx #<run_message ;
    stx zp_str_ptr
    ldx #>run_message
    stx zp_str_ptr+1
    jsr snd_str            ; Send Startup message to serial
    jsr snd_cr             ; newline
    jmp USER_APP ; execute!

;-------------------------------------------------------------------------
;  Send code at $USER_APP on serial. Only singel page code snippets
;  Destructive on A, X, Y but we always return to kernel loop.
;-------------------------------------------------------------------------

;; @@@ doesn;t scroll yet; needs to check end of line and send CD!!!

list_app:
    ldx APP_SIZE    ; Load app size in bytes, less than 255
    txa
    jsr led_out
    ldy #$00        ; address counter
list_loop:
    lda USER_APP, Y ; read byte
    jsr PRBYTE      ; send char in A to serial, using WozMon.
    iny             ; increment RAM addr
    dex             ; dec file size counter
    bne list_loop   ; repeat if not done
    jsr snd_cr      ; newline
    tya             ; app size to A
    jsr PRBYTE      ; send total app size on serial
    jsr snd_cr             ; newline
    jmp kernel             ; done

;-------------------------------------------------------------------------
;  Receive single page code snippet at $USER_APP on serial.
;  Note there's no flow control, so at 19200Baud there's ~521 cpu cycles
;  for each incoming cyte. Should be plenty?
;  Destructive on A, X, Y but we always return to kernel loop.
;-------------------------------------------------------------------------
load_app:
    ldx #<load_message;
    stx zp_str_ptr
    ldx #>load_message
    stx zp_str_ptr+1
    jsr snd_str            ; Send Startup message to serial
    jsr snd_cr             ; newline
;-------------------------------------------------------------------------
;  Set up file transfer
;-------------------------------------------------------------------------
    jsr get_acia_char    ; Read and ignore header 0xFF for now
    jsr get_acia_char    ; Read and ignore sub-command for now
    lda #<USER_APP       ; Load LB of app start address. Should be 0.
    sta zp_app_ptr       ; Set LB of app pointer to start address
    lda #>USER_APP       ; Load HB of app start address. This is page number
    sta zp_app_ptr + 1   ; Set LB of app pointer to page number
    jsr get_acia_char   ; Read serial. A contains LB of app size
    sta APP_SIZE         ; Save LB app size to memory. Permanent for future reference.
    sta APP_CNT          ; Also save LB to app byte counter, for tracking transfer.
    jsr get_acia_char   ; Read serial again, A contains HB of app size, number of pages
    sta APP_SIZE+1       ; Save HB app size to memory. Permanent for future reference.
    sta APP_CNT+1        ; Also save HB to app byte counter (number of pages), for tracking transfer.
    ldy #$00             ; Init Y as address counter within a page.
;-------------------------------------------------------------------------
;  Main tranfset loop
;-------------------------------------------------------------------------
transfer_loop:
    lda APP_CNT             ; Load LB of app byte counter
    ora APP_CNT+1           ; Or HB of app byte counter with LB
    beq load_app_done       ; If 0, HB and LB are 0, so we're done.
    jsr get_acia_char     ; Not done yet. Read serial
    sta (zp_app_ptr), Y     ; Store data at current index in page zp_app_ptr + 1
;  Decrement 16b app counter.
    sec                     ; Set carry bit. This creates a subtract without borrow.
    lda APP_CNT             ; Load LB of app byte counter
    sbc #$01                ; Subtract 1. If negative, carry but is reset, creating borrow.
    sta APP_CNT             ; Store LB of app counter back to memory
    lda APP_CNT+1           ; Load HB of app counter (page number)
    sbc #$00                ; Subtract with borrow. Subtracts 1 if Lb borrowed
    sta APP_CNT+1           ; Store HB of app counter back to memory
;  Continue
    iny                     ; increment addr pointer withing a page.
    bne transfer_loop       ; If not 0, stay in page, continue loop.
    inc zp_app_ptr + 1      ; Y wrapped to 0, move to next page.
    jmp transfer_loop       ; Start at index 0 on next page.
load_app_done:              ; We are doen with transfer.
  ldx #<file_loaded_message ; set string pointer to message address
  stx zp_str_ptr
  ldx #>file_loaded_message
  stx zp_str_ptr+1
  jsr snd_str            ; Send message to serial
  lda APP_SIZE
  jsr PRBYTE             ; show file size on com
  lda APP_SIZE + 1
  jsr snd_cr             ; new line
  jmp gruos_start   ; done

;-------------------------------------------------------------------------
;  Read input from keyboard or serial in A. This is blocking.
;-------------------------------------------------------------------------

get_char:
    lda ACIA_STATUS        ; Check status
    and #$08               ; Receive ready set?
    bne load_acia_char     ; Yes! Read from ACIA
    lda PORTAIFR           ; Check VIA status for CA1 interrupt (polling)
    and #$02               ; Receive ready set?
    bne load_kb_char       ; Yes! Read from keyboard
    jmp get_char           ; Neither, check again (blocking!!)
load_acia_char:
    lda ACIA_DATA          ; We have a char, read from ACIA
    rts
load_kb_char:
    lda PORTA              ; We have a char, read from VIA PORT A
    rts

get_acia_char:
    lda ACIA_STATUS        ; Check status
    and #$08               ; Receive ready set?
    beq get_acia_char      ; No? check again.
    lda ACIA_DATA          ; We have a char, read from ACIA
    rts



;-------------------------------------------------------------------------
; Send byte in A to display and serial.
; Note serial is slow, so perhaps keep serial enable bit and skip if not needed
;-------------------------------------------------------------------------

send_char:
    jsr send_char_display
    jsr send_char_acia
    rts

;-------------------------------------------------------------------------
;  Send byte in A to serial. No interrupts yet, so work-around for ACIA
;  bug by sleepign until we are sure character is sent.t
;  At 19200 baud, this is 512 uS, so at least 512 cycles! We wait 3x255 cycles
;  to be sure....
;-------------------------------------------------------------------------

send_char_acia:
    sta ACIA_DATA    ; send char
    pha              ; save A
    tya              ; Y - > A
    pha              ; save Y
    ldy #$FF         ; delay 3FF cycles lsb
    sty SLEEP_CNTR
    ldy #$03         ; delay 3FF cycles msb
    sty SLEEP_CNTR + 1
    jsr sleep
    pla              ; restore Y
    tay              ; A -> Y
    pla              ; restore A
    rts

;-------------------------------------------------------------------------
; Send byte in A to display. Assuming display is in text mode.
; RA8889 will wrap arournd lines, but no scroll implemented yet.
;-------------------------------------------------------------------------

send_char_display:
    pha                ; save character to send
    ; if cr, send CR!!
    cmp     #CR
    beq send_char_display_snd_cr          ; It's  CR!
    ; if lf, send CR!!
    cmp     #LF
    beq send_char_display_snd_cr          ; It's  LF!
send_char_display_not_cr:
    lda DISPLAY_CTRL
    and #$01
    beq send_char_display_done
    lda #RA8889_MRWDP  ; Select RA8889 memory write port
    sta RA8889_CMD     ; Set RA8889 register to MRWDP
    pla                ; restore char
    sta RA8889_DAT     ; send char
    rts
send_char_display_snd_cr:
;    jsr snd_cr_display
send_char_display_done:
    pla
    rts

 ; interrupt mode, tbd
 ; tx irq check, disable for now
 ;pha
 ;lda ACIA_TDRE ; check if tx reg is empty, this will be reset by IRQ
 ;beq send_char_acia ; not empty, loop
 ;pla
; lda #$00 ;
; sta ACIA_TDRE ; set TDRE to full, will be cleared by IRQ


;-------------------------------------------------------------------------
;  Long Sleep $SLEEP_CNTR cycles, 16b counter
;  Count down from $#HHLL. Must be more than FF!
;  SLEEP_CNT      <- LL
;  SLEEP_CNTR + 1 <- HH
;
;-------------------------------------------------------------------------

sleep:
    pha                 ; save A
    txa                 ; X - > A
    pha                 ; save X
sleep_loop:
    dec SLEEP_CNTR      ; Decrement LB
    bne sleep_loop      ; Repeat if not 0
    lda SLEEP_CNTR + 1  ; LH is 0, load HB
    beq sleep_done      ; If 0, we're done
    dec SLEEP_CNTR + 1  ; Not 0, decrement HB
    lda #$FF            ; Reload LB for full page
    sta SLEEP_CNTR
    jmp sleep_loop      ; Repeat
sleep_done:
    pla                 ; restore Y
    tay                 ; A -> Y
    pla                 ; restore X
    rts

;-------------------------------------------------------------------------
;  Output A on 8b led strip
;-------------------------------------------------------------------------

led_out:
    sta PORTB
    rts

;-------------------------------------------------------------------------
; WozMon
; Modified from https://www.sbprojects.net/projects/apple1/wozmon.php
;-------------------------------------------------------------------------

wozmon:
                ldx     #<wozmon_message ;
                stx     zp_str_ptr
                ldx     #>wozmon_message
                stx     zp_str_ptr+1
                jsr     snd_str         ; Send Startup message to serial
                jsr     snd_cr          ; newline
                jsr     led_pattern1    ;
                ldy #   $7F             ; Original WozMon expects Y still holds $7F, which will cause an automatic Escape

;-------------------------------------------------------------------------
; The GETLINE process
;-------------------------------------------------------------------------

NOTCR:
                cmp     #BS            ; backspace key?
                beq     BACKSPACE      ; yes
                cmp     #ESC           ; esc?
                beq     ESCAPE         ; yes
                iny                    ; advance text index
                bpl     NEXTCHAR       ; auto esc if line longer than 127

ESCAPE:
                lda     #PROMPT        ; Print prompt character
                jsr     send_char      ; Output it.

GETLINE:        
                jsr     snd_cr         ; Send CR

                ldy     #0+1           ; Start a new input line
BACKSPACE:
                dey                    ; Backup text index
                bmi     GETLINE        ; Oops, line's empty, reinitialize

NEXTCHAR:
                jsr     get_char  ; Wait for key press, note WozMon expects B7=1, and we don;t have that
                jsr     led_out
                sta     IN,Y           ; Add to text buffer
                jsr     send_char      ; Display character
                cmp     #CR
                bne     NOTCR          ; It's not CR!

; Line received, now let's parse it

                ldy     #-1            ; Reset text index
                lda     #0             ; Default mode is XAM
                tax                    ; X=0

SETSTOR:
                asl                    ; Leaves $7B if setting STOR mode

SETMODE:
                sta     MODE           ; Set mode flags

BLSKIP:
                iny                    ; Advance text index

NEXTITEM:
                lda     IN,Y           ; Get character
                cmp     #CR
                beq     GETLINE        ; We're done if it's CR!
                cmp     #"."
                bcc     BLSKIP         ; Ignore everything below "."!
                beq     SETMODE        ; Set BLOCK XAM mode ("." = $AE)
                cmp     #":"
                beq     SETSTOR        ; Set STOR mode! $BA will become $7B
                cmp     #"R"
                beq     RUN            ; Run the program! Forget the rest
                stx     L              ; Clear input value (X=0)
                stx     H
                sty     YSAV           ; Save Y for comparison

; Here we're trying to parse a new hex value

NEXTHEX:
                lda     IN,Y           ; Get character for hex test
                eor     #$30           ; Map digits to 0-9. Wozmon had B0, but we don't get B7=1
                cmp     #9+1           ; Is it a decimal digit?
                bcc     DIG            ; Yes!
                adc     #$88           ; Map letter "A"-"F" to $FA-FF.
                cmp     #$FA           ; Hex letter?
                bcc     NOTHEX         ; No! Character not hex

DIG:
                asl
                asl                    ; Hex digit to MSD of A
                asl
                asl

                ldx     #4             ; Shift count
HEXSHIFT:
                asl                    ; Hex digit left, MSB to carry
                rol     L              ; Rotate into LSD
                rol     H              ; Rotate into MSD's
                dex                    ; Done 4 shifts?
                bne     HEXSHIFT       ; No, loop
                iny                    ; Advance text index
                bne     NEXTHEX        ; Always taken

NOTHEX:
                cpy     YSAV           ; Was at least 1 hex digit given?
                beq     ESCAPE         ; No! Ignore all, start from scratch

                bit     MODE           ; Test MODE byte
                bvc     NOTSTOR        ; B6=0 is STOR, 1 is XAM or BLOCK XAM

; STOR mode, save LSD of new hex byte

                lda     L              ; LSD's of hex data
                sta     (STL,X)        ; Store current 'store index'(X=0)
                inc     STL            ; Increment store index.
                bne     NEXTITEM       ; No carry!
                inc     STH            ; Add carry to 'store index' high
TONEXTITEM:
                jmp     NEXTITEM       ; Get next command item.

;-------------------------------------------------------------------------
;  RUN user's program from last opened location
;-------------------------------------------------------------------------

RUN:
                jmp     (XAML)         ; Run user's program

;-------------------------------------------------------------------------
;  We're not in Store mode
;-------------------------------------------------------------------------

NOTSTOR:
                bmi     XAMNEXT        ; B7 = 0 for XAM, 1 for BLOCK XAM

; We're in XAM mode now

                ldx     #2             ; Copy 2 bytes
SETADR:
                lda     L-1,X          ; Copy hex data to
                sta     STL-1,X        ;  'store index'
                sta     XAML-1,X       ;  and to 'XAM index'
                dex                    ; Next of 2 bytes
                bne     SETADR         ; Loop unless X = 0

; Print address and data from this address, fall through next BNE.

NXTPRNT:
                bne     PRDATA         ; NE means no address to print
                jsr     snd_cr         ; Send CR
                lda     XAMH           ; Output high-order byte of address
                jsr     PRBYTE
                lda     XAML           ; Output low-order byte of address
                jsr     PRBYTE
                lda     #":"           ; Print colon
                jsr     send_char

PRDATA:
		lda     #" "           ; Print space
                jsr     send_char
                lda     (XAML,X)       ; Get data from address (X=0)
		jsr     led_out
                jsr     PRBYTE         ; Output it in hex format
XAMNEXT:
                stx     MODE           ; 0 -> MODE (XAM mode).
                lda     XAML           ; See if there's more to print
                cmp     L
                lda     XAMH
                sbc     H
                bcs     TONEXTITEM     ; Not less! No more data to output

                inc     XAML           ; Increment 'examine index'
                bne     MOD8CHK        ; No carry!
                inc     XAMH

MOD8CHK:
                lda     XAML           ; If address MOD 8 = 0 start new line
                and     #$07           ; Wozmon had #%0000.0111
                bpl     NXTPRNT        ; Always taken.

;-------------------------------------------------------------------------
;  Subroutine to print a byte in A in hex form (destructive)
;-------------------------------------------------------------------------

PRBYTE:
                pha ; Save A for LSD
                lsr
                lsr
                lsr
                lsr
                jsr      PRHEX          ; Output hex digit
                pla                     ; Restore A

; Fall through to print hex routine

;-------------------------------------------------------------------------
;  Subroutine to print a hexadecimal digit
;-------------------------------------------------------------------------

PRHEX:
                and     #$0f            ; Mask LSD for hex print
                ora     #"0"            ; Add "0"
                cmp     #"9"+1          ; Is it a decimal digit?
                bcc     PRHEX_ECHO      ; Yes! output it
                adc     #6              ; Add offset for letter A-F
PRHEX_ECHO:
                jsr send_char
                rts

;-------------------------------------------------------------------------
;  RA8889 LCD display;
;-------------------------------------------------------------------------


;-------------------------------------------------------------------------
;  Display not connected, message on serial and start WozMon
;-------------------------------------------------------------------------

no_display:
    ldx #<dsp_err_msg ;
    stx zp_str_ptr
    ldx #>dsp_err_msg
    stx zp_str_ptr+1
    jsr snd_str_acia        ; Send Startup message to serial
    jsr snd_cr_acia         ; newline

    jmp wozmon

;-------------------------------------------------------------------------
;  RA8889 LCD display controller initialization
;-------------------------------------------------------------------------

display_init:
    lda #RA8889_SSR
    sta RA8889_CMD          ; set SSR
    lda RA8889_DAT          ; read SSR
    cmp #RA8889_SSR_DEFAULT
    bne no_display          ; no display found

    lda RA8889_DAT          ; read SSR
    ora #SET_BIT_0
    sta RA8889_DAT          ; SW reset

;  PLLs Dram clock
    lda #RA8889_MPLLC1
    sta RA8889_CMD
    lda #$02 ; div by 2
    sta RA8889_DAT
    lda #RA8889_MPLLC2
    sta RA8889_CMD
    lda #$19 ;
    sta RA8889_DAT

; PLLs Core clock
    lda #RA8889_SPLLC1
    sta RA8889_CMD
    lda #$04 ; div by 4
    sta RA8889_DAT
    lda #RA8889_SPLLC2
    sta RA8889_CMD
    lda #$2F ;
    sta RA8889_DAT

; PLLs Pixel clock
    lda #RA8889_PPLLC1
    sta RA8889_CMD
    lda #$06 ; div by 8
    sta RA8889_DAT
    lda #RA8889_PPLLC2
    sta RA8889_CMD
    lda #$27 ;
    sta RA8889_DAT

; Enable PLLs
    lda #RA8889_CCR
    sta RA8889_CMD
    lda #SET_BIT_7 ; reconfig pll
    sta RA8889_DAT
display_check_plls:
    lda RA8889_DAT ; check CCR
    and #SET_BIT_7
    beq display_check_plls ; bit7 not set yet, wait until PLL reconfig is done

; Set display SDRAM
    lda #RA8889_SDRAR
    sta RA8889_CMD
    lda #$29 ;
    sta RA8889_DAT
    lda #RA8889_SDRMD
    sta RA8889_CMD
    lda #$03 ; cas latency
    sta RA8889_DAT
    lda #RA8889_SDR_REF_ITVL0
    sta RA8889_CMD
    lda #$1D ;
    sta RA8889_DAT
    lda #RA8889_SDR_REF_ITVL1
    sta RA8889_CMD
    lda #$08 ;
    sta RA8889_DAT

; Init srdam
    lda #RA8889_SDRCR
    sta RA8889_CMD
    lda RA8889_DAT
    ora #SET_BIT_0 ; sdr_initdone
    sta RA8889_DAT
display_check_sdram:
    lda RA8889_CMD ; check STSR
    and #SET_BIT_2
    beq display_check_sdram ; bit2 not set yet, wait until SDRAM is ready for access

; Set Color Output
    lda #RA8889_CCR
    sta RA8889_CMD
    lda #$00 ; tft 24bit
    sta RA8889_DAT

; Main window
    lda #RA8889_MPWCTR
    sta RA8889_CMD
    lda #$04 ; 16b Main Image Color Depth Setting (conflicts with tft 24bit?)
    sta RA8889_DAT

    lda #RA8889_AW_COLOR
    sta RA8889_CMD
    lda #$01 ; 16b Canvas image’s color depth & memory R/W data widt (conflicts with tft 24bit?)
    sta RA8889_DAT

    lda #RA8889_DPCR
    sta RA8889_CMD
    lda RA8889_DAT
    ora #SET_BIT_7 ; Panel fetches XPDAT at PCLK falling edge.
    sta RA8889_DAT


; LCD_HorizontalWidth_VerticalHeight
    lda #RA8889_HDWR
    sta RA8889_CMD
    lda #RA8889_1024x600_HDWR
    sta RA8889_DAT

    lda #RA8889_HDWFTR
    sta RA8889_CMD
    lda #RA8889_1024x600_HDWFTR
    sta RA8889_DAT

    lda #RA8889_VDHR0
    sta RA8889_CMD
    lda #RA8889_1024x600_VDHR0
    sta RA8889_DAT

    lda #RA8889_VDHR1
    sta RA8889_CMD
    lda #RA8889_1024x600_VDHR1
    sta RA8889_DAT

; LCD_Horizontal_Non_Display
    lda #RA8889_HNDR
    sta RA8889_CMD
    lda #RA8889_1024x600_HNDR
    sta RA8889_DAT

    lda #RA8889_HNDFTR
    sta RA8889_CMD
    lda #RA8889_1024x600_HNDFTR
    sta RA8889_DAT

; LCD_HSYNC_Start_Position
    lda #RA8889_HSTR
    sta RA8889_CMD
    lda #RA8889_1024x600_HSTR
    sta RA8889_DAT

; LCD_HSYNC_Pulse_Width
    lda #RA8889_HPWR
    sta RA8889_CMD
    lda #RA8889_1024x600_HPWR
    sta RA8889_DAT

; LCD_Vertical_Non_Display
    lda #RA8889_VNDR0
    sta RA8889_CMD
    lda #RA8889_1024x600_VNDR0
    sta RA8889_DAT

    lda #RA8889_VNDR1
    sta RA8889_CMD
    lda #RA8889_1024x600_VNDR1
    sta RA8889_DAT

; LCD_VSYNC_Start_Position
    lda #RA8889_VSTR
    sta RA8889_CMD
    lda #RA8889_1024x600_VSTR
    sta RA8889_DAT

; LCD_VSYNC_Pulse_Width
    lda #RA8889_VPWR
    sta RA8889_CMD
    lda #RA8889_1024x600_VPWR
    sta RA8889_DAT

; Main_Image_Width
    lda #RA8889_MIW0
    sta RA8889_CMD
    lda #RA8889_1024x600_MIW0
    sta RA8889_DAT

    lda #RA8889_MIW1
    sta RA8889_CMD
    lda #RA8889_1024x600_MIW1
    sta RA8889_DAT

; Canvas_image_width
    lda #RA8889_CVS_IMWTH0
    sta RA8889_CMD
    lda #RA8889_1024x600_CVS_IMWTH0
    sta RA8889_DAT

    lda #RA8889_CVS_IMWTH1
    sta RA8889_CMD
    lda #RA8889_1024x600_CVS_IMWTH1
    sta RA8889_DAT

; Active_Window_WH
    lda #RA8889_AW_WTH0
    sta RA8889_CMD
    lda #RA8889_1024x600_AW_WTH0
    sta RA8889_DAT

    lda #RA8889_AW_WTH1
    sta RA8889_CMD
    lda #RA8889_1024x600_AW_WTH1
    sta RA8889_DAT

    lda #RA8889_AW_HT0
    sta RA8889_CMD
    lda #RA8889_1024x600_AW_HT0
    sta RA8889_DAT

    lda #RA8889_AW_HT1
    sta RA8889_CMD
    lda #RA8889_1024x600_AW_HT1
    sta RA8889_DAT


    lda #RA8889_F_CURX0     ; Select X cursor LB
    sta RA8889_CMD
    lda #$00                ; Set to 0, beginning of line
    sta RA8889_DAT
    lda #RA8889_F_CURX1     ; Select X cursor LB
    sta RA8889_CMD
    lda #$00                ; Set to 0, beginning of line
    sta RA8889_DAT
    lda #RA8889_F_CURY0     ; Select X cursor LB
    sta RA8889_CMD
    lda #$00                ; Set to 0, beginning of line
    sta RA8889_DAT
    lda #RA8889_F_CURY1     ; Select X cursor LB
    sta RA8889_CMD
    lda #$00                ; Set to 0, beginning of line
    sta RA8889_DAT


; BTE color 
    lda #RA8889_BTE_COLR      
    sta RA8889_CMD
    lda #$25                ; 16b for Destination, source 0 and 1
    sta RA8889_DAT

    rts


;-------------------------------------------------------------------------
;  Turn on text cursor and set blinking
;-------------------------------------------------------------------------

display_blinking_cursor_on:
    lda #RA8889_GTCCR
    sta RA8889_CMD
    lda RA8889_DAT
    ora #SET_BIT_0 ; Text curson blinking
    ora #SET_BIT_1 ; Text cursor on
    sta RA8889_DAT
    lda #RA8889_BTCR
    sta RA8889_CMD
    lda #$16           ; Blinking speed 25 frames
    sta RA8889_DAT
    rts

;-------------------------------------------------------------------------
;  Set text mode
;-------------------------------------------------------------------------

display_set_text_mode:
    lda #RA8889_ICR
    sta RA8889_CMD
    lda RA8889_DAT
    ora #SET_BIT_2 ; text mode
    sta RA8889_DAT
    rts

;-------------------------------------------------------------------------
;  Set graphics mode
;-------------------------------------------------------------------------

display_set_graphics_mode:
    lda #RA8889_ICR
    sta RA8889_CMD
    lda RA8889_DAT
    and #CLEAR_BIT_2 ; graphics mode
    sta RA8889_DAT
    rts

;-------------------------------------------------------------------------
;  Turn display on
;-------------------------------------------------------------------------

display_on:
    lda #RA8889_DPCR
    sta RA8889_CMD
    lda RA8889_DAT
    ora #SET_BIT_6 ; display on
    sta RA8889_DAT
    rts

;-------------------------------------------------------------------------
;  Turn display off
;-------------------------------------------------------------------------

display_off:
    lda #RA8889_DPCR
    sta RA8889_CMD
    lda RA8889_DAT
    and #CLEAR_BIT_6 ; display off
    sta RA8889_DAT
    rts

;-------------------------------------------------------------------------
;  Send 0-terminated string to display, pointer at by $zp_str_ptr
;-------------------------------------------------------------------------

snd_str_display:
    pha              ; save A
    tya              ; Y - > A
    pha              ; save Y
    lda #RA8889_MRWDP
    sta RA8889_CMD   ; Set RA8889 register to MRWDP
    ldy #$0          ; address counter
snd_str_display_loop:
    lda (zp_str_ptr), y    ; load character
    beq snd_str_display_done  ; if 0, end of string, so done
    sta RA8889_DAT         ; send char
    iny                    ; next charachter
    jmp snd_str_display_loop
snd_str_display_done:
    pla              ; restore Y
    tay              ; A -> Y
    pla              ; restore A
    rts

;-------------------------------------------------------------------------
; Clear 1024x600 LCD display. Implemented as a BTE solid fill using black.
; Assumes we are in text mode with a basic black background
;-------------------------------------------------------------------------

clear_screen:
    lda #RA8889_BTE_CTRL1       ; Select Block Transfer Register
    sta RA8889_CMD
    lda #$0C                    ; Set function to Solid fill
    sta RA8889_DAT

; Set WidthxHeight of solid fill to full 1024x600 LCD screen size.

    lda #RA8889_BTE_WTH0        ; Select BT width reg, LB
    sta RA8889_CMD
    lda #$00                    ; Set to 1024 LCD width, LB
    sta RA8889_DAT
    lda #RA8889_BTE_WTH1        ; Select BT width reg, HB
    sta RA8889_CMD
    lda #$04                    ; Set to 1024 LCD width, HB
    sta RA8889_DAT

    lda #RA8889_BTE_HIG0        ; Select BT height reg, LB
    sta RA8889_CMD
    lda #$58                    ; Set to 600 LCD height, LB
    sta RA8889_DAT
    lda #RA8889_BTE_HIG1        ; Select BT height reg, HB
    sta RA8889_CMD
    lda #$02                    ; Set to 600 LCD height, HB
    sta RA8889_DAT

; Coordinates top-left of screen

    lda #RA8889_DT_X0      
    sta RA8889_CMD
    lda #$00               
    sta RA8889_DAT
    lda #RA8889_DT_X1      
    sta RA8889_CMD
    lda #$00               
    sta RA8889_DAT

    lda #RA8889_DT_Y0      
    sta RA8889_CMD
    lda #$00             
    sta RA8889_DAT
    lda #RA8889_DT_Y1      
    sta RA8889_CMD
    lda #$00               
    sta RA8889_DAT


; Set destination image width to 1024 LCD width

    lda #RA8889_DT_WTH0         ; Select BT height reg, LB
    sta RA8889_CMD
    lda #$00                  ;
    sta RA8889_DAT
    lda #RA8889_DT_WTH1
    sta RA8889_CMD
    lda #$04                  ;
    sta RA8889_DAT

    lda FG_COLOR_R
    pha
    lda FG_COLOR_G
    pha
    lda FG_COLOR_B
    pha
    lda BG_COLOR_R
    sta FG_COLOR_R
    lda BG_COLOR_G
    sta FG_COLOR_G
    lda BG_COLOR_B
    sta FG_COLOR_B
    jsr display_set_fg_color  ; Clear screen by filling with black color

    lda #RA8889_BTE_CTRL0           ; Select BT Control register
    sta RA8889_CMD
    lda RA8889_DAT                  ; Read it
    ora #SET_BIT_4                  ; Set bit4: start BTE function
    sta RA8889_DAT

    lda #RA8889_BTE_CTRL0           ; Technically not required...
    sta RA8889_CMD
clear_screen_loop:
    lda RA8889_DAT                  ; Read BT Control
    and #SET_BIT_4                  ; Check if still busy with function
    bne clear_screen_loop           ; Still busy....

; set back original FG color

    pla
    sta FG_COLOR_B
    pla
    sta FG_COLOR_G
    pla
    sta FG_COLOR_R
    jsr display_set_fg_color  ; Clear screen by filling with black color

    rts                             ; Screen cleared!

;-------------------------------------------------------------------------
; Set LCD display foreground and background colors 
; PAssing RGB arguments through FG/GG_COLOR parameters
;-------------------------------------------------------------------------


display_set_fg_color:
    lda #RA8889_FGCR    ; Select foreground red
    sta RA8889_CMD
    lda FG_COLOR_R
    sta RA8889_DAT
    lda #RA8889_FGCG    ; Select foreground green
    sta RA8889_CMD
    lda FG_COLOR_G
    sta RA8889_DAT
    lda #RA8889_FGCB    ; Select foreground blue
    sta RA8889_CMD
    lda FG_COLOR_B
    sta RA8889_DAT
    rts



display_set_bg_color:
    lda #RA8889_BGCR    ; Select foreground red
    sta RA8889_CMD
    lda BG_COLOR_R
    sta RA8889_DAT
    lda #RA8889_BGCG    ; Select foreground green
    sta RA8889_CMD
    lda BG_COLOR_G
    sta RA8889_DAT
    lda #RA8889_BGCB    ; Select foreground blue
    sta RA8889_CMD
    lda BG_COLOR_B
    sta RA8889_DAT
    rts

;-------------------------------------------------------------------------
; Display scroll in text mode
;-------------------------------------------------------------------------


display_scroll:
    lda #RA8889_BTE_CTRL1       ; Select Block Transfer Register
    sta RA8889_CMD
    lda #$C2                    ; Set function to mem copy with ROP, ROP = S0
    sta RA8889_DAT

; Set WidthxHeight of solid fill to full 1024x600 LCD screen size.

    lda #RA8889_BTE_WTH0        ; Select BT width reg, LB
    sta RA8889_CMD
    lda #$00                   ; Set to 1024 LCD width, LB
    sta RA8889_DAT
    lda #RA8889_BTE_WTH1        ; Select BT width reg, HB
    sta RA8889_CMD
    lda #$04                    ; Set to 1024 LCD width, HB
    sta RA8889_DAT

    lda #RA8889_BTE_HIG0        ; Select BT height reg, LB
    sta RA8889_CMD
    lda #$42                    ; Set to 600 LCD height, LB
    sta RA8889_DAT
    lda #RA8889_BTE_HIG1        ; Select BT height reg, HB
    sta RA8889_CMD
    lda #$02                    ; Set to 600 LCD height, HB
    sta RA8889_DAT

; Set destination image width to 1024 LCD width

    lda #RA8889_DT_WTH0         ; Select BT height reg, LB
    sta RA8889_CMD
    lda #$00                  ;
    sta RA8889_DAT
    lda #RA8889_DT_WTH1
    sta RA8889_CMD
    lda #$04                  ;
    sta RA8889_DAT


; Dest X, Y top of screen

    lda #RA8889_DT_X0      
    sta RA8889_CMD
    lda #$00               
    sta RA8889_DAT
    lda #RA8889_DT_X1      
    sta RA8889_CMD
    lda #$00               
    sta RA8889_DAT

    lda #RA8889_DT_Y0      
    sta RA8889_CMD
    lda #$00             
    sta RA8889_DAT
    lda #RA8889_DT_Y1      
    sta RA8889_CMD
    lda #$00               
    sta RA8889_DAT


; Source 0 X and Y. Find the top of the second text line.

    lda #RA8889_S0_X0        
    sta RA8889_CMD
    lda #$00                 
    sta RA8889_DAT
    lda #RA8889_S0_X1        
    sta RA8889_CMD
    lda #$00                 
    sta RA8889_DAT

    lda #RA8889_S0_Y0        
    sta RA8889_CMD
    lda #$15                 
    sta RA8889_DAT
    lda #RA8889_S0_Y1        
    sta RA8889_CMD
    lda #$00                 
    sta RA8889_DAT

; Set source image width to 1024 LCD width

    lda #RA8889_S0_WTH0         ; Select BT height reg, LB
    sta RA8889_CMD
    lda #$00                  ;
    sta RA8889_DAT
    lda #RA8889_S0_WTH1
    sta RA8889_CMD
    lda #$04                  ;
    sta RA8889_DAT


    lda #RA8889_BTE_CTRL0           ; Select BT Control register
    sta RA8889_CMD
    lda RA8889_DAT                  ; Read it
    ora #SET_BIT_4                  ; Set bit4: start BTE function
    sta RA8889_DAT

    lda #RA8889_BTE_CTRL0           ; Technically not required...
    sta RA8889_CMD
dsp_scroll_loop:
    lda RA8889_DAT                  ; Read BT Control
    and #SET_BIT_4                  ; Check if still busy with function
    bne dsp_scroll_loop             ; Still busy....


; clear last line with BG color

    lda #RA8889_BTE_CTRL1       ; Select Block Transfer Register
    sta RA8889_CMD
    lda #$0C                    ; Set function to Solid fill
    sta RA8889_DAT

; Set WidthxHeight of solid fill to full 1024 LCD screen size, and hight of 1 text line

    lda #RA8889_BTE_WTH0        ; Select BT width reg, LB
    sta RA8889_CMD
    lda #$00                    ; Set to 1024 LCD width, LB
    sta RA8889_DAT
    lda #RA8889_BTE_WTH1        ; Select BT width reg, HB
    sta RA8889_CMD
    lda #$04                    ; Set to 1024 LCD width, HB
    sta RA8889_DAT

    lda #RA8889_BTE_HIG0        ; Select BT height reg, LB
    sta RA8889_CMD
    lda #$1B                    ; use text high tvariable!!!!
    sta RA8889_DAT
    lda #RA8889_BTE_HIG1        ; Select BT height reg, HB
    sta RA8889_CMD
    lda #$00                    ; Set to 600 LCD height, HB
    sta RA8889_DAT

; Destination X, Y, target top of last tect line

    lda #RA8889_DT_X0      
    sta RA8889_CMD
    lda #$00               
    sta RA8889_DAT
    lda #RA8889_DT_X1      
    sta RA8889_CMD
    lda #$00               
    sta RA8889_DAT

    lda #RA8889_DT_Y0      
    sta RA8889_CMD
    lda #$36             
    sta RA8889_DAT
    lda #RA8889_DT_Y1      
    sta RA8889_CMD
    lda #$02               
    sta RA8889_DAT


    ; Fill with  BG color, first save FG color for later.
    lda FG_COLOR_R
    pha
    lda FG_COLOR_G
    pha
    lda FG_COLOR_B
    pha
    lda BG_COLOR_R
    sta FG_COLOR_R
    lda BG_COLOR_G
    sta FG_COLOR_G
    lda BG_COLOR_B
    sta FG_COLOR_B
    jsr display_set_fg_color  ; 


; Set destination image width to 1024 LCD width

    lda #RA8889_DT_WTH0         ; Select BT height reg, LB
    sta RA8889_CMD
    lda #$00                  ;
    sta RA8889_DAT
    lda #RA8889_DT_WTH1
    sta RA8889_CMD
    lda #$04                  ;
    sta RA8889_DAT


    lda #RA8889_BTE_CTRL0           ; Select BT Control register
    sta RA8889_CMD
    lda RA8889_DAT                  ; Read it
    ora #SET_BIT_4                  ; Set bit4: start BTE function
    sta RA8889_DAT

    lda #RA8889_BTE_CTRL0           ; Technically not required...
    sta RA8889_CMD
dsp_scroll_clear_line_loop:
    lda RA8889_DAT                  ; Read BT Control
    and #SET_BIT_4                  ; Check if still busy with function
    bne dsp_scroll_clear_line_loop           ; Still busy....


; set back original FG color

    pla
    sta FG_COLOR_B
    pla
    sta FG_COLOR_G
    pla
    sta FG_COLOR_R
    jsr display_set_fg_color  ; Clear screen by filling with black color


; set cursor to beginnign of last line

    lda #RA8889_F_CURX0     ; Select X cursor LB
    sta RA8889_CMD
    lda #$00                ; Set to 0, beginning of line
    sta RA8889_DAT
    lda #RA8889_F_CURX1     ; Select X cursor LB
    sta RA8889_CMD
    lda #$00                ; Set to 0, beginning of line
    sta RA8889_DAT
    lda #RA8889_F_CURY0     ; Select Y cursor LB
    sta RA8889_CMD
    lda #$36                ; Set to 0, beginning of line
    sta RA8889_DAT
    lda #RA8889_F_CURY1     ; Select Y cursor LB
    sta RA8889_CMD
    lda #$02                ; Set to 0, beginning of line
    sta RA8889_DAT


    rts

;-------------------------------------------------------------------------
; Set LCD display foreground color to black
;-------------------------------------------------------------------------



;-------------------------------------------------------------------------
; LCD display carriage return
;-------------------------------------------------------------------------
snd_cr_display:

    lda DISPLAY_CTRL
    and #$01
    beq snd_cr_display_done

    lda #RA8889_F_CURY0     ; Select Y cursor LB
    sta RA8889_CMD
    lda RA8889_DAT          ; Read current Y value LB
    cmp #$36
    bcc snd_cr_display_no_scroll 
    lda #RA8889_F_CURY1     ; Select Y cursor LB
    sta RA8889_CMD
    lda RA8889_DAT          ; Read current Y value LB
    cmp #$02
    bcc snd_cr_display_no_scroll 


    jsr display_scroll
    rts


snd_cr_display_no_scroll:
    lda #RA8889_F_CURX0     ; Select X cursor LB
    sta RA8889_CMD
    lda #$00                ; Set to 0, beginning of line
    sta RA8889_DAT
    lda #RA8889_F_CURX1     ; Select X cursor LB
    sta RA8889_CMD
    lda #$00                ; Set to 0, beginning of line
    sta RA8889_DAT
    lda #RA8889_F_CURY0     ; Select Y cursor LB
    sta RA8889_CMD
    lda RA8889_DAT          ; Read current Y value LB
    clc                     ; Clear carry flag
    adc DISPLAY_CHAR_HT     ; Add character height: move one line down
    sta RA8889_DAT	    ; Store LB of Y value
    lda #RA8889_F_CURY1      ; Read current Y value LHB
    sta RA8889_CMD
    lda RA8889_DAT          ; Read current Y value HB
    adc #$00                ; Add 0 with carry, adds one if LB wrapped
    sta RA8889_DAT	    ; store HB  of Y value.
snd_cr_display_done:
    rts



;-------------------------------------------------------------------------
;  Interrupt handler
;-------------------------------------------------------------------------


nmi:
irq:
; inc IRQ_COUNTER
; lda IRQ_COUNTER
 jsr led_out
 lda ACIA_STATUS ; Was IRQ from Serial?
 and #$80 ; IRQ occurred and RDR full
 bne acia_irq
 rti

acia_irq:
 and #$08 ; RDR full
 bne handle_serial_input
 lda #$01 ; TDRE, set variable in RAM
 sta ACIA_TDRE
 rti

 handle_serial_input:
 lda ACIA_DATA ; read ACIA
 jsr led_out ; output char on led
 jsr send_char_acia ; echo chat back
 rti

;-------------------------------------------------------------------------
;  Messages, Errors
;-------------------------------------------------------------------------

startup_message: .asciiz "GRU-10 Computer, v0.127"
boot_message: .asciiz "GRU BIOS v0.1, ready..."
file_loaded_message: .asciiz "File loaded, size (B): "
wozmon_message: .asciiz "Starting WozMon"
load_message: .asciiz "Waiting for file on serial port"
run_message: .asciiz "Running app"
dsp_err_msg: .asciiz "No Display found"
kbd_err_msg: .asciiz "No Keyboard found"


gruos_prompt:       .asciiz "gru-bios>"

gruos_cmd_wozmon:   .asciiz "wozmon"
gruos_cmd_load:     .asciiz "load"
gruos_cmd_run:      .asciiz "run"
gruos_cmd_list:      .asciiz "list"

gruos_syn_err:      .asciiz "Syntax Error"
gruos_kernel_err:   .asciiz "Kernel Error"

GRUOS_NUM_CMDS = $04
gruos_cmd_table_lo: .byte<gruos_cmd_wozmon, <gruos_cmd_load, <gruos_cmd_run, <gruos_cmd_list
gruos_cmd_table_hi: .byte>gruos_cmd_wozmon, >gruos_cmd_load, >gruos_cmd_run, >gruos_cmd_list

;gruos_sr_table_lo: .byte<gruos_sr_wozmon, <gruos_sr_load, <gruos_sr_run
;gruos_sr_table_hi: .byte>gruos_sr_wozmon, >gruos_sr_load, >gruos_sr_run



 .org $fffa
 .word nmi
 .word reset
 .word irq

