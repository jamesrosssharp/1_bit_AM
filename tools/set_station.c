/*
 *  iceprog -- simple programming tool for FTDI-based Lattice iCE programmers
 *
 *  Copyright (C) 2015  Clifford Wolf <clifford@clifford.at>
 *  Copyright (C) 2018  Piotr Esden-Tempski <piotr@esden.net>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *  Relevant Documents:
 *  -------------------
 *  http://www.latticesemi.com/~/media/Documents/UserManuals/EI/icestickusermanual.pdf
 *  http://www.micron.com/~/media/documents/products/data-sheet/nor-flash/serial-nor/n25q/n25q_32mb_3v_65nm.pdf
 */

#define _GNU_SOURCE

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <getopt.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

#ifdef _WIN32
#include <io.h> /* _setmode() */
#include <fcntl.h> /* _O_BINARY */
#endif

#include "mpsse.h"

static bool verbose = false;

// ---------------------------------------------------------
// FLASH definitions
// ---------------------------------------------------------

// ---------------------------------------------------------
// Hardware specific CS, CReset, CDone functions
// ---------------------------------------------------------

static void set_cs_creset(int cs_b, int creset_b)
{
	uint8_t gpio = 0;
	uint8_t direction = 0x93;

	if (cs_b) {
		// ADBUS4 (GPIOL0)
		gpio |= 0x10;
	}

	if (creset_b) {
		// ADBUS7 (GPIOL3)
		gpio |= 0x80;
	}

	mpsse_set_gpio(gpio, direction);
}

static bool get_cdone(void)
{
	// ADBUS6 (GPIOL2)
	return (mpsse_readb_low() & 0x40) != 0;
}




// ---------------------------------------------------------
// FLASH function implementations
// ---------------------------------------------------------


int main(int argc, char **argv)
{

	const char *devstr = NULL;
	int ifnum = 0;

	if (argc != 3)
	{
		printf("Usage: %s <frequency, Hz> <gain, 0-3>\n\n", argv[0]);
		return 1;
	}

	int freq = atoi(argv[1]);

	


//	char buffer[] = {0x00, 0x0b, 0xeb, 0xd3};
	char buffer[] = {0x00, 0x13, 0x12, 0xeb};
//	char buffer[] = {0xaa, 0xaa, 0xaa, 0x20};


	int64_t phase_incr = ((1ULL<<26) * (int64_t)freq) / 50250000;

	buffer[3] = phase_incr & 0xff;
	buffer[2] = (phase_incr >> 8) & 0xff;
	buffer[1] = (phase_incr >> 16) & 0xff;
	buffer[0] = (phase_incr >> 24) & 0x3;

	int gain = atoi(argv[2]);

	buffer[0] = gain << 2;

	mpsse_init(ifnum, devstr, true);

	set_cs_creset(0, 1);
	usleep(1000);
	mpsse_send_spi(buffer, sizeof(buffer));
	usleep(1000);	
	set_cs_creset(1, 1);
	
	mpsse_close();
	return 0;
}
