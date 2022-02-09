/*
Copyright (c) 2013-2014 Ben Croston

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "Python.h"
#include "c_gpio.h"
#include "common.h"

int gpio_mode = MODE_UNKNOWN;
#ifdef RK3399PRO_AI 
/*
#define GPIO0_C1		17			//7----->17

#define GPIO5_B0		(8+152)		//7----->160
#define GPIO5_B1		(9+152)		//7----->161
#define GPIO5_B2		(10+152)	//7----->162
#define GPIO5_B3		(11+152)	//7----->163
#define GPIO5_B4		(12+152)	//7----->164
#define GPIO5_B5		(13+152)	//7----->165
#define GPIO5_B6		(14+152)	//7----->166
#define GPIO5_B7		(15+152)	//7----->167
#define GPIO5_C0		(16+152)	//7----->168
#define GPIO5_C1		(17+152)	//7----->169
#define GPIO5_C2		(18+152)	//7----->170
#define GPIO5_C3		(19+152)	//7----->171

#define GPIO6_A0		(184)		//7----->184
#define GPIO6_A1		(1+184)		//7----->185
#define GPIO6_A3		(3+184)		//7----->187
#define GPIO6_A4		(4+184)		//7----->188

#define GPIO7_A7		(7+216)		//7----->223
#define GPIO7_B0		(8+216)		//7----->224
#define GPIO7_B1		(9+216)		//7----->225
#define GPIO7_B2		(10+216)	//7----->226
#define GPIO7_C1		(17+216)	//7----->233
#define GPIO7_C2		(18+216)	//7----->234
#define GPIO7_C6		(22+216)	//7----->238
#define GPIO7_C7		(23+216)	//7----->239

#define GPIO8_A3		(3+248)		//7----->251
#define GPIO8_A4		(4+248)		//7----->252
#define	GPIO8_A5		(5+248)		//7----->253
#define GPIO8_A6		(6+248)		//7----->254
#define GPIO8_A7		(7+248)		//7----->255
#define GPIO8_B0		(8+248)		//7----->256
#define GPIO8_B1		(9+248)		//7----->257


//RK3288
const int pin_to_gpio_rev[41]={-1,-1,-1,GPIO8_A4,-1,GPIO8_A5,-1,GPIO0_C1,GPIO5_B1,
				-1,GPIO5_B0,GPIO5_B4,GPIO6_A0,GPIO5_B6,-1,GPIO5_B7,GPIO5_B2,-1,GPIO5_B3,
				GPIO8_B1,-1,GPIO8_B0,GPIO5_C3,GPIO8_A6,GPIO8_A7,-1,GPIO8_A3,GPIO7_C1,GPIO7_C2,
				GPIO5_B5,-1,GPIO5_C0,GPIO7_C7,GPIO7_C6,-1,GPIO6_A1,GPIO7_A7,GPIO7_B0,GPIO6_A3,
				-1,GPIO6_A4};
*/

#define RK3399PRO_GPIO0_A6              (0+6)

#define RK3399PRO_GPIO1_A7              (8+31)
#define RK3399PRO_GPIO1_B0              (9+31)
#define RK3399PRO_GPIO1_B1              (10+31)
#define RK3399PRO_GPIO1_B2              (11+31)

#define RK3399PRO_GPIO2_A7              (8+63)
#define RK3399PRO_GPIO2_B0              (9+63)
#define RK3399PRO_GPIO2_B1              (10+63)
#define RK3399PRO_GPIO2_B2              (11+63)

#define RK3399PRO_GPIO2_C0              (17+63)
#define RK3399PRO_GPIO2_C1              (18+63)
#define RK3399PRO_GPIO2_C2              (19+63)
#define RK3399PRO_GPIO2_C3              (20+63)
#define RK3399PRO_GPIO2_C4              (21+63)
#define RK3399PRO_GPIO2_C5              (22+63)
#define RK3399PRO_GPIO2_C6              (23+63)
#define RK3399PRO_GPIO2_C7              (24+63)
#define RK3399PRO_GPIO2_D1              (26+63)

#define RK3399PRO_GPIO3_D0              (25+95)
#define RK3399PRO_GPIO3_D1              (26+95)
#define RK3399PRO_GPIO3_D2              (27+95)
#define RK3399PRO_GPIO3_D3              (28+95)
#define RK3399PRO_GPIO3_D4              (29+95)
#define RK3399PRO_GPIO3_D5              (30+95)
#define RK3399PRO_GPIO3_D6              (31+95)
#define RK3399PRO_GPIO3_D7              (32+95)


#define RK3399PRO_GPIO4_C2              (19+127)
#define RK3399PRO_GPIO4_C5              (22+127)
#define RK3399PRO_GPIO4_C6              (23+127)


