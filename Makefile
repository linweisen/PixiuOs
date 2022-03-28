
Image: boot/header.o
	@tools/build.sh boot/bootsect boot/setup tools/kernel Image $(ROOT_DEV)
	@sync

boot/header.o: boot/header.S
	@make header.o -C boot/