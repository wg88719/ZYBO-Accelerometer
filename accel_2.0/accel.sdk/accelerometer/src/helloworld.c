/*
   Copyright(c) 2015 Kevin Bloom

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xscutimer.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "math.h"

#define CE_ID				XPAR_CE_DEVICE_ID
#define AXIS_DATA_ID		XPAR_AXIS_DATA_DEVICE_ID
#define AXIS_SW_ID			XPAR_AXIS_SW_DEVICE_ID
#define BTN_ID 				XPAR_BTN_DEVICE_ID
#define RST_ID				XPAR_RST_DEVICE_ID
#define SW_ID				XPAR_SW_DEVICE_ID
#define TIMER_DEVICE_ID		XPAR_XSCUTIMER_0_DEVICE_ID
#define TIMER_LOAD_VALUE	65



int main()
{
    init_platform();

    XScuTimer Timer;
    XGpio ce, axis_data, axis_sw, btn, rst, sw;

	//setup of the timer
    XScuTimer_Config *TimerConfigPtr;
    XScuTimer *TimerInstancePtr = &Timer;
    TimerConfigPtr = XScuTimer_LookupConfig(TIMER_DEVICE_ID);

	int status, readFlag, switchVal, i = 0;
	int16_t rawData = 0; 			  //the raw binary from the ACL chip
	float   res 	= 0.003921568627; //resolution of each bit in the raw binary
	double gData, angle, sumAngle = 0;


	/* Initialize all the GPIOs used */
	status = XGpio_Initialize(&btn, BTN_ID);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	status = XGpio_Initialize(&sw, SW_ID);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	status = XGpio_Initialize(&ce, CE_ID);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	status = XGpio_Initialize(&axis_data, AXIS_DATA_ID);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	status = XGpio_Initialize(&axis_sw, AXIS_SW_ID);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	status = XGpio_Initialize(&rst, RST_ID);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/* Private Timer Initialization */
	status = XScuTimer_CfgInitialize(&Timer, TimerConfigPtr, TimerConfigPtr->BaseAddr);
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XScuTimer_LoadTimer(TimerInstancePtr, TIMER_LOAD_VALUE); //loaded with 65

	XScuTimer_EnableAutoReload(TimerInstancePtr);

	XScuTimer_Start(TimerInstancePtr);

	while(1){

		/* Constantly read the switches */
		switchVal = XGpio_DiscreteRead(&sw, 1);

		/* Constantly looking for when the reset button (btn0) is pressed */
		XGpio_DiscreteWrite(&rst, 1, XGpio_DiscreteRead(&btn, 1));

		/* Tells the PmodACL HW model what switches are active */
		XGpio_DiscreteWrite(&axis_sw, 1, switchVal);

		/* Used to see if the axis data gpio has been read yet */
		readFlag = 0;

		if (XGpio_DiscreteRead(&ce, 1) == 0){

			XScuTimer_LoadTimer(TimerInstancePtr, TIMER_LOAD_VALUE);

			/* This keeps us in here until it's done sending/receiving */
			while (XGpio_DiscreteRead(&ce, 1) == 0){

				if (XScuTimer_IsExpired(TimerInstancePtr)){

					rawData = XGpio_DiscreteRead(&axis_data, 1);

					readFlag = 1; //you've read!

					XScuTimer_ClearInterruptStatus(TimerInstancePtr);
				}

			}

		}

		if (readFlag == 1){

			/* This state is used to see if the number received is negative or not (rawData > 512 is negative) */
			if (rawData < 512){
				gData = rawData * res; //res is the resolution of each bit received
			}else{
				gData = (512 - rawData) * res; //subtracting rawData from 512 is used to get the actual negative number
			}								   //not the binary unsigned

			/* This switch is used to see what axis you're using and what to display
			 * NOTE: The Z-axis is setup to do angle measurement! */
			switch(switchVal){
			case 0:
				printf("x-axis:%fg\r\n", gData);
				break;
			case 1:
				printf("y-axis:%fg\r\n", gData);
				break;
			case 2:
				gData    += .0991; 				  //add the offset
				gData     = (gData>1)? 1 : gData; //if gData is greater than 1, gData = 1 (because you can't take the acos
				angle     = acos(gData);		  //of a number greater than 1)
				angle    *= (180 / 3.14159); 	  //acos gives you the angle in radians, this converts it to degrees
				sumAngle += angle; 				  //used for finding the average
				i++;

				/* After 20 samples it prints the average value out */
				if (i == 20){

					printf("z-axis:%f degrees\r\n", (sumAngle / 20) );

					i = 0;
					sumAngle = 0;

				}

				break;
			default:
				printf("x-axis:%fg\r\n", gData); //chooses x-axis by default
				break;
			}

			readFlag = 0;
		}

	}

    cleanup_platform();
    return 0;
}
