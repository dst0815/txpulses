#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "txpulses.h"

#include "const-c.inc"

MODULE = txpulses		PACKAGE = txpulses		

INCLUDE: const-xs.inc

#include <stdio.h>

int txpulses(pin, carrier, intro, intro2, tshort, tlong, tmargin, tseparator, const char *code)
	uint32_t pin;
	int carrier;
	int intro;
	int intro2;
	int tshort;
	int tlong;
	int tmargin;
	int tseparator;
	char *code;

    CODE:
       int x = txpulses(
	pin,
	carrier,
	intro,
	intro2,
	tshort,
	tlong,
	tmargin,
	tseparator,
	*code);



        RETVAL = x;
    OUTPUT:
        RETVAL

