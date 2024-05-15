/********************************************************************
 * Module: thermometer.c
 * Description: This module handles the initialization and reading
 * of temperature values using the ADC.
 ********************************************************************/

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

void delay_10ms(void);

int temperature = 0x3FF; // Initial temperature value

/********************************************************************
 * Function: updateThermometer
 * Description: Updates the temperature reading by starting a new ADC conversion.
 ********************************************************************/
void updateThermometer(void) {
    ATD0CTL5 = 0x87; // Start conversion on channel 7
    while ((ATD0STAT0 & 0x80) != 0) {
        // wait until conversion is finished
    }
    temperature = ATD0DR0 * 50 / 511 - 30; // lower values so it does not overflow
}

/********************************************************************
 * Function: initThermometer
 * Description: Initializes the ADC for temperature measurement.
 ********************************************************************/
void initThermometer(void) {
    ATD0CTL2 = 0xC0; // Enable ATD0, no interrupt
    delay_10ms();
    ATD0CTL3 = 0x08; // Single conversion only
    ATD0CTL4 = 0x05; // 10 bit, 2 MHz ATD0 clock
}

/********************************************************************
 * Function: getTemperatureString
 * Description: Converts the temperature value to a string.
 * Parameters: char* temperatureString - Pointer to the string buffer.
 ********************************************************************/
void getTemperatureString(char* temperatureString) {
    // the temperature String has to have a length of 7
    decToASCII_Wrapper(temperatureString, temperature);
    // move the last two characters to the left
    if (temperatureString[4] == '0') {
        temperatureString[1] = ' ';
    } else {
        temperatureString[1] = temperatureString[4];
    }
    temperatureString[2] = temperatureString[5];
    temperatureString[3] = '\xDF';
    temperatureString[4] = 'C';
    temperatureString[5] = '\0';
    temperatureString[6] = '\0';
}
