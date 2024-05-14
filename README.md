# HCS12 Clock Project

## Overview

This project involves the development of a radio-frequency controlled clock based on the DCF77 signal, designed for the HCS12 microcontroller. This application utilizes HCS12's timer module and various other components such as LEDs, LCD, and buttons to create a comprehensive embedded system for timekeeping and temperature measurement. The Program was tested on the Dragon12 development board.

## Features

- **Contributors Display:** Shows the names of the contributors on the LCD. This line is alternated with the Semester every 10 seconds.
- **Time Display:** Shows current time on an LCD in HH:MM:SS format, updated every second. The LED on Port B.0 toggles once per second to indicate time progression.
- **Set Mode:** Allows setting the time manually using buttons at port PTH.0, PTH.1, PTH.2 and PTH.3. The LED on port B.7 indicates active Set Mode.
- **Temperature Display:** Uses an analog-to-digital converter and displays it on the LCD. The isn't any temperature sensor on the Dragon12 board, so the temperature is simulated.
- **Adjustable Time Format:** Supports both 24-hour and 12-hour formats through conditional compilation.

## Getting Started

### Prerequisites

- **Hardware:** Dragon12 development board with HCS12 microcontroller.
- **Software:** CodeWarrior IDE for HCS12. (with some modifications to the components)

### Installation

1. Clone the repository to your local machine.
2. Open the project in CodeWarrior IDE.
3. Build the project and flash the binary to the Dragon12 board.

### Hint

If run in the simulator, the program will not work as expected because the button inputs are inverted. To fix this, change `BRCLR` to `BRSET` in the `button.asm` file.

## Modules

- `main.c`: Orchestrates the initialization and main loop of the application.
- `clock.c`: Manages timekeeping functionalities.
- `thermometer.c`: Handles temperature measurement and display.
- `lcd.asm`, `led.asm`, `button.asm`: Drivers for the LCD display, LED control, and button input respectively.
- `ticker.asm`: Contains the timer interrupt service routine.
- `decToASCII.asm`: Converts decimal numbers to ASCII for display purposes.
- `delay.asm`: Implements a delay function for time-sensitive operations.

## Development and Testing

Developed using a mix of C and HCS12 assembler, this project emphasizes modular programming and separation of concerns among different functionalities. Testing involves both simulation and physical deployment on the Dragon12 board to ensure robust performance.

## Instructions for Use

1. **Initialization:** On startup, the clock displays the set initial time and periodically updates the display.
2. **Setting Time:** Enter Set Mode by Pressing the Button on Port PTH.0 to adjust hours (PTH.1), minutes (PTH.2), and seconds (PTH.3) independently.
3. **Viewing Temperature:** The temperature is displayed continuously and updated every second.

## Acknowledgements

Thanks to Hochschule Esslingen for providing the platform and resources necessary for the development of this project.
