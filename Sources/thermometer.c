#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

void delay_10ms(void);

int temperature = 0x3FF;

void interrupt 22 adcISR(void)
{  // Read the result registers and compute average of 4 measurements
   temperature = ((ATD0DR0 + ATD0DR1 + ATD0DR2 + ATD0DR3) * 100 / 1023) - 30;
   
   ATD0CTL2 = ATD0CTL2 | 0x01;  // Reset interrupt flag (bit 0 in ATD0CTL2)

   ATD0CTL5 = 0b10000111;       // Start next measurement on single channel 7
}

void updateThermometer(void) {
    ATD0CTL5 = 0x87;// Start conversion on channel 7
    while ((ATD0STAT0 & 0x80) != 0) {
        // wait until conversion is finished
    }
    temperature = ATD0DR0 * 50 / 511 - 30; // lower values so it does not overflow
}

void initThermometer(void) {
    //--- Initialize ATD0 -------------------------------------------------
    ATD0CTL2 = 0xC0;// Enable ATD0, no interrupt
    delay_10ms();
    ATD0CTL3 = 0x08;// Single conversion only
    ATD0CTL4 = 0x05;// 10 bit, 2 MHz ATD0 clock"
}

void getTemperatureString(char* temperatureString) {
    // the temperature String has to have a length of 7
    decToASCII_Wrapper(temperatureString, temperature);
    // move the last two characters to the left
    if (temperatureString[4] == '0') {
        temperatureString[1] = ' ';
    } else {
        temperatureString[1] = temperatureString[4];
    }
    temperatureString[2]=temperatureString[5];
    temperatureString[3]='\xDF';
    temperatureString[4]='C';
    temperatureString[5]='\0';
    temperatureString[6]='\0';
}
