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

clean:
	rm main.out stb_image.h stb_image_write.h
