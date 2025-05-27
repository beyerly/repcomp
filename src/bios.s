 .org $8000


PORTB = $6000 ; VIA PORTB
PORTA = $6001 ; VIA PORTA
PORTBDDR = $6002 ; VIA PORTB Data Direction
PORTADDR = $6003 ; VIA PORTA Data Direction
AUXCTRL = $600B ; VIA Auxilary Control Register
KEYPRESSED = $01
DELAY = $ff

reset:
 lda #$ff
 sta PORTBDDR ; VIA Port B all outputs
 lda #$00
 sta PORTADDR ; VIA Port A all inputs
 lda #00
 sta AUXCTRL ; VIA PORT A latching disabled


pattern0:
 lda #$55
 sta PORTB ; LED pattern 1
 ldx #DELAY ; load delay counter
wait0:
 lda PORTA ; read keys
 cmp #KEYPRESSED ; pressed?
 beq pattern1 ; witch pattern
 dex ; decrement delay counter
 bne wait0 ; repeat untill delay completed
 lda #$aa
 sta PORTB  ; LED pattern 1
 ldx #DELAY
wait1:
 lda PORTA
 cmp #KEYPRESSED
 beq pattern1
 dex
 bne wait1
 jmp pattern0


pattern1:
 lda #$FF
 sta PORTB ; LED pattern 1

 ldx #DELAY
wait2:
 lda PORTA
 cmp #KEYPRESSED
 beq pattern0
 dex
 bne wait2
 lda #$00
 sta PORTB  ; LED pattern 1
 ldx #DELAY
wait3:
 lda PORTA
 cmp #KEYPRESSED
 beq pattern0
 dex
 bne wait3
 jmp pattern1

 .org $fffc
 .word reset
 .word $0

