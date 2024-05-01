STB_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image.h
STB_WRITE_URL = https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h

.PHONY: com
com: stb_image.h stb_image_write.h
	fasm asm_impl.asm asm_impl.obj
	# clang 

stb_image.h:
	wget -O stb_image.h $(STB_URL)

stb_image_write.h:
	wget -O stb_image_write.h $(STB_WRITE_URL)

clean:
	rm -f $(PROGRAM_NAME) stb_image.h stb_image_write.h
