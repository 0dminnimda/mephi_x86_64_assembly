#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <errno.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

typedef unsigned int uint;

void process(unsigned char *input, uint width, uint height, uint channels, unsigned char *output, uint new_width, uint new_height);

#ifdef PROCESSING_IMPLEMENTATION
void process(unsigned char *input, uint width, uint height, uint channels, unsigned char *output, uint new_width, uint new_height) {
    double x_ratio = (double)width / new_width;
    double y_ratio = (double)height / new_height;

    output += new_height * new_width * channels;

    for (long y = new_height - 1; y >= 0; --y) {
        uint input_y = (uint)((double)y * y_ratio);

        for (long x = new_width - 1; x >= 0; --x) {
            uint input_x = (uint)((double)x * x_ratio);

            unsigned char *part_input = input + (input_y * width + input_x + 1) * channels;

            for (short c = channels - 1; c >= 0; --c) {
                *(--output) = *(--part_input);
            }
        }
    }
}

#endif


bool parse_uint(char *str, uint *result) {
    char *endptr = NULL;

    long value = strtol(str, &endptr, 10);

    if (endptr == str) {
        fprintf(stderr, "Not an integer\n");
        return false;
    }
    if (*endptr != '\0') {
        fprintf(stderr, "Non-digit characters found after the number\n");
        return false;
    }
    if (errno == ERANGE) {
        fprintf(stderr, "The number is out of range for a unsigned int\n");
        return false;
    }
    if (value > UINT_MAX || value < 0) {
        fprintf(stderr, "The number is out of range for an unsigned int\n");
        return false;
    }

    *result = (int)value;
    return true;
}


int main(int argc, char **argv) {
    if (argc < 5) {
        printf("Usage: %s <input.jpg> <output.jpg> <new_width> <new_height>\n", argv[0]);
        return 1;
    }

    uint new_width, new_height;
    if (!parse_uint(argv[3], &new_width)) {
        fprintf(stderr, "Invalid width\n");
        return 1;
    }
    if (!parse_uint(argv[4], &new_height)) {
        fprintf(stderr, "Invalid height\n");
        return 1;
    }
    printf("Got new width: %u, new height: %u\n", new_width, new_height);

    int width, height, channels;
    unsigned char *img = stbi_load(argv[1], &width, &height, &channels, 0);
    if (img == NULL) {
        printf("Error loading image\n");
        return 1;
    }
    printf("Loaded image '%s', width: %d, height: %d, channels: %d\n", argv[1], width, height, channels);

    unsigned char *result_img = (unsigned char *)malloc(new_width * new_height * channels * sizeof(char));

    process(img, width, height, channels, result_img, new_width, new_height);

    stbi_write_jpg(argv[2], new_width, new_height, channels, result_img, 100);
    printf("Written image '%s', width: %d, height: %d, channels: %d\n", argv[2], new_width, new_height, channels);

    stbi_image_free(img);
    free(result_img);

    return 0;
}
