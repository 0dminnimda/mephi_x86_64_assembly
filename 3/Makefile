EXE_NAME = main.out

prep_executable = $(eval $(1) := $(shell bash ../prep_exec.sh $(2)))

N = 0

.PHONY: com
com:
	qemu-x86_64 ~/fasm.x64 main.asm $(EXE_NAME)

.PHONY: run
run:
	$(call prep_executable, EXEC, $(EXE_NAME))
	qemu-x86_64 -E N=$(N) $(EXEC)

