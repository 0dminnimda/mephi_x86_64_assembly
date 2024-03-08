.PHONY: compile
compile:
	fasm main.asm main.out

.PHONY: debug
debug:
	gdb ./main.out --eval-command="display/i $pc"
