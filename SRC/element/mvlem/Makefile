include ../../../Makefile.def

OBJS       = MVLEM.o \
	SFI_MVLEM.o \
	FourNodeMVLEM3D.o \
	FourNodeSFI_MVLEM3D.o \
	TclFourNodeMVLEM3DCommand.o \
	TclFourNodeSFI_MVLEM3DCommand.o


all:         $(OBJS)

# Miscellaneous
tidy:	
	@$(RM) $(RMFLAGS) Makefile.bak *~ #*# core

clean: tidy
	@$(RM) $(RMFLAGS) $(OBJS) *.o

spotless: clean

wipe: spotless

# DO NOT DELETE THIS LINE -- make depend depends on it.
