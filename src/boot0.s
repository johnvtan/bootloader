; BIOS loads us in 16 bit real mode, so we have to make sure NASM outputs 16 bit code
bits 16

; export print_str symbol so boot1 can use it
global print_str

; tell the assembler that the boot2 symbol is defined elsewhere
extern boot1

boot0:
    mov si, boot0_start_str
    call print_str
    
    ; first thing to do is zero out segment/offset regs
    xor ax, ax ; xoring something with itself is always 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    ; enable A20 gate by calling BIOS INT 15 function 2401
    mov ax, 0x2401
    int 0x15    

    ; query A20 status and halt if it isn't enabled
    mov ax, 0x2402
    int 0x15
    cmp al, 0x01 
    jc halt 

    ; set up stack pointer
    ; stack grows downward, so this won't conflict with location of bootloader
    mov sp, 0x7c00

reset_floppy:
    ; reset floppy disk
    mov si, boot0_reset_floppy_str
    call print_str
    mov ah, 0
    mov dl, 0   ; drive number - 0 is the floppy drive
    int 0x13
    jc reset_floppy     ; if there was an error try again

load_next_sector:
    mov si, boot0_load_sector_str
    call print_str

    ; bx contains the pointer to the buffer to load the next sector in
    ; boot1 = 0x7E00, as defined in boot1.s
    ; TODO - maybe extern symbols from linker script directly instead
    mov bx, boot1

    mov al, 1 ; only load one sector
    mov ch, 0 ; on track 1
    mov cl, 2 ; read track 2 (boot 0 was on track 1)
    mov dh, 0 ; read from head 0
    mov dl, 0 ; drive number 0 = floppy disk

    mov ah, 0x02 ; call function 2 with int 13 - which means read from floppy
    int 0x13
    jc halt  ; carry flag will be set if BIOS function failed
    jmp boot1 ; jump to second stage bootloader

halt:
    ; if we get here, something went wrong
    mov si, boot0_fail_str
    call print_str
    cli
    hlt

; subroutine for printing out a null terminated string
; assumes that string has been loaded into si reg (which is what?? - stack?)
print_str:
    mov ah, 0x0e ; tells bios to write a character in TTY mode 
 print_str_loop:
    lodsb ; load byte pointed to by si into al
    or al, al ; OR current char with itself
    jz print_str_done ; if the character is zero, exit from function
    int 0x10 ; BIOS interrupt call for video services - based on value of ah
    jmp print_str_loop

 ; exit point for the print_str routine
 print_str_done:
    ret
    
; String literal definitions
; 13 is carriage return, 10 is new line
boot0_reset_floppy_str: db "Resetting floppy drive...", 13, 10, 0
boot0_load_sector_str: db "Loading next sector...", 13, 10, 0
boot0_start_str: db "Boot 0 starting...", 13, 10, 0
boot0_fail_str: db "BOOT0: SOMETHING WENT WRONG!", 13, 10, 0

times 510 - ($-$$) db 0 ; pad remaining bytes with 0 until 510 
dw 0xaa55 ; magic bootloader bytes at the end of the boot sector
