STB_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image.h
STB_WRITE_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h

.PHONY: com
com: stb_image.h stb_image_write.h
	# fasm asm_impl.asm asm_impl.obj
	clang main.c -o main.out -D PROCESSING_IMPLEMENTATION

stb_image.h:
	curl -o stb_image.h -L $(STB_URL)

stb_image_write.h:
	curl -o stb_image_write.h -L $(STB_WRITE_URL)

clean:
	rm -f $(PROGRAM_NAME) stb_image.h stb_image_write.h
