	.code16
	.equ SETUPSEG, 0x800
	.equ INFOSEG, 0x700
	.equ CR0_PE_ON, 0x1
	.equ PROT_MODE_CSEG, 0x8
	.equ PROT_MODE_DSEG, 0x10

	.global _start, begtext, begdata, begbss, endtext, enddata, endbss
	.text
	begtext:
	.data
	begdata:
	.bss
	begbss:
	.text
_start:
#进入保护模式
    cli
    cld
	lgdt	gdt_48

	inb     $0x92, %al
	orb     $0b00000010, %al
	outb    %al, $0x92

	movl    %cr0, %eax
    orl     $CR0_PE_ON, %eax
    movl    %eax, %cr0

    .equ PRO_START, protcseg+0x8000
	ljmp	$PROT_MODE_CSEG, $PRO_START

  .code32
protcseg:
    movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    movw    %ax, %ds                # -> DS: Data Segment
    movw    %ax, %es                # -> ES: Extra Segment
    movw    %ax, %fs                # -> FS
    movw    %ax, %gs                # -> GS
    movw    %ax, %ss                # -> SS: Stack Segment

    # Set up the stack pointer and call into C.
    movl    $SETUPSEG, %esp
spin:
  jmp spin
gdt:
	.word	0,0,0,0
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
	.word	0x07FF
	.word	0x0000
	.word	0x9A00
	.word	0x00C0
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
	.word	0x07FF
	.word	0x0000
	.word	0x9200
	.word	0x00C0

gdt_48:
	.word	0x800			# gdt limit=2048, 256 GDT entries
	.long   gdt+0x8000		# gdt base = 0X9xxxx,
	# 512+gdt is the real gdt after setup is moved to 0x9020 * 0x10

boot_msg:
	.byte 13,10
	.ascii "Now PixiuOs in setup ..."
	.byte 13,10
boot_msg_end:
cur:
	.ascii "Cursor POS:"
mem:
	.ascii "Memory SIZE:"
cyl:
	.ascii "KB"
	.byte 13,10,13,10
	.ascii "HD Info"
	.byte 13,10
	.ascii "Cylinders:"
head:
	.ascii "Headers:"
sect:
	.ascii "Secotrs:"
    .org 512
.text
endtext:
.data
enddata:
.bss
endbss:
