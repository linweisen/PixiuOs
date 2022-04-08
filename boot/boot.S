    .code16
    .equ SETUPLEN, 1
    .equ SETUPSEG, 0x800
    .equ STACKADDR, 0x800*0x10
    .equ BOOTMSGLN, mbr_msg_end-mbr_msg

    .global _start
_start:
    mov %cs, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $STACKADDR, %sp
# -----------------------------------------------------------
#   INT 0x10   功能号:0x03       功能描述:获取光标位置
# -----------------------------------------------------------
# 输入：
# AH 功能号 = 0x06
# BH 页号 = 0x00
# 返回值：
# CH = 光标开始行    CL = 光标结束行
# DH = 行           DL = 列
get_cursor_pos:
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
show_mbr_msg:
    mov $BOOTMSGLN, %cx
    mov $0x0007, %bx
    mov $mbr_msg, %bp
    mov $0x1301, %ax
    int $0x10
# ------------------------------------------------------------------
#   INT 0x13   功能号:0x02       功能描述:读扇区
# ------------------------------------------------------------------
# 输入：
# AH 功能号 = 0x02         AL 读取的扇区数量 = SETUPLEN
# CH 柱面 = 0x00           CL 扇区 = 0x02 (cx cl中0~5位为扇区,6~7磁道号高2位,ch为磁道号的低八位)
# DH 磁头 = 0x00           DL 驱动器 = 0x80 （0x00~0x7F：软盘;0x80~0x0FF：硬盘)
# ES:BX 指向数据缓冲区
# 返回值:
# 如果出错则CF标志置位, AH中是出错码
load_setup:
    mov $0x0080, %dx
    mov $0x0002, %cx
    mov $SETUPSEG, %ax
    mov %ax, %es               #将setup加载到0x8000
    xor %bx, %bx
    xor %ax, %ax
    mov $0x02, %ah
    mov $SETUPLEN, %al         #setup 目前只占一个磁盘扇区
    int $0x13
    jnc ok_load_setup
    jmp end                    #加载失败则无限循环
ok_load_setup:
    ljmp $0, $STACKADDR         #跳转到setup 0x0:8000
end:
    jmp end
mbr_msg:
    .byte 13,10
    .ascii "PixiuOs is booting ..."
    .byte 13,10
mbr_msg_end:
    .org 510
boot_flag:
    .word 0xAA55