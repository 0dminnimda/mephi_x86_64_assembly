prep_executable = $(eval $(1) := $(shell bash ../prep_exec.sh $(2)))

EXE_NAME = main.out

ifdef PRINT_STEPS
	FLAGS = -d PRINT_STEPS=1
else
	FLAGS =
endif

.PHONY: com
com:
	fasm main.asm main.obj $(FLAGS)
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o $(EXE_NAME) -lc -lm main.obj

.PHONY: com_dr
com_dr:
	# qemu-x86_64 ~/fasm.x64 main.asm main.o
	fasm main.asm main.o
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o main.out -lc main.o
	# qemu-x86_64 ld main.o -dynamic-linker /lib/ld-linux.so.2 -lc
	# qemu-x86_64 ld main.o -dynamic-linker /lib/ld-linux.so.2 -lc
	# qemu-x86_64 ~/fasm.x64 main.asm $(EXE_NAME)

.PHONY: run
run:
	$(call prep_executable, EXEC, $(EXE_NAME))
	qemu-x86_64 $(EXEC)

.PHONY: test
test:
	printf "2.5\n1e-3" | ./$(EXE_NAME)
	#
	printf "2.5\n-1e-3" | ./$(EXE_NAME)
	#
	printf " -2.5\n1e-3" | ./$(EXE_NAME)
	#
	printf " -2.5\n-1e-3" | ./$(EXE_NAME)
