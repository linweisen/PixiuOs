    .code16
    .equ CR0_PE_ON, 0x1
    .equ PROT_MODE_CSEG, 0x8
    .equ PROT_MODE_DSEG, 0x10
    .equ MSG_LEN, boot_msg_end-boot_msg
    .global _start
_start:
    mov %cs, %ax
    mov %ax, %ds
    mov %ax, %es
# -----------------------------------------------------------
#   INT 0x10   功能号:0x03       功能描述:获取光标位置
# -----------------------------------------------------------
# 输入：
# AH 功能号 = 0x06
# BH 页号 = 0x00
# 返回值：
# CH = 光标开始行    CL = 光标结束行
# DH = 行           DL = 列
    mov $0x03, %ah
    xor %bh, %bh
    int $0x10
# ------------------------------------------------------------------
#   INT 0x10   功能号:0x13       功能描述:以电传打字机的方式显示字符串
# ------------------------------------------------------------------
# 输入：
# AH 功能号 = 0x06         AL 显示模式 = 0x01(字符串只包含字符码,显示之后更新光标位置,属性值在BL中)
# BH 页号 = 0x00           BL 属性值 = 0x07 黑色字体
# CX 字符串长度
# DH 行                    DL 列
# ES:BP 字符串的段:偏移地址
# 无返回值
    mov $MSG_LEN, %cx
    mov $0x000b, %bx
    mov $boot_msg, %bp
    mov $0x1301, %ax
    int $0x10

# -----------------------------------------------------------
#   进入保护模式
# -----------------------------------------------------------
# 1 加载全局描述符表GDT
# 2 打开A20地址线
# 3 cr0寄存器第0位置1
    cli
    cld
    lgdt gdt_48

    inb $0x92, %al
    orb $0b00000010, %al
    outb %al, $0x92

    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0

    ljmp $PROT_MODE_CSEG, $protcseg

.error_hlt:
    hlt

    .code32
protcseg:
    mov $PROT_MODE_DSEG, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    call boot_kernel
end:
    jmp end

gdt:
    .word 0,0,0,0
#================ 代码段===================
# 基地址 0x00000000
# 段界限 0x007FF (2047 + 1) * 4096 = 8MB
# G(颗粒度) = 1 (4096K)
# D/B(有效地址及操作数) = 1 32位
# L = 0 32位(=1位64位）
# AVL = 0
# P(Present 是否存在) = 1
# DPL = 00 特权级
# S = 1 非系统段
# TYPE(XCRA) = 1010 可读/可执行代码段
#==========================================
    .word 0x07FF
    .word 0x0000
    .word 0x9A00
    .word 0x00C0
#================ 数据段===================
# 基地址 0x00000000
# 段界限 0x007FF (2047 + 1) * 4096 = 8MB
# G(颗粒度) = 1 (4096K)
# D/B(有效地址及操作数) = 1 32位
# L = 0 32位(=1位64位）
# AVL = 0
# P(Present 是否存在) = 1
# DPL = 00 特权级
# S = 1 非系统段
# TYPE(XCRA) = 0010 可读写数据段
#==========================================
    .word 0x07FF
    .word 0x0000
    .word 0x9200
    .word 0x00C0

gdt_48:
    .word 0x800
    .long gdt
boot_msg:
    .byte 13,10
    .ascii "Now PixiuOs in setup ..."
    .byte 13,10
boot_msg_end:
