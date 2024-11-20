.global dispatch
.global go

.extern ReadyQ
.extern Running
dispatch:
    /* 
        Stack layout:
        x0
        x2
        ...
        x28
        x29
        x30
        PSTATE
        Exception return address
    */

    msr     DAIFSet, #0x2

    str x1, [sp] // Save x1 Temporarily so we can use it to reference the process stack
    
    MRS     x1, SP_EL0 // Load the process stack pointer  

    sub     x1, x1, 16*17               // Make room for the process context



    // Save the proces general purpose registers

    stp	    x0, x1, [x1] //    Store the process's x0 and x1 onto process stack
    stp     x2, x3, [x1, 16]
    stp     x4, x5, [x1, 16*2]
    stp     x6, x7, [x1, 16*3]
    stp     x8, x9, [x1, 16*4]
    stp     x10, x11, [x1, 16*5]
    stp     x12, x13, [x1, 16*6]
    stp     x14, x15, [x1, 16*7]
    stp     x16, x17, [x1, 16*8]
    stp     x18, x19, [x1, 16*9]
    stp     x20, x21, [x1, 16*10]
    stp     x22, x23, [x1, 16*11]
    stp     x24, x25, [x1, 16*12]
    stp     x26, x27, [x1, 16*13]
    stp     x28, x29, [x1, 16*14]
    str     x30, [x1, 16*15]

    mrs     x0, SPSR_EL1            // Save the process PSTATE
    str     x0, [sp, 16*15+8]

    mrs     x0, ELR_EL1
    str     x0, [x1, 16*16]

    //TODO:
    //	Save the value of x1 into the process's PCB 
    str x0, [x1, 0] 
    str x1, [x1, 8]

    // Enqueue the current process to the ready Q (call enqueue) 
    adr     x0, ReadyQ              // enqueue takes a pointer to the queue and 
    adr     x4, Running             //    a pointer to a PCB
    ldr     x4, [x4]                // put the first value in the PCB (the stack pointer) into x1 
    mov     x1, sp
    str     x1, [x4]                //    Then store the new top of stack that is now in x4 to the PCB 
    mov     x1, x4                  // Note: the first element in the pcb is the top of stack
    bl      enqueue                 // Put the current processes PCB into the ready Q

 restore_context:
    // Dequeue the next process to run
    adr     x0, ReadyQ              // dequeue has one argument, the address of the ready Q
    bl      dequeue                 // call dequeue, x0 will have a ptr to the returned PCB
    adr     x1, Running             // We need to set the returned PCB as "running"
    str     x0, [x1]                // store the pointer to the PCB into the Running variable
    ldr     x2, [x0]                // x1 now has the value of the stack ptr (we cant ldr sp directly) //x0 holds the stack pointer of the pcb
    //FIGURE OUT:
    mov	    sp, x2 //x1? doesnt x2 have it?

    ldr     x0, [sp, 16*15+8]   // Restore PSTATE
    msr     SPSR_EL1, x0

    ldr     x0, [x1, 16*16]   // Restore interrupt return address	
  	msr     ELR_EL1, x0
    //   Note: When the handler returns via
    //   eret, this will be the value of sp

    /*
    Store the new top of stack into the
    System exception register for EL0
    */
    mov     x0, x1           
    add     x0, x0, 16*17    
    MSR     SP_EL0, x0

    /*

    Restore process registers x2...x29, 	// but do not restore x0,x1 just yet
    										//   we are going to use them
       										// Also, do not yet restore x29 and x30
                                           //   we will make a function call, which
                                           //   can wipe them out
   											// Hint: start like so: 
                                           //   ldp     x2, x3, [x1, 16]

    */

    ldp     x2, x3, [x1, 16]         // Restore x2, x3
    ldp     x4, x5, [x1, 16*2]       // Restore x4, x5
    ldp     x6, x7, [x1, 16*3]       // Restore x6, x7
    ldp     x8, x9, [x1, 16*4]       // Restore x8, x9
    ldp     x10, x11, [x1, 16*5]     // Restore x10, x11
    ldp     x12, x13, [x1, 16*6]     // Restore x12, x13
    ldp     x14, x15, [x1, 16*7]     // Restore x14, x15
    ldp     x16, x17, [x1, 16*8]     // Restore x16, x17
    ldp     x18, x19, [x1, 16*9]     // Restore x18, x19
    ldp     x20, x21, [x1, 16*10]    // Restore x20, x21
    ldp     x22, x23, [x1, 16*11]    // Restore x22, x23
    ldp     x24, x25, [x1, 16*12]    // Restore x24, x25
    ldp     x26, x27, [x1, 16*13]    // Restore x26, x27
    //ldr     x28, [x1, 16*14]         // Restore x28

    /*
    // clear counter and reset the timer.
    // This is easy...
    temporarity save x0 and x1
    call clear_timer			// code is given for clear_timer above 
    restore x0 and x1
    */

    //FIGURE OUT:
    //is this how we save and restore x0, x1
    sub sp, sp, 16
    stp x0, x1, [sp]

    bl clear_timer

    ldp x0, x1, [sp]
    add sp, sp, 16

    ldp     x28, x29, [x1, 16*14]    // Restore x26, x27
    ldr     x30, [x1, 16*15]

    //FIGURE OUT:
    //	restore x0 and x1			    
    ldp     x0, x1, [x1]         // ????????

    msr     DAIFClr, #0x2

    eret
 
 go:
    // Dequeue the next process to run
    adr     x0, ReadyQ              // dequeue has one argument, the address of the ready Q
    bl      dequeue                 // call dequeue, x0 will have a ptr to the returned PCB
    adr     x1, Running             // We need to set the returned PCB as "running"
    str     x0, [x1]                // store the pointer to the PCB into the Running variable
    ldr     x1, [x0]                // x1 now has the value of the stack ptr (we cant ldr sp directly)
    mov	    sp, x1
    
    ldr     x0, [sp, 16*15+8]   // Restore PSTATE
    msr     SPSR_EL1, x0

    // retore process context
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, 16]
    ldp     x4, x5, [sp, 16*2]
    ldp     x6, x7, [sp, 16*3]
    ldp     x8, x9, [sp, 16*4]
    ldp     x10, x11, [sp, 16*5]
    ldp     x12, x13, [sp, 16*6]
    ldp     x14, x15, [sp, 16*7]
    ldp     x16, x17, [sp, 16*8]
    ldp     x18, x19, [sp, 16*9]
    ldp     x20, x21, [sp, 16*10]
    ldp     x22, x23, [sp, 16*11]
    ldp     x24, x25, [sp, 16*12]
    ldp     x26, x27, [sp, 16*13]
    ldp     x28, x29, [sp, 16*14]
    ldr     x30, [sp, 16*15]
    add	    sp, sp, 16*16

    ret
