#include "../source/shrink.h"

#include "stdio.h"
#include <stdlib.h>

unsigned int count_set_bits(unsigned int n)
{
    unsigned int count = 0;
    while (n) {
        count += n & 1;
        n >>= 1;
    }
    return count;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("use like this:\n ./interpret <file> <compressed_size (hex, w/o the leading 0x)>");
        return -1;
    }

    char* file_name = argv[1];
    int compressed_len = strtol(argv[2], NULL, 16);
    printf("%s %x\n", file_name, compressed_len);

    FILE *fileptr;
    char *buffer;
    long filelen;

    char* result = (char*) malloc(280896 / 8 * sizeof(char));

    fileptr = fopen(file_name, "rb");
    buffer = (char *)malloc(0x8000 * sizeof(char));
    fread(buffer, 0x8000, 1, fileptr);
    fclose(fileptr);

    long unsigned int outlength = 280896 / 8;
    shrink_buffer(CODEC_LZSS, 0, buffer, compressed_len, result, &outlength);

    if (outlength != 280896 / 8) {
        printf("output length: %d (supposed to be %d)\n", outlength, 280896 / 8);
        return -1;
    }

    for (int scanline = 0; scanline < 228; scanline++) {
        printf("scanline %d:\n", scanline);
        int set_bits = 0;
        for (int i = 0; i < 1232 / 8; i++) {
            // looks ugly but whatever
            printf("%d%d%d%d%d%d%d%d", 
                (result[scanline * (1232 / 8) + i] >> 7) & 1,
                (result[scanline * (1232 / 8) + i] >> 6) & 1,
                (result[scanline * (1232 / 8) + i] >> 5) & 1,
                (result[scanline * (1232 / 8) + i] >> 4) & 1,
                (result[scanline * (1232 / 8) + i] >> 3) & 1,
                (result[scanline * (1232 / 8) + i] >> 2) & 1,
                (result[scanline * (1232 / 8) + i] >> 1) & 1,
                (result[scanline * (1232 / 8) + i] >> 0) & 1
            );
            set_bits += count_set_bits(result[scanline * (1232 / 8) + i]);

        }
        printf("\n^ num set bits: %d", set_bits);
        printf("\n");
    }

    fileptr = fopen("decompressed-results.sav", "wb");
    printf("%d\n", fileptr);
    fwrite(result, 1, 280896 / 8, fileptr);
}

