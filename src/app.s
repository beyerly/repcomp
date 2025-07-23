 .org $2000

PORTB = $6000 ; VIA PORTB
SLEEP_CNTR = $1004 ; 2B


zp_str_ptr = $00   ; 2B, Pointer to message string

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
RA8889_BTE_WTH0 = $B1
RA8889_BTE_WTH1 = $B2
RA8889_BTE_HIG0 = $B3
RA8889_BTE_HIG1 = $B4

RA8889_DT_WTH0 = $AB
RA8889_DT_WTH1 = $AC


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


dp_start:
 jsr led_pattern1
 jsr led_pattern
 jsr display_init
 jsr display_test
 jmp wozmon


;-------------------------------------------------------------------------
;  RA8889 LCD display;
;-------------------------------------------------------------------------

no_display:
    jsr led_pattern1
    jmp wozmon


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
    
    rts



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

display_set_text_mode:
    lda #RA8889_ICR
    sta RA8889_CMD
    lda RA8889_DAT
    ora #SET_BIT_2 ; text mode
    sta RA8889_DAT
    rts

display_set_graphics_mode:
    lda #RA8889_ICR
    sta RA8889_CMD
    lda RA8889_DAT
    and #CLEAR_BIT_2 ; graphics mode
    sta RA8889_DAT
    rts

display_on:
    lda #RA8889_DPCR
    sta RA8889_CMD
    lda RA8889_DAT
    ora #SET_BIT_6 ; display on
    sta RA8889_DAT
    rts

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


clear_screen:
    lda #RA8889_BTE_CTRL1
    sta RA8889_CMD
    lda #$0C                  ; Solid fill
    sta RA8889_DAT

    lda #RA8889_BTE_WTH0
    sta RA8889_CMD
    lda #$00                  ; 
    sta RA8889_DAT
    lda #RA8889_BTE_WTH1
    sta RA8889_CMD
    lda #$04                  ; 
    sta RA8889_DAT

    lda #RA8889_BTE_HIG0
    sta RA8889_CMD
    lda #$58                  ; 
    sta RA8889_DAT
    lda #RA8889_BTE_HIG1
    sta RA8889_CMD
    lda #$04                  ; 
    sta RA8889_DAT

    lda #RA8889_DT_WTH0
    sta RA8889_CMD
    lda #$00                  ; 
    sta RA8889_DAT
    lda #RA8889_DT_WTH1
    sta RA8889_CMD
    lda #$04                  ; 
    sta RA8889_DAT

    jsr display_set_fg_color_black

    lda #RA8889_BTE_CTRL0
    sta RA8889_CMD
    lda RA8889_DAT                  ; 
    ora #SET_BIT_4
    sta RA8889_DAT

    lda #RA8889_BTE_CTRL0
    sta RA8889_CMD
clear_screen_loop:
    lda RA8889_DAT                  ; 
    and #SET_BIT_4
    bne clear_screen_loop  

    rts


display_set_fg_color_white:
    lda #RA8889_FGCR
    sta RA8889_CMD
    lda #$FF
    sta RA8889_DAT
    lda #RA8889_FGCG
    sta RA8889_CMD
    lda #$FF
    sta RA8889_DAT
    lda #RA8889_FGCB
    sta RA8889_CMD
    lda #$FF
    sta RA8889_DAT
    rts

display_set_fg_color_black:
    lda #RA8889_FGCR
    sta RA8889_CMD
    lda #$00
    sta RA8889_DAT
    lda #RA8889_FGCG
    sta RA8889_CMD
    lda #$FF
    sta RA8889_DAT
    lda #RA8889_FGCB
    sta RA8889_CMD
    lda #$00
    sta RA8889_DAT
    rts

display_set_bg_color_black:
    lda #RA8889_BGCR
    sta RA8889_CMD
    lda #$00
    sta RA8889_DAT
    lda #RA8889_BGCG
    sta RA8889_CMD
    lda #$00
    sta RA8889_DAT
    lda #RA8889_BGCB
    sta RA8889_CMD
    lda #$00
    sta RA8889_DAT
    rts



display_test:
    jsr display_set_text_mode
    jsr display_blinking_cursor_on
    jsr display_on
    jsr clear_screen
    jsr display_set_fg_color_white    
    jsr display_set_bg_color_black
    ldx #<startup_message ;
    stx zp_str_ptr
    ldx #>startup_message
    stx zp_str_ptr+1
    jsr snd_str_display       ; Send Startup message to serial
;    jsr snd_cr             ; newline
    rts



startup_message: .asciiz "GRU-10 Computer, v0.11"

