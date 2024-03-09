ifdef REVERSED
	FLAGS = -d REVERSED=1
else
	FLAGS =
endif

.PHONY: compile
compile:
	fasm main.asm main.out $(FLAGS)

.PHONY: debug
debug:
	gdb ./main.out --eval-command="display/i $pc"
