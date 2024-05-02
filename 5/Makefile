STB_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image.h
STB_WRITE_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h

.PHONY: com
com: stb_image.h stb_image_write.h
	fasm process.asm process.obj
	clang main.c process.obj -o main.out -lm -no-pie # -D PROCESSING_IMPLEMENTATION

stb_image.h:
	curl -o stb_image.h -L $(STB_URL)

stb_image_write.h:
	curl -o stb_image_write.h -L $(STB_WRITE_URL)

.PHONY: clean
clean:
	rm -f $(PROGRAM_NAME) stb_image.h stb_image_write.h
