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
	.equ ROOT_DEV, 0x301
_start:
    mov	$BOOTSEG, %ax		#将ds，es，ss都设置成移动后代码所在的段处(0x9000)
	mov	%ax, %ds
	mov	%ax, %es
	mov	%ax, %ss
	mov	$0xFF00, %sp		# arbitrary value >>512
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
# AH 功能号 = 0x06         AL 显示模式 = 0x01(字符串只包含字符码，显示之后更新光标位置，属性值在BL中)
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
