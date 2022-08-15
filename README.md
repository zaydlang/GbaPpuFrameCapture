# What this is

This rom performs an access to VRAM on every cycle of a frame, and reports whether or not each cycle idled an extra cycle or not. This can be used to investigate the inner workings of the PPU.

# How it works

First, you need to compile the rom. You can configure two things:
- modify main.c to configure the PPU however you want (different ppu modes, sprites, etc)
- modify test_vram.s/TestVramFast. r0 will be the address that will be read from on each cycle, so you can change it to have whatever address you want. just make sure that your changes don't add or remove any cycles to the total operation.

Once you run it the rom, put the resulting save file in the `interp` folder, and name it `results.sav`. make and run the C program in there, and it will generate a map that shows you where the idles occurred. 0 = no idle, 1 = idle, left = start of scanline, right = end of scanline. It will also create a `decompressed-results.sav` which contains this information in binary form in case you want to use the data to visualize things or whatever.

There's also a python script in `interp` to visualize the result data but it doesn't work. Might fix it later.