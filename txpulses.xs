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

int txpulses(outPin,carrier,InitPulse,InitGap,onePulse,zeroPulse,Gap,pause,pulses)
        uint32_t outPin;
        int carrier;
        int InitPulse;
        int InitGap;
        int onePulse;
        int zeroPulse;
        int Gap;
        int pause;
        char *pulses;

    CODE:
       int x = txpulses(
               outPin,
               carrier,
               InitPulse,
               InitGap,
               onePulse,
               zeroPulse,
               Gap,
               pause,
               pulses);



        RETVAL = x;
    OUTPUT:
        RETVAL


