#include "stdio.h"
extern void VitPrintf(const char*, ...);

int main()
{
	VitPrintf ("%d %s %x %d%%%c%b\n", -1, "Love", 3802, 100, 33, 127);
	VitPrintf ("%b\n", 127);
	VitPrintf ("%d\n", 127);
	VitPrintf ("it is just my %d st %s, %x, %b, %o, %c%c%%%g%m%L\n", 1, "test", 16, 16, 16, '!', '!');
}
