

ASM=nasm
ASMFlags=-f macho64 

all: link

link: main
	ld -macosx_version_min 12.6.0 -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib -lSystem -o prog printf.o

main: printf.s
	nasm -f macho64 -l printf.lst printf.s

clear: 
	rm *.o *.lst
