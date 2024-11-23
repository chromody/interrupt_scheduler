/*
    Author: Jesus Villanueva-Segovia (with psuedo code and arm-os-coop of Dr. ROgers)
    Class: CSC 4100, 001
    Professor: Dr. Rogers
    Date: 11/23/2024
*/

#include "libos.h"
#include "process.h"
#include <stdbool.h>

int box(unsigned int sr, unsigned int sc, unsigned int er, unsigned int ec);
void clear_src(unsigned int startRow, unsigned int startColumn, unsigned int endRow, unsigned int endColumn); //Prototype to clear at a ordered pair, defined in libos.a
int p1();
int p2();
int p3(); 
int p4();

void go();
void dispatch();
void setup_EVT();
void init_timer();
void enable_interrupts();
void disable_interrupts();
int get_el();
int main(void) {

    clear_src(0, 0, term_txtheight(), term_txtwidth()); // clearing the section that we draw in
 
    create_process(p1); //creating processes
    create_process(p2);
    create_process(p3);
    create_process(p4);

    setup_EVT();
    init_timer();

    go();

	return 0;
}

// Name: clear_src
// Arguments: unsigned int srow, unsigned int scol, unsigned int erow, unsigned int ecol
// Purpose: This will clear a defined section of the terminal
void clear_src(unsigned int startRow, unsigned int startColumn, unsigned int endRow, unsigned int endColumn) {

	const char c = ' ';
	for(unsigned int x = startRow; x < endRow; ++x) {
		for(unsigned int y = startColumn; y < endColumn; ++y) {
			putc_to(x, y, c);
		}
	}
}

int p1() {
    box(9,23, 11, 39);
    char hello[] = "Process 1: 0";
    while (1) {
 
        print_to(10, 25, hello);
        if (hello[11] == '9')
            hello[11] = '0';
        else 
            hello[11]++;
    }
    return 0;
}

int p2() {
    box(13,23, 15, 39);
    char hello[] = "Process 2: 0";
    print_to(14, 25, hello);
    while (1) {
        putc_to(14, 36, hello[11]);
        if (hello[11] == '9')
            hello[11] = '0';
        else 
            hello[11]++;
    }
    return 0;
}

int p3() {
    box(9,49, 11, 65);
    char hello[] = "Process 3: 0";
    while (1) {
        print_to(10, 51, hello);
        if (hello[11] == '9')
            hello[11] = '0';
        else 
            hello[11]++;
    }
    return 0;
}

int p4() {
    box(13,49, 15, 65);
    char hello[] = "Process 4: 0";
    while (1) {
        print_to(14, 51, hello);
        if (hello[11] == '9')
            hello[11] = '0';
        else 
            hello[11]++;
    }
    return 0;
}
