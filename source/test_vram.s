#include "idle.s"

.align 2
.section .iwram,"ax",%progbits
.arm

.global TestVram, TestVram_NopSlide, TestVramFast

TestVram:
    @ we have 19 cycles to set up any useful stuff we want before VCOUNT increments.
    mov r0, #0x06000000           @ 1 cycles
    mov r1, #0x04000000           @ 1 cycles
    mov r2, #0x800000             @ 1 cycles
    mov r3, #0                    @ 1 cycle
    ldr r4, =TestVram_PerformTest @ 3 cycles
    b TestVram_SkipLiteralPool    @ 3 cycles

    @ skip the literal pool
.ltorg

TestVram_SkipLiteralPool:
    str r3, [r1, #0x100]
    nop

    @ in 6 cycles, VCOUNT will have incremented once.
    @ we will insert a nop slide here with 1232 nops.
    @ main.c will, one by one, replace each nop with a
    @ bx r4 to perform the test. this bx will take
    @ exactly 3 cycles, meaning we then have 3 more
    @ cycles before the targetted cycle occurs. conveniently,
    @ the strh to start the timer takes 2 cycles, and
    @ the ldr from VRAM that follows it will perform
    @ the read after 1 cycle.

TestVram_NopSlide:
    m_idle_1000_cycles
    m_idle_100_cycles
    m_idle_100_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    nop
    nop
    bx lr

.ltorg

TestVram_PerformTest:
    str r2, [r1, #0x100] @ 2 cycles
    ldrb r0, [r0]  @ 1 cycle until the read from VRAM occurs
    ldr r0, [r1, #0x100]

    bx lr

TestVramFast:
    push {r5, r6, r7, r8} @ 4 cycles

    @ we have 19 cycles to set up any useful stuff we want before VCOUNT increments.
    mov r0,  #0x06000000           @ 1 cycles
    mov r1,  #0x04000000           @ 1 cycles
    mov r2,  #0x800000             @ 1 cycles
    mov r3,  #0                    @ 1 cycle
    mov r4,  #0x02000000           @ 1 cycle
    ldr r6, =#280896               @ 3 cycles
    mov r7,  #0                    @ 1 cycle
    mov r8,  #0                    @ 1 cycle

    add r0, #0x10000               @ 1 cycle

    @ 29 cycle loop:
    TestVramFast_Loop:
        @ stop/start timer
        str r2, [r1, #0x100]  @ 2 cycles
        
        @ load from VRAM (perform the test)
        ldrb r5, [r0]         @ 3 cycles (1 till read occurs)
        
        @ load the timer value (the test result)
        ldrb r5, [r1, #0x100] @ 3 cycles

        @ if we didn't idle an extra cycle when loading from VRAM, then
        @ we need to idle another cycle here to keep the loop times
        @ consistent.

        @ TODO: what to do if we idle more than one extra cycle?
        @ we could just keep idling extra cycles to compensate, but
        @ whats the most amount of cycles we theoretically could idle?
        cmp r5, #3            @ 1 cycle
        streq r3, [r3]        @ 2 cycles when taken, 1 cycle if not taken

        @ r7 is the loop counter, increment it.
        add r7, #1            @ 1 cycle
        
        @ pack timer value into one byte
        cmp r5, #3            @ 1 cycle
        moveq r5, #0          @ 1 cycle
        movne r5, #1          @ 1 cycle
        lsl r8, #1            @ 1 cycle
        orr r8, r5            @ 1 cycle

        @ if a byte is full, increment r4
        strb r8, [r4]         @ 3 cycles
        tst r7, #7            @ 1 cycle
        addeq r4, #1          @ 1 cycle

        @ clear the timer
        str r3, [r1, #0x100]  @ 2 cycles
        
        @ loop
        cmp r7, r6            @ 1 cycle
        bne TestVramFast_Loop @ 3 cycle

    pop {r5, r6, r7, r8}
    bx lr

.ltorg