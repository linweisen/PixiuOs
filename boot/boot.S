	.code16
	.equ SYSSIZE, 0x3000

	.global _start, begtext, begdata, begbss, endtext, enddata, endbss
	.text
	begtext:
	.data
	begdata:
	.bss
	begbss:
	.text

	.equ SETUPLEN, 4		# nr of setup-sectors
	.equ BOOTSEG, 0x07c0		# original address of boot-sector
	.equ SETUPSEG, 0x800
	.equ ROOT_DEV, 0x301
_start:
    mov	$BOOTSEG, %ax		#将ds,es,ss都设置成移动后代码所在的段处(0x9000)
	mov	%ax, %ds
	mov	%ax, %es
	mov	%ax, %ss
	mov	$0x00, %sp
# -----------------------------------------------------------
#   INT 0x10   功能号:0x03	   功能描述:获取光标位置
# -----------------------------------------------------------
# 输入：
# AH 功能号 = 0x06
# BH 页号 = 0x00
# 返回值：
# CH = 光标开始行    CL = 光标结束行
# DH = 行           DL = 列
get_cursor_pos:
	mov	$0x03, %ah
	xor	%bh, %bh
	int	$0x10
# ------------------------------------------------------------------
#   INT 0x10   功能号:0x13	   功能描述:以电传打字机的方式显示字符串
# ------------------------------------------------------------------
# 输入：
# AH 功能号 = 0x06         AL 显示模式 = 0x01(字符串只包含字符码,显示之后更新光标位置,属性值在BL中)
# BH 页号 = 0x00           BL 属性值 = 0x07 黑色字体
# CX 字符串长度
# DH 行                    DL 列
# ES:BP 字符串的段:偏移地址
# 无返回值
show_mbr_msg:
    .equ LN, mbr_msg_end-mbr_msg
	mov	$LN, %cx
	mov	$0x0007, %bx
	mov $mbr_msg, %bp
	mov	$0x1301, %ax
	int	$0x10
# ------------------------------------------------------------------
#   INT 0x13   功能号:0x02	   功能描述:读扇区
# ------------------------------------------------------------------
# 输入：
# AH 功能号 = 0x02         AL 读取的扇区数量 = SETUPLEN
# CH 柱面 = 0x00           CL 扇区 = 0x02 (cx cl中0~5位为扇区,6~7磁道号高2位,ch为磁道号的低八位)
# DH 磁头 = 0x00           DL 驱动器 = 0x80 （0x00~0x7F：软盘;0x80~0x0FF：硬盘)
# ES:BX 指向数据缓冲区
# 返回值:
# 如果出错则CF标志置位, AH中是出错码
load_setup:
	mov	$0x0000, %dx
	mov	$0x0002, %cx
	push %es
    mov $SETUPSEG, %ax
    mov %ax, %es
	mov	$0x0200, %bx
	.equ AX, 0x0200+SETUPLEN
	mov $AX, %ax
	int	$0x13
	pop %es
	jnc	ok_load_setup
	jmp end
ok_load_setup:
    ljmp $SETUPSEG, $0
end:
    jmp end
mbr_msg:
	.byte 13,10
	.ascii "PixiuOs is booting ..."
	.byte 13,10,13,10
mbr_msg_end:
	.org 508
root_dev:
	.word ROOT_DEV
boot_flag:
	.word 0xAA55

	.text
	endtext:
	.data
	enddata:
	.bss
	endbss:
