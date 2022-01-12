;loader.asm
;Copyright 2021-2022 Lin Chenjun,All rights reserved.

org 0x500
[bits 16]

%include "protect.inc"

GDT_BASE: SEGMDESC 0,0,0
SectionCode32:     SEGMDESC 0x00000000,0xfffff,AR_CODE32 ;32位代码段
SectionData32:     SEGMDESC 0x00000000,0xfffff,AR_DATA32 ;32位数据段
SectionVideo:      SEGMDESC 0x000b8000,0x00007,AR_DATA32 ;文字显存
SectionColorVideo: SEGMDESC 0x000a0000,0x0000e,AR_DATA32 ;彩色显存

GDT_SIZE equ ($ - GDT_BASE)
GDT_LIMIT equ GDT_SIZE - 1

times 60 dq 0;预留60个描述符

;段选择子
SelectorCode32     equ (((SectionCode32-GDT_BASE)/8) | TI_GDT | RPL0)
SelectorData32     equ (((SectionData32-GDT_BASE)/8) | TI_GDT | RPL0)
SelectorVideo      equ (((SectionVideo -GDT_BASE)/8) | TI_GDT | RPL0)
SelectorColorVideo equ (((SectionColorVideo-GDT_BASE)/8) | TI_GDT | RPL0)

gdt_ptr dw GDT_LIMIT
        dd GDT_BASE

times (0x300 - ($ - $$)) db 0

;&total_memory_bytes = 0x500+0x300 = 0x800
total_memory_bytes dq 0 ;内存大小(单位:字节)

ards_buf times 240 db 0
ards_nr dw 0

times (0x500-($ - $$)) db 0;对齐到文件起始0x500处

;$ =0x500 + 0x500 = 0xa00

;loader从此处开始执行
start:

; int 0x15 edx=0x534d4150:获取内存布局
    xor ebx,ebx       ;将ebx清零
    mov edx,0x534d4150;edx = "SMAP"
    mov di,ards_buf
    .e820_memory_get_loop:
        mov ax,0xe820 ;int 0x15子功能号e820
        mov ecx,20    ;ards结构大小是20字节
        int 0x15
        jc .e820_get_error ;cf为1表示有错误
        add di,cx          ;使di指向下一个ards结构
        inc word [ards_nr] ;让ards_nr自增1
        cmp ebx,0
        jnz .e820_memory_get_loop
    ;寻找内存容量,就是最大的那一块内存
    mov cx,[ards_nr]
    mov ebx,ards_buf
    xor edx,edx       ;edx先清零
    .find_max_memory: ;冒泡排序
        mov eax,[ebx]
        add eax,[ebx + 8]
        add ebx,20
        cmp edx,eax
        jge .next_ards
        
jmp $
