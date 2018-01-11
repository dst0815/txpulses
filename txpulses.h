/*   txplses - transmit IR signal with pigpiod
 *   Johann Wiesner 2018
 *   dst0815@gmail.com
 */

#include <string.h>
#include <pigpiod_if2.h>

#define TXPULSES_MAX_LEN 598

int txpulses(uint32_t pin, int carrier, int intro, int intro2, int tshort, int tlong, int tmargin, int tseparator, const char *code) {
	#define WAVES 4
	#define WAVE_MAX_PULSES_PER_PACKET 65535 / sizeof(gpioPulse_t) //max packet size sending to pigpiod

	typedef struct {
		char name;
		int id;
		int pulses;
		int len;
	} wids;

// create
	int genwave(int pin, gpioPulse_t *wavedata, int tshort, int tlong, int cycle) {
		int j=0;
		if (tlong>0)
		       	for (uint32_t i=1; i<tlong; i=i+cycle) {
				wavedata[j].gpioOn = pin; wavedata[j].gpioOff = 0;   wavedata[j].usDelay = cycle / 2; j++;
				wavedata[j].gpioOn = 0;   wavedata[j].gpioOff = pin; wavedata[j].usDelay = cycle / 2; j++;
			}

		if (tshort>0) {
				wavedata[j].gpioOn = 0;   wavedata[j].gpioOff = pin; wavedata[j].usDelay = tshort;  j++;
		}

		return j;
	}
//
	int wid_create(int pi, int nid, char name, wids *wid, int pulses, gpioPulse_t *wavedata) {  
		int ret = wave_add_generic(pi, pulses, wavedata );
		if ( ret != pulses ) {
			printf("\nError: wave_add_generic %i: ret(%i) != pulsecount(%i).\n", name, ret, pulses);
			for (int i=0; i<WAVES; i++) wave_delete(pi, wid[i].id);
			pigpio_stop(pi);
			return -2;
		}

		ret = wave_create(pi);
		if ( ret < 0 ) {
			printf("\nError: wave_create %i: ret(%i).\n", name, ret);
			for (int i=0; i<WAVES; i++) wave_delete(pi, wid[i].id);
			pigpio_stop(pi);
			return -4;
		}
		wid[nid].id = ret;

		wid[nid].name   = name;
		wid[nid].pulses = pulses;
		wid[nid].len    = wave_get_micros(pi);
	}
//

	wids wid[WAVES];
	gpioPulse_t wavedata[WAVE_MAX_PULSES_PER_PACKET];

	char playlist[TXPULSES_MAX_LEN];

	size_t count = strlen(code);
	if (count>TXPULSES_MAX_LEN)
		return -255;

	int cycle;
	if (carrier) {     // if carrier, allign values to exact cycletimes // which are anyways off by mmm say 1-3/100
		cycle = 1000000 / carrier;
		intro  = intro  / cycle * cycle;
		intro2 = intro2 / cycle * cycle;
		tshort = tshort / cycle * cycle;
		tlong = tlong / cycle * cycle;
		tmargin = tmargin / cycle * cycle;
		tseparator = tseparator / cycle * cycle;
	}

// connect to pigpiod
        int pi = pigpio_start(NULL,NULL) ;
	if (pi < 0)
	{
		printf("\nError: can't connect to pigpiod daemon\n");
		return -1;
	}

	set_mode(pi, pin, PI_OUTPUT);
	wave_clear(pi);

// create wave set
	wid_create(pi, 0, '0', wid, genwave(pin, wavedata, tshort, tmargin, cycle), wavedata );
	wid_create(pi, 1, '1', wid, genwave(pin, wavedata, tlong,  tmargin, cycle), wavedata );
	wid_create(pi, 2, '[', wid, genwave(pin, wavedata, intro,  intro2,  cycle), wavedata );
	wid_create(pi, 3, ']', wid, genwave(pin, wavedata, 0, tshort,        cycle), wavedata );
//	wid_create(pi, 3, ']', wid, genwave(pin, wavedata, tshort, tseparator, cycle), wavedata );   //send separator as wave 

// --- Create playlist
int j;
int ret;

j=0;
int time=0;
for (int i = 0; i<count; i++) {
	if (code[i] == '0') {
		playlist[j]=wid[0].id;
		time=time+wid[0].len;
		j++;
	} else
	if (code[i] == '1') {
		playlist[j]=wid[1].id;
		time=time+wid[1].len;
		j++;
	} else
	if (code[i] == '[') {
		playlist[j]=wid[2].id;
		time=time+wid[2].len;
		j++;
	} else
	if (code[i] == ']') {
		playlist[j]=wid[3].id;
		time=time+wid[3].len;
		j++;
		if (code[i+1] == '[') {
			playlist[j]=255;
			j++;
			playlist[j]=2;
			j++;
			playlist[j]=tseparator ^ 256;
			j++;
			playlist[j]=tseparator / 256;
			j++;
			time=time+tseparator;
		}
	} else
	printf("Unknown character: %c\n", code[i]);
}

	ret=wave_chain( pi, playlist, j );

	if (ret!=0) {
		printf("\nError sending codes (%i): count, %i.\n");
		for (int i=0; i<WAVES; i++) 
			printf("wave: %i, name: %c, code: %i len: %ius\n",i,wid[i].name,wid[i].id,wid[i].len);
	} else time_sleep(time/1000000);

	while (wave_tx_busy(pi)) time_sleep(0.1);

	for (int i=0; i<WAVES; i++) wave_delete(pi, wid[i].id);

	pigpio_stop(pi);

	return ret;
}


