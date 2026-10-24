org 0x7C00

start:
    mov ax, 0x0013
    int 0x10

    ; tablice do odtwarzania utworu
    mov si, melody
    mov di, durations

    mov word [y_current], 75
    mov word [y_target], 75
    mov byte [time], 0

main_loop:
    mov ax, [si]
    push ax
    call play_tone
    pop ax

    ; ruch kwadratu zgodnie z muzyka
    xor dx, dx
    mov bx, 30
    div bx
    mov dx, 200
    sub dx, ax
    mov [y_target], dx

    call smooth_y
    call draw_frame

    mov ax, [di]
    imul ax,500
    call delay

    add si, 2
    add di, 2
    cmp si, melody_end
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
    push ax
    push bx 
    push cx 
    push dx 
    push si 
    push di 
    push es

    mov ax, 0xA000
    mov es, ax

    call wavefield
    call draw_square

    inc byte [time]

    pop es 
    pop di 
    pop si 
    pop dx 
    pop cx 
    pop bx 
    pop ax
    ret


wavefield:
    xor di, di
    mov cx, 320*200
.loop:
    mov al, [time]
    add ax, di
    shr al, 2
    and al, 0x18
    sub al, 0x0F
   
    stosb
    loop .loop
    ret

draw_square:
    mov cx, 160        ; X
    mov bp, 8         ; rozmiar
    mov dx, [y_current]

    mov ax, dx
    mov bx, 320
    mul bx
    add ax, cx
    mov di, ax
    mov al, 0x0F       ;  kolor

    mov bx, bp
.y:
    push bx
    mov bx, bp
.x:
    stosb
    dec bx
    jnz .x
    add di, 320
    sub di, bp
    pop bx
    dec bx
    jnz .y
    ret

play_tone:
    mov bx, ax
    mov al, 0xB6
    out 0x43, al
    mov al, bl
    out 0x42, al
    mov al, bh
    out 0x42, al
    in al, 0x61
    or al, 3
    out 0x61, al
    ret

delay:
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


; =====================
; DANE
; =====================
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

%assign filler_size 510-($-$$)
times filler_size db 0
dw 0xAA55


