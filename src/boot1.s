bits 16

; export boot1 symbol so boot0 can jump here
global boot1

; refer to print_str routine in boot0
extern print_str

boot1:
    mov ax, 0x1234
    mov si, boot1_hello_str
    call print_str

halt:
    cli
    hlt

boot1_hello_str: db "Hello from boot1!!", 13, 10, 0
times 512 - ($-$$) db 0 ; pad remaining bytes with 0 until 510 
