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

USER_APP   = $2000   ; Start address for user programms

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

    lda #$00
    sta ACIA_STATUS     ; Reset ACIA
    lda #$1f
    sta ACIA_CTRL       ; 1 stop bit, 8b, Baud rate 19200
    lda #$0b
    sta ACIA_CMD        ; Odd parity, parity disabled, reveiver normal, Tirq and Rirq disabled, DTR not ready

    lda #$01
    sta ACIA_TDRE       ; iniit ACIA transmit data register as empty

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
    jsr snd_str_acia        ; Send Startup message to serial
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
    jsr snd_str_acia       ; Send boot message to serial
    jsr snd_cr             ; newline
kernel_loop:
    jsr get_acia_char       ; read serial
    cmp #$ff                ; is it a header of an app?
    beq jump_load_app       ; yes, load app
    cmp #$6c                ; 'l'; list program
    beq jump_list_app       ; yes, list app
    cmp #$65                ; 'e'; execute program
    beq jump_exe_app        ; yes, execute app
    cmp #$77                ; 'w'; execute program
    beq jump_wozmon         ; yes, execute wozmon
; no known command: keep on listening
    jsr led_out             ; echo on led
    jsr send_char_acia      ; echo to serial
    jmp kernel_loop
jump_wozmon:                ; Absolute jump because brach is out of range.
    jmp wozmon
jump_load_app:              ; Absolute jump because brach is out of range.
    jmp load_app
jump_list_app:              ; Absolute jump because brach is out of range.
    jmp list_app
jump_exe_app:               ; Absolute jump because brach is out of range.
    jmp exe_app

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


;-------------------------------------------------------------------------
;  Send CR to serial
;-------------------------------------------------------------------------

snd_cr:
    pha
    lda #LF
    jsr send_char_acia
    lda #CR
    jsr send_char_acia
    pla
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
    jsr snd_str_acia       ; Send Startup message to serial
    jsr snd_cr             ; newline
    jmp USER_APP ; execute!

;-------------------------------------------------------------------------
;  Send code at $USER_APP on serial. Only singel page code snippets
;  Destructive on A, X, Y but we always return to kernel loop.
;-------------------------------------------------------------------------

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
;-------------------------------------------------------------------------
;  Set up file transfer
;-------------------------------------------------------------------------
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
  jsr snd_str_acia       ; Send message to serial
  lda APP_SIZE
  jsr PRBYTE             ; show file size on com
  lda APP_SIZE + 1
  jsr snd_cr             ; new line
  jmp kernel_loop   ; done

;-------------------------------------------------------------------------
;  Return byte from serial in A. This is blocking.
;-------------------------------------------------------------------------

get_acia_char:
    lda ACIA_STATUS        ; Check status
    and #$08               ; Receive ready set?
    beq get_acia_char      ; No? check again.
    lda ACIA_DATA          ; We have a char, read from ACIA
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
                jsr     snd_str_acia    ; Send Startup message to serial
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
                jsr     send_char_acia ; Output it.

GETLINE:        
                jsr     snd_cr         ; Send CR

                ldy     #0+1           ; Start a new input line
BACKSPACE:
                dey                    ; Backup text index
                bmi     GETLINE        ; Oops, line's empty, reinitialize

NEXTCHAR:
                jsr     get_acia_char  ; Wait for key press, note WozMon expects B7=1, and we don;t have that
                jsr     led_out
                sta     IN,Y           ; Add to text buffer
                jsr     send_char_acia ; Display character
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
                jsr     send_char_acia

PRDATA:
		lda     #" "           ; Print space
                jsr     send_char_acia
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
                jsr send_char_acia
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

startup_message: .asciiz "GRU-10 Computer, v0.125"
boot_message: .asciiz "Kernel v0.1, ready..."
file_loaded_message: .asciiz "File loaded, size (B): "
wozmon_message: .asciiz "Starting WozMon"
load_message: .asciiz "Waiting for file"
run_message: .asciiz "Running app"

 .org $fffa
 .word nmi
 .word reset
 .word irq

