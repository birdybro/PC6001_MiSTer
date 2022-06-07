#
#
#

AS		= z80as
ASFLAGS	= -cpu z80 -L
P2B		= p2bin
P2H		= p2hex
SOURCE	= ctrlrom.asm

$(SOURCE:.asm=.p):$(SOURCE)
	$(AS) $(ASFLAGS) $(SOURCE)
	$(P2H) $(SOURCE:.asm=.p)  -l 16 -r 0x0000-0x3FFF $(SOURCE:.asm=.hex)
	cp $(SOURCE:.asm=.hex) ../src

clean:
	rm *.P *.MAP *.LST
