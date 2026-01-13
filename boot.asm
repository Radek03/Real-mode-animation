org 0x7C00

start:
    mov ax, 0x0013
    int 0x10

    ; tablice do odtwarzania utworu
    mov si, melody
    mov di, durations

    mov word [y_current], 75 ; pozycja
    mov word [y_target], 75
    mov byte [time], 0 ; czas

main_loop:
    mov ax, [si] ; dzielnik PIT (częstotliwość dla PC-speakera)
    push ax
    call play_tone
    pop ax

    xor dx, dx
    mov bx, 30
    div bx
    mov dx, 200
    sub dx, ax
    mov [y_target], dx

    call smooth_y ; ustawianie y
    call draw_frame ; rysowanie klatek

    mov ax, [di]
    imul ax,500 ; tempo animacji (czas trwania pojedynczej nuty)
    call delay

    add si, 2
    add di, 2
    cmp si, melody_end ; kolejne nuty, zapetlanie 

    jb main_loop
    mov si, melody
    mov di, durations
    jmp main_loop


smooth_y:
    mov ax, [y_target]
    sub ax, [y_current]
    sar ax, 2
    add [y_current], ax
    ret

draw_frame: 
    push si 
    push di 
    push es

    mov ax, 0xA000
    mov es, ax

    call wavefield; tlo
    call draw_bars; slupki

    inc byte [time]

    pop es 
    pop di 
    pop si 

    ret


wavefield:
    xor di, di
    mov cx, 320*200
.loop:
    xor ax, ax         
    mov al, [time]
    add ax, di
    shr al, 2
    and al, 0x18
    sub al, 0x0F
    stosb       ; zapis do pamieci
    loop .loop
    ret


draw_bars:
    xor cx, cx             
.next_bar:
    mov ax, [y_current]

    mov bl, [time]; efekt fali trojkatnej
    add bl, cl
    and bl, 15
    sub ax, bx
    jns .h_ok
    xor ax, ax
.h_ok:
    cmp ax, 120
    jbe .h_clip
    mov ax, 120
.h_clip:

    mov si, ax              ; wysokosc
    mov al, ah

    add al, 16              ; kolor 

    ; DI = 199*320 + x
    mov di, 199*320
    add di, cx

.bar_y:
    stosb           ; zapis piksela do pamieci
    sub di, 320
    dec si
    jnz .bar_y

    add cx, 4               ; szerokosc slupka
    cmp cx, 320
    jb .next_bar
    ret


play_tone:
    mov bx, ax
    mov al, 0xB6
    out 0x43, al ; tryb fali prostokatnej, generowanej przez pcspeaker
    mov al, bl
    out 0x42, al
    mov al, bh
    out 0x42, al
    in al, 0x61 ; właczenie głośnika
    or al, 3
    out 0x61, al
    ret

delay: ; czas 
    push cx
    push dx
    mov cx, ax        
.outer:
    mov dx, 0xFFFF
.inner:
    dec dx
    jnz .inner
    loop .outer
    pop dx
    pop cx
    ret


melody:
    ; E4 E4 F4 G4 | G4 F4 E4 D4
    dw 3626,3626,3419,3047,3047,3419,3626,4074
    ; C4 C4 D4 E4 | E4 D4 D4 0
    dw 4572,4572,4074,3626,3626,4074,4074,0

    ; E4 E4 F4 G4 | G4 F4 E4 D4
    dw 3626,3626,3419,3047,3047,3419,3626,4074
    ; C4 C4 D4 E4 | D4 C4 C4 0
    dw 4572,4572,4074,3626,4074,4572,4572,0

    ; D4 D4 E4 C4 | D4 E4 F4 E4
    dw 4074,4074,3626,4572,4074,3626,3419,3626
    ; C4 C4 D4 E4 | D4 C4 C4 0
    dw 4572,4572,4074,3626,4074,4572,4572,0
     ; E4 E4 F4 G4 | G4 F4 E4 D4
    dw 3626,3626,3419,3047,3047,3419,3626,4074
    ; C4 C4 D4 E4 | D4 C4 C4 0
    dw 4572,4572,4074,3626,4074,4572,4572,0
melody_end:



durations:
    dw 4,4,4,4,4,4,4,4
    dw 4,4,4,4,8,2,2,2
    dw 4,4,4,4,4,4,4,4
    dw 4,4,4,4,8,2,2,2
    dw 4,4,4,4,4,2,2,2
    dw 8,4,4,4,4,4,2,2
    dw 4,4,4,4,4,4,4,4
    dw 4,4,4,4,8,2,2,2


y_current dw 0
y_target  dw 0
time      db 0

; boot signature
%assign filler_size 510-($-$$)
times filler_size db 0
dw 0xAA55


