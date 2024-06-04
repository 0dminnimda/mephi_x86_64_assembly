STB_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image.h
STB_WRITE_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h

O = 0

.PHONY: com
com: stb_image.h stb_image_write.h
	nasm -g -f elf64 process.asm        -o process_asm.obj
	nasm -g -f elf64 process.asm -d SSE -o process_asm_sse.obj
	clang -c process.c -O$(O)        -o process_c.obj
	clang -c process.c -O$(O) -D SSE -o process_c_sse.obj
	clang main.c process_asm.obj process_asm_sse.obj process_c.obj process_c_sse.obj \
		-o main.out -O$(O) -lm -no-pie -D OPTIMIZATION_OPTION=\"$(O)\"

stb_image.h:
	curl -o stb_image.h -L $(STB_URL)

stb_image_write.h:
	curl -o stb_image_write.h -L $(STB_WRITE_URL)

.PHONY: test
test:
	# burner, to warmed up cache
	./main.out resources/cat_wow.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 1 1 1279 959 3000 > /dev/null

	./main.out resources/cat_wow.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 506 501 600 594 100000
	./main.out resources/cat_wow.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 400 400 600 800 100000
	./main.out resources/cat_wow.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 103 51 923 892 100000
	./main.out resources/cat_wow.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 1 1 1279 959 100000

	./main.out resources/cat_yum.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 203 301 283 412 100000
	./main.out resources/cat_yum.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 400 400 600 800 100000
	./main.out resources/cat_yum.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 103 51 701 1040 100000
	./main.out resources/cat_yum.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 1 1 719 1279 100000

	./main.out resources/boat.512.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 203 301 283 412 100000
	./main.out resources/boat.512.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 300 300 400 500 100000
	./main.out resources/boat.512.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 103 51 400 450 100000
	./main.out resources/boat.512.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 1 1 511 511 100000

	./main.out resources/4.1.01.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 103 1 183 112 100000
	./main.out resources/4.1.01.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 100 100 150 200 100000
	./main.out resources/4.1.01.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 103 51 200 200 100000
	./main.out resources/4.1.01.png output/c.png output/c_sse.png output/asm.png output/asm_sse.png 1 1 255 255 100000


clean:
	rm main.out stb_image.h stb_image_write.h
