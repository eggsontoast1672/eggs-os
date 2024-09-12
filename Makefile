all: stupid.img

bootloader.bin: src/bootloader/main.asm
	nasm -o $(@) $(<)

kernel.bin: src/kernel/main.asm
	nasm -o $(@) $(<)

stupid.img: bootloader.bin kernel.bin
	dd if=/dev/zero of=$(@) bs=512 count=2880
	mkfs.fat -F 12 -n NBOS $(@)
	dd if=bootloader.bin of=$(@) conv=notrunc
	mcopy -i $(@) kernel.bin ::kernel.bin

clean:
	rm -f bootloader.bin kernel.bin stupid.img

run: all
	qemu-system-i386 -fda stupid.img

.PHONY: clean run
