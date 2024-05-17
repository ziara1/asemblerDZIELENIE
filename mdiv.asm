section .text

global mdiv
    ; rdi - adres tablicy x
    ; rsi - n
    ; rdx - y - r8
    ; r8 przenoszę y do r8
    ; rdx to będzie reszta z dzielenia
    ; rcx jest n żeby liczyć pętlę

mdiv:

    mov r8, rdx
    mov rcx, rsi
    xor rdx, rdx                
    xor r9b, r9b
    xor r10b, r10b

.check_y:
    test r8, r8
    jns .check_x                    ; jeśli y >= 0 to skaczę
    ;not r8                          ; jeśli y < 0 to zmieniam go na -y
    ;inc r8
    neg r8
    dec r9b                         ; jeśli r9b będzie = 0 to x i y taki sam znak

.check_x:
    mov rax, [rdi + rcx * 8 - 8]    ; ładuję x do rax x[n-1]
    test rax, rax
    jns .loop                       ; jeśli x >= 0 to skok
    inc r9b                         ; jeśli r9b będzie = 0 to x i y taki sam znak
    inc r10b                        ; żeby wiedzieć czy resztę zmieniać na -1

.reverse_x:
    xor r11, r11
    mov rax, 1                      ; bo w pierwszej komórce dodaję 1 (not i inc)
.reverse_loop:
    not qword [rdi + r11 * 8]
    add qword [rdi + r11 * 8], rax
    setc al
    inc r11
    cmp r11, rsi
    jne .reverse_loop
    test rcx, rcx                   ; bo jeśli rcx = 0 to loop już był wykonany
    jz .exit

.loop:
    dec rcx
    mov rax, [rdi + rcx * 8]        ; dzielenie rdx:rax przez r8, w rdx reszta
    div r8
    mov [rdi + rcx * 8], rax
    ;test rcx, rcx                   ; może niepotrzebne
    jnz .loop

.negative_remainder:                ; jeśli trzeba zmienić resztę na ujemną
    test r10b, r10b
    jz .negative_product
    ;not rdx
    ;inc rdx
    neg rdx

.negative_product:                  ; jeśli trzeba zmienić iloraz na ujemny
    test r9b, r9b                   
    jnz .reverse_x
    mov rax, [rdi + rsi * 8 - 8]    ; jeśli iloraz powinien być dodatni, czyli 
    test rax, rax                   ; nie zmieniamy go na ujemny, ale jest ujemny
    js .handle_sigfpe               ; tzn że wystąpił overflow

.exit:
    mov rax, rdx                    ; w rdx została reszta z dzielenia
    ret                            

.handle_sigfpe:
    div r9b                         ; bo r9b = 0 wtedy
