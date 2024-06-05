#include <stdint.h>

#ifdef SSE

void process_c(
    unsigned char *src, unsigned char *dst, int original_width, int x_offset, int y_offset, int width, int height
) {
    src += (original_width * y_offset + x_offset) * 4;
    for (int i = height; i != 0; --i) {
        unsigned char *src_prev = src;
        for (int j = width; j != 0; --j) {
            *((uint32_t *)dst) = *((uint32_t *)src);
            dst += 4;
            src += 4;
        }
        src = src_prev + original_width * 4;
    }
}

#else

#include <immintrin.h>

void process_c_sse(unsigned char *src, unsigned char *dst, int original_width, int x_offset, int y_offset, int width, int height) {
    src += (original_width * y_offset + x_offset) * 4;

    int width_div = width / 4;
    int width_mod = width % 4;
    for (int i = height; i != 0; --i) {
        unsigned char *src_prev = src;
        for (int j = width_div; j != 0; --j) {
            _mm_storeu_si128((__m128i*)dst, _mm_loadu_si128((__m128i*)src));
            dst += 16;
            src += 16;
        }
        for (int j = width_mod; j != 0; --j) {
            *((uint32_t *)dst) = *((uint32_t *)src);
            dst += 4;
            src += 4;
        }
        src = src_prev + original_width * 4;
    }
}
#endif
