ASM=nasm

all: link

link: main
	ld -o prog printf.o

asm2c: main testC
	gcc -no-pie testPrintf.o printf.o -o test


main: printf.s
	$(ASM) -f elf64 -l printf.lst printf.s

testC: testPrintf.c
	gcc -c testPrintf.c -o testPrintf.o

clear: 
	rm *.o *.lst
