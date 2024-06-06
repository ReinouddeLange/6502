PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

  .org $8000 

reset:  
  ldx #$ff
  txs

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB

  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction

  ldx #0
print:
  lda message,x  ; Loads the first character from string: message
  beq loop       ; Branch to loop if A register is zero
  jsr print_char
  inx            ; Increment X to read the next character after the jump
  jmp print

loop:
  jmp loop

message: .asciiz " Hello, world!                          I like the 6502"

lcd_wait:
  pha            ; Push content A register to the stack
  lda #%00000000 ; Set all pins on port B to input
  sta DDRB
lcd_busy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000 ; Compare busy flag using AND instruction and set zero flag or not
  bne lcd_busy   ; Branch Not Equal when zero flag is set

  lda #RW
  sta PORTA
  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  pla            ; Pull stored content from the stack an load in A register
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #E         ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)  ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts

  .org $fffc
  .word reset
  .word $0000
