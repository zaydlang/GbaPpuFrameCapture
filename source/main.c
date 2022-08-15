#include <gba_console.h>
#include <gba_video.h>
#include <stdio.h>

#include "shrink.h"

extern int SyncToVcount(int scanline, int (*callback)(void));
extern int TestVram(void);
extern int TestVramFast(void);
extern volatile u32 TestVram_NopSlide[1232];

volatile const char savetype[] = "SRAM_V123";

void fast() {
    SyncToVcount(0, &TestVramFast);

    consoleDemoInit();
    printf("got results. reordering them.\n");

    // TestVramFast stores the results in a very very VERY scuffed way
    // due to the fact that it has to make sure all code paths take the
    // same amount of cycles. it stores the results in EWRAM in this format:

    // Adderss 0 contains results 0, 23, 23 * 2, 23 * 3, ..., 23 * 7
    // Address 1 contains results 23 * 8, ..., 23 * 15
    // Address 2 contains results 23 * 16, ..., 23 * 23

    // the following algorithm rearranges the bits so that theyre stored
    // by cycle, instead of this stupid format.

    int ewram_offset = 0;
    int bit_offset = 7;
    u8 reconstructed_result = 0;

    for (int i = 0; i < 280896; i++) {
        volatile u8* partial_result_address = (volatile u8*) (EWRAM + ewram_offset);
        int partial_result = *(partial_result_address);

        reconstructed_result |= ((partial_result >> bit_offset) & 1) << (7 - (i & 7));

        if ((i & 7) == 7) {
            volatile u8* write_address = (volatile u8*) (EWRAM + (i >> 3) + 0x36000);
            *(write_address) = reconstructed_result;
            reconstructed_result = 0;
        }

        ewram_offset += 16951;
        if (bit_offset >= 5) {
            ewram_offset--;
        }

        if (ewram_offset >= 35112) {
            ewram_offset -= 35112;
        }

        bit_offset += 3;
        if (bit_offset > 7) bit_offset -= 8;  
    }

    // now we compress the results so they can fit in SRAM.

    printf("compressing results... this may take a while\n");

    unsigned int outlength = 0x8000;
    shrink_buffer(CODEC_LZSS, 1, (char*) 0x02036000, 280896 / 8, (char*) 0x0E000000, &outlength);

    if (outlength > 0x8000) {
        printf("ERROR: couldn't compress the data enough to fit it in SRAM.\n");
    } else {
        printf("done. final size: %x", outlength);
    }
}

void slow() {
    for (int i = 0; i < 240 * 4; i++) {
        if (i != 0) TestVram_NopSlide[i - 1] = 0xE320F000; // nop
        TestVram_NopSlide[i] = 0xe12fff14; // bx r4
        int result = SyncToVcount(140, &TestVram) & 0xF;

        int x = i >> 2;
        int y = i & 3;
        int index = x + y * 240;

        volatile u16* vram_pixel = (volatile u16*) (VRAM + index * 2);

        if (result == 3) {
            *(vram_pixel) = 0x00FF;
        } else {
            *(vram_pixel) = 0xFF00;
        }

        volatile u8* sram_addr = (volatile u8*) (SRAM + i);
        *(sram_addr) = result;
    }
}

int main() {
    REG_DISPCNT = MODE_3 | BG2_ENABLE;

    // slow runs a single scanline and takes like 20 seconds to run.
    // fast runs a whole frame and takes 1-2 minutes to run.

    // slow();
    fast();

    while (1);
}