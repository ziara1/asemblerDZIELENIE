section .text

global mdiv
    ; rdi - adres tablicy x
    ; rsi - n
    ; rdx - y - r8
    ; r8 przenosze y do r8
    ; rdx to bedzie reszta z dzielenia aktualnego
    ; rcx jest n zeby liczyc petle
    ; r11 to bedzie remainder

mdiv:

    test rdx, rdx
    jz .handle_sigfpe           ; wykonuje skok, gdy rdx == 0ls
    mov r8, rdx
    mov rcx, rsi
    xor rdx, rdx                ; zeruje rdx, bo pozniej go uzywam w dzieleniu

    xor r9b, r9b
    xor r10b, r10b

.check_y:
    test r8, r8
    jns .check_x                    ; jesli y > 0
    not r8                          ; jesli y < 0 to zmieniam go na -y
    inc r8
    dec r9b                         ; jesli r9b bedzie = 0 to x i y taki sam znak

.check_x:
    mov rax, [rdi + rcx * 8 - 8]    ; laduje x do rax x[n-1]
    test rax, rax
    jns .loop                       ; jesli x >= 0 to skok
    inc r9b
    inc r10b                       ; zeby wiedziec czy reszte zmieniac na -1


.reverse_x:
    xor rdx, rdx
    mov rax, 1
.reverse_loop:
    not qword [rdi + rdx * 8]
    add [rdi + rdx * 8], rax
    setc al
    inc rdx
    cmp rdx, rsi
    jne .reverse_loop
    test rcx, rcx                     ; bo jesli rcx = 0 to loop juz byl wykonany
    jz .exit
    xor rdx, rdx

.loop:
    dec rcx
    mov rax, [rdi + rcx * 8]
    div r8
    mov [rdi + rcx * 8], rax
    test rcx, rcx                   ; moze niepotrzebne
    jnz .loop
    mov r11, rdx                   ; przenosze reszte //moze niepotrzebne?

.negative_remainder:
    test r10b, r10b
    jz .negative_product
    not r11
    inc r11

.negative_product:
    test r9b, r9b                 ; bo jesli r10b zmieniony tzn ze x zmieniony
    jnz .reverse_x
    mov rax, [rdi + rsi * 8 - 8]
    test rax, rax
    js .handle_sigfpe

.exit:
    mov rax, r11                    ; w r11 jest remainder
    ret                             ; wynik zwracam w rax


.handle_sigfpe:
    xor al, al
    div al

;; mozna juz w reverse loop odjac czy dodaac po prostu bo wtedy x jest ujemny

