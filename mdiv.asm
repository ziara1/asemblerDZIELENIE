section .text

global mdiv
    ; rdi - adres tablicy x
    ; rsi - n
    ; rdx - y - r8
    ; r8 przenosze y do r8
    ; rdx to bedzie reszta z dzielenia
    ; rcx jest n zeby liczyc petle

mdiv:

    mov r8, rdx
    mov rcx, rsi
    xor rdx, rdx                ; zeruje rdx, bo pozniej go uzywam w dzieleniu
    xor r9b, r9b
    xor r10b, r10b

.check_y:
    test r8, r8
    jns .check_x                    ; jesli y > 0 to  skacze
    not r8                          ; jesli y < 0 to zmieniam go na -y
    inc r8
    dec r9b                         ; jesli r9b bedzie = 0 to x i y taki sam znak

.check_x:
    mov rax, [rdi + rcx * 8 - 8]    ; laduje x do rax x[n-1]
    test rax, rax
    jns .loop                       ; jesli x >= 0 to skok
    inc r9b                         ; jesli r9b bedzie = 0 to x i y taki sam znak
    inc r10b                        ; zeby wiedziec czy reszte zmieniac na -1

.reverse_x:
    xor r11, r11
    mov rax, 1                      ; bo w pierwszej komorce dodaje 1 (not i inc)
.reverse_loop:
    not qword [rdi + r11 * 8]
    add qword [rdi + r11 * 8], rax
    setc al
    inc r11
    cmp r11, rsi
    jne .reverse_loop
    test rcx, rcx                   ; bo jesli rcx = 0 to loop juz byl wykonany
    jz .exit

.loop:
    dec rcx
    mov rax, [rdi + rcx * 8]        ; dzielenie rdx:rax przez r8, w rdx reszta
    div r8
    mov [rdi + rcx * 8], rax
    test rcx, rcx                   ; moze niepotrzebne
    jnz .loop

.negative_remainder:                ; jesli trzeba zmienic reszte na ujemna
    test r10b, r10b
    jz .negative_product
    not rdx
    inc rdx

.negative_product:                  ; jesli trzeba zmienic iloraz na ujemny
    test r9b, r9b                   
    jnz .reverse_x
    mov rax, [rdi + rsi * 8 - 8]    ; jesli iloraz powinien byc dodatni, czyli 
    test rax, rax                   ; nie zmieniamy go na ujemny, ale jest ujemny
    js .handle_sigfpe               ; tzn ze wystapil overflow

.exit:
    mov rax, rdx                    ; w rdx zostala reszta z dzielenia
    ret                            

.handle_sigfpe:
    div r9b                         ; bo r9b = 0 wtedy

; POLSKIE ZNAKI