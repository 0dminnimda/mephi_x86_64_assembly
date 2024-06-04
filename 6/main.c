#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define STBI_ONLY_PNG

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

struct timespec timespec_sub(struct timespec t2, struct timespec t1) {
    struct timespec result;
    result.tv_sec = t2.tv_sec - t1.tv_sec;
    result.tv_nsec = t2.tv_nsec - t1.tv_nsec;

    if (result.tv_nsec < 0) {
        result.tv_sec--;
        result.tv_nsec += 1000000000;
    }

    return result;
}

struct timespec timespec_add(struct timespec t1, struct timespec t2) {
    struct timespec result;
    result.tv_sec = t1.tv_sec + t2.tv_sec;
    result.tv_nsec = t1.tv_nsec + t2.tv_nsec;

    if (result.tv_nsec >= 1000000000) {
        result.tv_sec++;
        result.tv_nsec -= 1000000000;
    }
    
    return result;
}

#define TIMESPEC_FORMAT "%lld.%09ld"
#define TIMESPEC_FORM(t) ((long long)((t).tv_sec)), ((t).tv_nsec)

#ifndef OPTIMIZATION_OPTION
#define OPTIMIZATION_OPTION "0"
#endif

typedef void process_fn(unsigned char *src, unsigned char *dst, int original_width, int x_offset, int y_offset, int width, int height);

process_fn process_c, process_c_sse, process_asm, process_asm_sse;

struct timespec time_it(process_fn func, int max_iter, unsigned char *src, unsigned char *dst, int original_width, int x_offset, int y_offset, int width, int height, int channels) {
    struct timespec result = {0}, t1 = {0}, t2 = {0};
    memset(dst, 0, height * width * channels);
    for (int i = 0; i < max_iter; i++) {
        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
        func(src, dst, original_width, x_offset, y_offset, width, height);
        clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
        result = timespec_add(result, timespec_sub(t2, t1));
    }
    return result;
}

int main(int argc, char *argv[]) {
    if (argc < 10 || argc > 11) {
        printf("Usage: %s <input.png> <c_result.png> <c_sse_result.png> <asm_result.png> "
               "<asm_sse_result.png> <x1_new> <y1_new> <x2_new> <y2_new> [<iterations>]\n", argv[0]);
        return 1;
    }

    unsigned char *old_image = NULL;
    int original_width = 0, original_height = 0, channels = 0;
    if ((old_image = stbi_load(argv[1], &original_width, &original_height, &channels, 4)) == NULL) {
        fprintf(stderr, "Error loading '%s'\n", argv[1]);
        return 1;
    }
    printf("Image loaded: %d*%d pixels, %d channels\n", original_width, original_height, channels);

    int x1 = atoi(argv[6]);
    int y1 = atoi(argv[7]);
    int x2 = atoi(argv[8]);
    int y2 = atoi(argv[9]);
    if ((x1 < 0) || (y1 < 0) || (x2 < 0) || (y2 < 0)) {
        fprintf(stderr, "Error: not correct cordinates\n");
        return 1;
    }

    int x_offset = 0, width = 0;
    if (x1 >= x2) {
        width = x1 - x2;
        x_offset = x2;
    } else {
        width = x2 - x1;
        x_offset = x1;
    }

    int y_offset = 0, height = 0;
    if (y1 >= y2) {
        height = y1 - y2;
        y_offset = y2;
    } else {
        height = y2 - y1;
        y_offset = y1;
    }

    printf("Cropping from %d to %d+%d by x and from %d to %d+%d by y \n", x_offset, x_offset, width, y_offset, y_offset, height);

    if (channels < 4) {
        fprintf(stderr, "Image should have 4 (rgb + alpha) channels.\n");
        stbi_image_free(old_image);
        return 1;
    }
    channels = 4;

    unsigned char *new_image = NULL;
    if ((new_image = malloc(height * width * channels)) == NULL) {
        fprintf(stderr, "Can't allocate memory for image\n");
        stbi_image_free(old_image);
        return 1;
    }

    int max_iter = 80000;
    if (argc >= 11) {
        max_iter = atoi(argv[10]);
    }

    printf("timing with %d iterations:\n", max_iter);

    struct timespec c_time = time_it(process_c, max_iter, old_image, new_image, original_width, x_offset, y_offset, width, height, channels);
    if (stbi_write_png(argv[2], width, height, channels, new_image, width * channels) == 0)
        printf("Cannot write '%s' to file\n", argv[2]);
    printf("c -O%s: " TIMESPEC_FORMAT "\n", OPTIMIZATION_OPTION, TIMESPEC_FORM(c_time));

    struct timespec c_sse_time = time_it(process_c_sse, max_iter, old_image, new_image, original_width, x_offset, y_offset, width, height, channels);
    if (stbi_write_png(argv[3], width, height, channels, new_image, width * channels) == 0)
        printf("Cannot write '%s' to file\n", argv[3]);
    printf("c sse -O%s: " TIMESPEC_FORMAT "\n", OPTIMIZATION_OPTION, TIMESPEC_FORM(c_sse_time));

    struct timespec asm_time = time_it(process_asm, max_iter, old_image, new_image, original_width, x_offset, y_offset, width, height, channels);
    if (stbi_write_png(argv[4], width, height, channels, new_image, width * channels) == 0)
        printf("Cannot write '%s' to file\n", argv[4]);
    printf("asm: " TIMESPEC_FORMAT "\n", TIMESPEC_FORM(asm_time));

    struct timespec asm_sse_time = time_it(process_asm_sse, max_iter, old_image, new_image, original_width, x_offset, y_offset, width, height, channels);
    if (stbi_write_png(argv[5], width, height, channels, new_image, width * channels) == 0)
        printf("Cannot write '%s' to file\n", argv[5]);
    printf("asm sse: " TIMESPEC_FORMAT "\n", TIMESPEC_FORM(asm_sse_time));

    stbi_image_free(old_image);
    free(new_image);
    return 0;
}
