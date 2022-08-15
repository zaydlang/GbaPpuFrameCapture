#include "idle.s"

.align 2
.section .iwram,"ax",%progbits
.arm

.global SyncToVcount

.macro m_idle_130_cycles
    m_idle_100_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
.endm

SyncToVcount:
    push {r5}

    @ we're gonna sync to the scanline before the one that was passed in
    subs r3, r0, #1
    movmi r3, #227
    
    mov r5, r1 @ r1 is where the callback is stored for later

    @ okay so the algorithm is kinda odd so here's an explanation: VCOUNT will
    @ increment every 1232 cycles. we want to enter the callback on the exact
    @ cycle that VCOUNT increments. if we have a loop that reads VCOUNT every
    @ 137 cycles, then this loop will be able to read VCOUNT on average 9 times
    @ before it increments (9 * 137 = 1233). however, depending on this loop's
    @ alignment with the PPU, the loop may be able to read VCOUNT 8 times
    @ instead. this can only happen if the loop's first VCOUNT read occurred
    @ on the cycle directly after VCOUNT increments. once that happens, we know
    @ the CPU's alignment with the PPU, and the rest is easy.

    @ first - wait until VCOUNT increments, so we can align ourselves with the
    @ start of the incrementing.
    mov r0, #0x4000000 @ put VCOUNT into r0
    add r0, #6

    ldrh r1, [r0] @ we will wait till we read a value that is not r1

    SyncToVcount_WaitForFirstIncrement:
        ldrh r2, [r0]
        cmp r2, r1
        beq SyncToVcount_WaitForFirstIncrement

    ldrh r1, [r0]

    @ now we have to wait till the 8th VCOUNT read is different from the initial read
    SyncToVcount_MainLoop:
        m_idle_130_cycles
        ldrh r2, [r0] @ 3 cycles
        cmp r2, r1    @ 1 cycle
        bne SyncToVcount_MainLoop @ 1 cycle when no branch
        mov r1, r2    @ 1 cycle
        nop

        m_idle_130_cycles
        ldrh r2, [r0] @ 3 cycles
        cmp r2, r1    @ 1 cycle
        bne SyncToVcount_MainLoop @ 1 cycle when no branch
        mov r1, r2    @ 1 cycle
        nop
        
        m_idle_130_cycles
        ldrh r2, [r0] @ 3 cycles
        cmp r2, r1    @ 1 cycle
        bne SyncToVcount_MainLoop @ 1 cycle when no branch
        mov r1, r2    @ 1 cycle
        nop
        
        m_idle_130_cycles
        ldrh r2, [r0] @ 3 cycles
        cmp r2, r1    @ 1 cycle
        bne SyncToVcount_MainLoop @ 1 cycle when no branch
        mov r1, r2    @ 1 cycle
        nop
        
        m_idle_130_cycles
        ldrh r2, [r0] @ 3 cycles
        cmp r2, r1    @ 1 cycle
        bne SyncToVcount_MainLoop @ 1 cycle when no branch
        mov r1, r2    @ 1 cycle
        nop
        
        m_idle_130_cycles
        ldrh r2, [r0] @ 3 cycles
        cmp r2, r1    @ 1 cycle
        bne SyncToVcount_MainLoop @ 1 cycle when no branch
        mov r1, r2    @ 1 cycle
        nop
        
        m_idle_130_cycles
        ldrh r2, [r0] @ 3 cycles
        cmp r2, r1    @ 1 cycle
        bne SyncToVcount_MainLoop @ 1 cycle when no branch
        mov r1, r2    @ 1 cycle
        nop
        
        m_idle_130_cycles
        ldrh r2, [r0] @ 3 cycles
        cmp r2, r1    @ 1 cycle
        bne SyncToVcount_WaitForSelectedScanline @ 1 cycle when no branch
        mov r1, r2    @ 1 cycle
        nop

        m_idle_130_cycles
        ldrh r2, [r0] @ 3 cycles
        mov r1, r2    @ 1 cycle
        b SyncToVcount_MainLoop @ 1 cycle when no branch
    
    SyncToVcount_WaitForSelectedScanline:
        @ we should be two cycles into the next scanline
        @ now we can wait for VCOUNT to equal r3
        m_idle_1000_cycles
        m_idle_100_cycles
        m_idle_100_cycles
        
        moveq r1, r5
        popeq {r5}
        bxeq r1

        m_idle_10_cycles
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop

        ldrh r1, [r0] @ 3 cycles
        cmp r1, r3 @ 1 cycle
        b SyncToVcount_WaitForSelectedScanline @ 3 cycles when branch
