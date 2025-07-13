 .org $2000

PORTB = $6000 ; VIA PORTB
SLEEP_CNTR = $1004 ; 2B


start:
 ldx #$8
 lda #$1
 clc
led_pattern:
 jsr led_out
 rol A
 ldy #$FF
 sty SLEEP_CNTR
 ldy #$1F
 sty SLEEP_CNTR + 1
 jsr sleep
 dex
 bne led_pattern
 jmp start


; 16-bit sleep. Assumes SLEEP_CNTR > 0.
sleep:
 pha              ; save A
 txa              ; X - > A
 pha              ; save X
sleep_loop:
 dec SLEEP_CNTR
 bne sleep_loop
 lda SLEEP_CNTR + 1
 beq sleep_done
 dec SLEEP_CNTR + 1
 lda #$FF
 sta SLEEP_CNTR
 jmp sleep_loop
sleep_done:
 pla              ; restore Y
 tay              ; A -> Y
 pla              ; restore X
 rts

led_out:
 sta PORTB ; LED pattern 1
 rts
