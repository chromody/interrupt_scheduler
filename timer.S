.global     setup_EVT
.global     init_timer
.global     clear_timer
.extern     print_to  


.data
    error_msg:
        .asciz "Error: unsupported exception!"

    .balign 128 //hacky method but it works
    vector_table:
    .balign 128
        b unsupported
    .balign 128
        b dispatch
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b dispatch    // yes
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b dispatch
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b unsupported
    .balign 128
        b dispatch
    .balign 128
        b unsupported
    .balign 128
        b unsupported

setup_EVT:
    adr     x0, vector_table 
    msr     VBAR_EL1, x0        // Set the vector base address
    ret

init_timer:
    stp     x29, x30, [sp, -16]!
    bl      clear_timer
    //route core 0 counter to core 0 irq
    ldr     x0, =0x40000040
    mov     x1, 0x08
    str     w1, [x0]
    // enable timer
    mov     x0, 1
    msr     CNTV_CTL_EL0, x0
    ldp     x29, x30, [sp], 16
    ret

clear_timer: 
    // read count frequency
    mrs     x0, CNTFRQ_EL0
    mov     x1, 20
    udiv    x0, x0, x1
    // clear cntv interrupt and set next 1 sec timer.
    msr     CNTV_TVAL_EL0, x0
    ret    

unsupported: // for errors
    // Load the row (x0 = 0)
    mov     x0, #0
    // Load the column (x1 = 0)
    mov     x1, #0
    // Load the address of the message into x2
    adr     x2, error_msg
    // Call print_to(0, 0, "Error: unsupported exception!")
    bl      print_to

    // Infinite loop
    1:
        b 1b