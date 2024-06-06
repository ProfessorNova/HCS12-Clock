/********************************************************************
 * Module: clock.c
 * Description: This module handles the clock functionality, including
 * incrementing time and managing 12-hour and 24-hour formats.
 ********************************************************************/

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

#define SELECT12HOURS 0

int seconds;
int minutes;
int hours;

#ifdef SELECT12HOURS

#if SELECT12HOURS == 1
/********************************************************************
 * Function: incSeconds
 * Description: Increments the seconds and resets to 0 if it reaches 60.
 ********************************************************************/
void incSeconds(void){
    seconds++;
    if (seconds == 60) {
        seconds = 0;
    }
}

/********************************************************************
 * Function: incMinutes
 * Description: Increments the minutes and resets to 0 if it reaches 60.
 ********************************************************************/
void incMinutes(void){
    minutes++;
    if (minutes == 60) {
        minutes = 0;
    }
}

/********************************************************************
 * Function: incHours
 * Description: Increments the hours and resets to 0 if it reaches 24.
 ********************************************************************/
void incHours(void){
    hours++;
    if (hours == 24) {
        hours = 0;
    }
}

/********************************************************************
 * Function: decSeconds
 * Description: Decrements the seconds and sets to 59 if it goes below 0.
 ********************************************************************/
void decSeconds(void){
    seconds--;
    if (seconds == -1) {
        seconds = 59;
    }
}

/********************************************************************
 * Function: decMinutes
 * Description: Decrements the minutes and sets to 59 if it goes below 0.
 ********************************************************************/
void decMinutes(void){
    minutes--;
    if (minutes == -1) {
        minutes = 59;
    }
}

/********************************************************************
 * Function: decHours
 * Description: Decrements the hours and sets to 23 if it goes below 0.
 ********************************************************************/
void decHours(void){
    hours--;
    if (hours == -1) {
        hours = 23;
    }
}

/********************************************************************
 * Function: getTimeString
 * Description: Converts the time into a string format.
 * Parameters: char *timeString - Pointer to the string buffer.
 ********************************************************************/
void getTimeString(char *timeString) {
    // the time String needs a to have a length of 12
    decToASCII_Wrapper(timeString, hours);
    // the ascii value we want is the 10^0 digit and the 10^1 digit
    timeString[0] = timeString[0+4];
    timeString[1] = timeString[1+4];
    timeString[2] = ':';
    decToASCII_Wrapper(timeString + 3, minutes);
    timeString[3] = timeString[3+4];
    timeString[4] = timeString[4+4];
    timeString[5] = ':';
    decToASCII_Wrapper(timeString + 6, seconds);
    timeString[6] = timeString[6+4];
    timeString[7] = timeString[7+4];
    timeString[8] = ' ';
    timeString[9] = ' ';
    timeString[10] = ' ';
    timeString[11] = '\0';
}
#else
int amPm = 0;

void incSeconds(void){
    seconds++;
    if (seconds == 60) {
        seconds = 0;
    }
}

void incMinutes(void){
    minutes++;
    if (minutes == 60) {
        minutes = 0;
    }
}

void incHours(void){
    hours++;
    if (hours == 12) {
        amPm = !amPm;
    }
    else if (hours == 13) {
        hours = 1;
    }
}

void decSeconds(void){
    seconds--;
    if (seconds == -1) {
        seconds = 59;
    }
}

void decMinutes(void){
    minutes--;
    if (minutes == -1) {
        minutes = 59;
    }
}

void decHours(void){
    hours--;
    if (hours == -1) {
        hours = 12;
    }
}

void getTimeString(char *timeString) {
    decToASCII_Wrapper(timeString, hours);
    timeString[0] = timeString[0+4];
    timeString[1] = timeString[1+4];
    timeString[2] = ':';
    decToASCII_Wrapper(timeString + 3, minutes);
    timeString[3] = timeString[3+4];
    timeString[4] = timeString[4+4];
    timeString[5] = ':';
    decToASCII_Wrapper(timeString + 6, seconds);
    timeString[6] = timeString[6+4];
    timeString[7] = timeString[7+4];
    if(amPm){
        timeString[8] = 'A';
        timeString[9] = 'M';
    }
    else{
        timeString[8] = 'P';
        timeString[9] = 'M';
    }   
    timeString[10] = ' ';
    timeString[11] = '\0';
}
#endif
#endif

/********************************************************************
 * Function: initClock
 * Description: Initializes the clock with the default time.
 ********************************************************************/
void initClock(void) {
    seconds = 50;
    minutes = 59;
    hours = 11;
}

/********************************************************************
 * Function: tickClock
 * Description: Updates the clock every second.
 ********************************************************************/
void tickClock(void) {
    incSeconds();
    if (seconds == 0) {
        incMinutes();
        if (minutes == 0) {
            incHours();
        }
    }
}
