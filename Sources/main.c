/********************************************************************
 * Module: main.c
 * Description: Main module for the clock program.
 ********************************************************************/

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

// Function prototype(s)
void initTicker(void);

// Prototypes and wrapper functions for dec2ASCII (from lab 1)
void decToASCII(void);

void decToASCII_Wrapper(char *txt, int val)
{   asm
    {   LDX txt
        LDD val
        JSR decToASCII
    }
}

// Prototypes and wrapper functions for LCD driver (from lab 1)
void initLCD(void);
void writeLine(void);

void WriteLine_Wrapper(char *text, char line)
{   asm
    {   LDX  text
        LDAB line
        JSR  writeLine
    }
}

// Initialize LEDs
void initLED_C(void)
{   DDRJ_DDRJ1  = 1;       // Port J.1 as output
    PTIJ_PTIJ1  = 0;      
    DDRB        = 0xFF;    // Port B as output
    PORTB       = 0x00;    // Initial pattern (changed it to 0x00)
}

// Global variables
int isSetMode = 0; // 0 = clock mode, 1 = set mode

void checkButtons(void);

unsigned char clockEvent = 0;

void initClock(void);
void tickClock(void);
void incSeconds(void);
void incMinutes(void);
void incHours(void);
void decSeconds(void);
void decMinutes(void);
void decHours(void);

extern int seconds;
extern int minutes;
extern int hours;

char memberString[16] = "Alex Florian";
char altString[16] = "(C) IT SS2024";
int currentString = 0; // 0 = memberString, 1 = altString
char timeString[12]; // enough space for the time string

void getTimeString(char*);

void initThermometer(void);
void updateThermometer(void);
void getTemperatureString(char*);

extern int temperature;
char temperatureString[7]; // enough space for the temperature string

int tenSecCounter = 0;
char lowerString[16];

/********************************************************************
 * Function: main
 * Description: Main function for the clock program. Initializes hardware 
 * and handles the main loop.
 ********************************************************************/
void main(void) 
{   EnableInterrupts;                           // Global interrupt enable

    initLED_C();                     // Initialize the LEDs
    initLCD();                       // Initialize the LCD
    WriteLine_Wrapper("Clock Template", 0);
    WriteLine_Wrapper("(C) HE Prof. Z", 1); 

    initTicker();                    // Initialize the time ticker
    initClock();                     // Initialize the clock
    initThermometer();               // Initialize the thermometer

    for(;;)                          // Endless loop
    {   if (clockEvent)
        {   clockEvent = 0;

            if (!isSetMode)
            {
                tickClock();
            }

            tenSecCounter++;
            if (tenSecCounter == 10)
            {
                tenSecCounter = 0;
                currentString = (currentString + 1) % 2;
            }

            // Update the time string
            getTimeString(timeString);

            // Check for changes in thermometer
            updateThermometer();
            // Update the temperature string
            getTemperatureString(temperatureString);

            // Update the lower string
            lowerString[0] = timeString[0];
            lowerString[1] = timeString[1];
            lowerString[2] = timeString[2];
            lowerString[3] = timeString[3];
            lowerString[4] = timeString[4];
            lowerString[5] = timeString[5];
            lowerString[6] = timeString[6];
            lowerString[7] = timeString[7];
            lowerString[8] = timeString[8];
            lowerString[9] = timeString[9];
            lowerString[10] = ' ';
            lowerString[11] = temperatureString[0];
            lowerString[12] = temperatureString[1];
            lowerString[13] = temperatureString[2];
            lowerString[14] = temperatureString[3];
            lowerString[15] = temperatureString[4];

            // Display the upper line
            if (currentString == 0)
            {
                WriteLine_Wrapper(memberString, 0);
            }
            else
            {
                WriteLine_Wrapper(altString, 0);
            }

            // Display the lower line
            WriteLine_Wrapper(lowerString, 1);
        }

        // Polling for buttons
        checkButtons();
    }
}
