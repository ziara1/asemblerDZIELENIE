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
    jz .handle_sigfpe           ; wykonuje skok, gdy rdx == 0
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
    ;inc r10b                       ; zeby wiedziec czy reszte zmieniac na -1

.reverse_x:
    xor r11, r11
    stc
.reverse_loop:
    not qword [rdi + r11 * 8]
    adc qword [rdi + r11 * 8], 0
    inc r11
    cmp rsi, r11
    jne .reverse_loop
    test r10b, r10b
    jz .exit
    inc r10b

.loop:
    dec rcx
    mov rax, [rdi + rcx * 8]
    div r8
    mov [rdi + rcx * 8], rax
    test rcx, rcx                   ; moze niepotrzebne
    jnz .loop
    ;mov r11, rdx                   ; przenosze reszte //moze niepotrzebne?

.negative_remainder:
    test r10b, r10b
    jz .negative_product
   ;not r11
   not rdx
   ;inc r11
   inc rdx

.negative_product:
    test r10b, r10b                 ; bo jesli r10b zmieniony tzn ze x zmieniony
    jz .reverse_x

.exit:
   ;mov rax, r11                    ; w r11 jest remainder
   mov rax, rdx
    ret                             ; wynik zwracam w rax


.handle_sigfpe:
    xor al, al
    div al

;; mozna juz w reverse loop odjac czy dodaac po prostu bo wtedy x jest ujemny
