

ASM=nasm
ASMFlags=-f macho64 

all: link

link: main
	ld -o prog printf.o

main: printf.s
	nasm -f elf64 -l printf.lst printf.s

clear: 
	rm *.o *.lst