const int pin_to_gpio_rev[41]={-1,
				-1,		   	-1,			//	1,	2
				RK3399PRO_GPIO2_B1,	-1,			//	3,	4
				RK3399PRO_GPIO2_B2,	-1,			//	5,	6
				RK3399PRO_GPIO2_D1,	RK3399PRO_GPIO2_C1,	//	7,	8
                                -1,			RK3399PRO_GPIO2_C0,	//	9,	10
				RK3399PRO_GPIO2_C3,	RK3399PRO_GPIO3_D0,	//	11,	12
				RK3399PRO_GPIO2_C5,	-1,			//	13,	14
				RK3399PRO_GPIO2_C4,	RK3399PRO_GPIO2_C6,	//	15,	16
				-1,			RK3399PRO_GPIO2_C7,	//	17,	18
                                RK3399PRO_GPIO1_B0,	-1,			//	19,	20
				RK3399PRO_GPIO1_A7,	RK3399PRO_GPIO3_D4,	//	21,	22
				RK3399PRO_GPIO1_B1,	RK3399PRO_GPIO1_B2,	//	23,	24
				-1,			RK3399PRO_GPIO0_A6,	//	25,	26
				RK3399PRO_GPIO2_A7,	RK3399PRO_GPIO2_B0,	//	27,	28
                                RK3399PRO_GPIO3_D6,	-1,			//	29,	30
				RK3399PRO_GPIO3_D5,	RK3399PRO_GPIO4_C2,	//	31,	32
				RK3399PRO_GPIO4_C6,	-1,			//	33,	34
				RK3399PRO_GPIO3_D1,	RK3399PRO_GPIO2_C2,	//	35,	36
				RK3399PRO_GPIO4_C5,	RK3399PRO_GPIO3_D3,	//	37,	38
                                -1,			RK3399PRO_GPIO3_D7};	//	39,	40

#else
const int pin_to_gpio_rev[41] = {-1, -1, -1, 2, -1, 3, -1, 4, 14, -1, 15, 17, 18, 27, -1, 22, 23, -1, 24, 10, -1, 9, 25, 11, 8, -1, 7, -1, -1, 5, -1, 6, 12, 13, -1, 19, 16, 26, 20, -1, 21 };//it depend on ee
#endif
const int bcm_gpio_to_pin[28]={
	27,28, 3, 5, 7,	//GPIO0-4
	29,31,26,24,21, //GPIO5-9
	19,23,32,33, 8, //GPIO10-14
	10,36,11,12,35, //GPIO15-19
	38,40,15,16,18, //GPIO20-24
	22,37,13		//GPIO25-27
};
int setup_error = 0;
int module_setup = 0;

int check_gpio_priv(void)
{
	// check module has been imported cleanly

	if (setup_error)
	{
		PyErr_SetString(PyExc_RuntimeError, "Module not imported correctly!");
		return 1;
	}

	// check mmap setup has worked
	if (!module_setup)
	{
		PyErr_SetString(PyExc_RuntimeError, "No access to /dev/mem.  Try running as root!");
		return 2;
	}
	return 0;
}

int get_gpio_number(int channel, unsigned int *gpio)
{
	// check setmode() has been run

	if (gpio_mode != BOARD && gpio_mode != RK && gpio_mode != ASUS && gpio_mode != BCM)
	{
		PyErr_SetString(PyExc_RuntimeError, "Please set pin numbering mode using GPIO.setmode(GPIO.BOARD), GPIO.setmode(GPIO.ASUS), GPIO.setmode(GPIO.BCM) or GPIO.setmode(GPIO.RK)");
		return 3;
	}

	// check channel number is in range
	if ( (gpio_mode == RK && (channel < 0 || channel > 300))
	|| (gpio_mode == ASUS && (channel < 0 || channel > 300))
	|| (gpio_mode == BCM && (channel < 0 || channel > 27))
	|| (gpio_mode == BOARD && (channel < 1 || channel > 40) ) )
	{
		PyErr_SetString(PyExc_ValueError, "The channel sent is invalid on a ASUS");
		return 4;
	}

	// convert channel to gpio
	if (gpio_mode == BOARD)
	{
		if (*(*pin_to_gpio+channel) == -1)
		{
			PyErr_SetString(PyExc_ValueError, "The channel sent is invalid on a ASUS");
			return 5;
		} 
		else 
		{
			*gpio = *(*pin_to_gpio+channel);
		}
	}
	else if(gpio_mode == BCM)
	{
		*gpio = *(*pin_to_gpio+bcm_gpio_to_pin[channel]);
	}
	else // gpio_mode == RK or gpio_mode == ASUS
	{
		*gpio = channel;
	}

	return 0;
}
