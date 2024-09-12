  ; CRLF terminator shorthand.
  %define ENDLINE 0x0d, 0x0a

  ; These are the FAT headers
  jmp short _start
  nop
  bdb_oem   db "MSWIN4.1" ; OEM identifier
  bdb_bps   dw 0x0200     ; Number of bytes per sector
  bdb_spc   db 0x01       ; Number of sectors per cluster
  bdb_rs    dw 0x0001     ; Number of reserved sectors
  bdb_fats  db 0x02       ; Number of file allocation tables
  bdb_rde   dw 0x00e0     ; Number of root directory entries
  bdb_nsect dw 0x0b40     ; The total sectors in the logical volume
  bdb_mdt   db 0xf0       ; Media descriptor type
  bdb_spf   dw 0x0009     ; Number of sectors per FAT
  bdb_spt   dw 0x0012     ; Number of sectors per track
  bdb_heads dw 0x0002     ; Number of heads or sides on the storage media
  bdb_hdn   dd 0x00000000 ; Number of hidden sectors
  bdb_lsc   dd 0x00000000 ; Large sector count

  ; Tells the assembler to emit 16-bit code.
  bits 16

  ; This instruction tells the assembler that all instructions and labels
  ; should be offset by the value provided. We need this to hint to the
  ; assembler where in memory the BIOS will load the code.
  org 0x7c00

  ; Prints a string to the screen.
  ; Parameters:
  ;   - ds:si points to string
puts:
  push si
  push ax
.loop:
  ; Load the character currently pointed to by si into al, then increment si.
  lodsb
  or al, al
  jz .done
  ; Call interrupt 0x10 (16) with 0x0e in ah to print the character currently
  ; in al to the screen and advance the cursor
  mov ah, 0x0e
  mov bh, 0
  int 0x10
  ; Of course we need to repeat with the next character
  jmp .loop
.done:
  ; Reset the data registers and the instruction pointer to what they were
  ; before to continue normal execution
  pop ax
  pop si
  ret

_start:
  ; Not all BIOS software will load the segments like we expect them, so we
  ; will explicitly set up the registers correctly here.
  mov ax, 0
  mov ds, ax
  mov es, ax
  ; Set up the stack segment and offset to point to the beginning of the
  ; program. The stack will grow downward, away from the rest of the program
  ; data.
  mov ss, ax
  mov sp, 0x7c00

  mov si, message
  call puts

  hlt

.halt:
  jmp .halt

  ; Null-terminated message to print to the screen
  message db "Hello, world!", ENDLINE, 0x00

  ; These are the magic bytes at the end of the sector that mark it as
  ; 'bootable' to the BIOS.
  times 510 - ($ - $$) db 0
  dw 0xaa55
