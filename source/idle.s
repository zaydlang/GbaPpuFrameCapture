.global m_idle_1000_cycles, m_idle_100_cycles, m_idle_10_cycles

.macro m_idle_1000_cycles
    m_idle_100_cycles
    m_idle_100_cycles
    m_idle_100_cycles
    m_idle_100_cycles
    m_idle_100_cycles
    m_idle_100_cycles
    m_idle_100_cycles
    m_idle_100_cycles
    m_idle_100_cycles
    m_idle_100_cycles
.endm

.macro m_idle_100_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
    m_idle_10_cycles
.endm

.macro m_idle_10_cycles
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
.endm