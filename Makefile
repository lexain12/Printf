ASM=nasm

all: link

link: main
	ld -o prog printf.o

asm2c: 
	gcc -c testPrintf.c -o testPrintf.o -O0
	$(ASM) -f elf64 -l printf.lst printf.s -Dself=0 
	gcc -no-pie testPrintf.o printf.o -o test -O0

c2asm: 
	nasm -f elf64 -o CallP.o CallCPrint.s 
	gcc -no-pie -o CallP.out CallP.o

main: printf.s
	$(ASM) -f elf64 -l printf.lst printf.s -Dself=1

clear: 
	rm *.o *.lst
