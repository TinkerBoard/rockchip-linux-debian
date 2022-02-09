/*
 * Author: Brian <brian@vamrs.com>
 * Copyright (c) 2019 Vamrs Corporation.
 *
 * SPDX-License-Identifier: MIT
 */

#include <mraa/common.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

#include "arm/tinker_board.h"
#include "common.h"

#define DT_BASE "/proc/device-tree"

/*
* "Radxa ROCK Pi 4" is the model name on stock 5.x kernels
* "ASUS Tinker Board 2" is used on Radxa 4.4 kernel
* so we search for the string below by ignoring case
*/
#define PLATFORM_NAME_TINKER_BOARD_2 "ASUS Tinker Board 2/2S"
#define PLATFORM_NAME_TINKER_BOARD_S "ASUS Tinker Board (S)"
#define PLATFORM_NAME_TINKER_EDGE_T "ASUS Tinker Edge T"
#define PLATFORM_NAME_TINKER_EDGE_R "ASUS Tinker Edge R"
#define MAX_SIZE 64

const char* tinkerboard2_serialdev[MRAA_TINKER2_UART_COUNT] = { "/dev/ttyS0", "/dev/ttyS4" };

const char* tinkerboards_serialdev[MRAA_TINKERS_UART_COUNT] = { "/dev/ttyS1", "/dev/ttyS2", "/dev/ttyS4" };

const char* tinkeredget_serialdev[MRAA_TINKEREDGET_UART_COUNT] = { "/dev/ttymxc0", "/dev/ttymxc2" };

const char* tinkeredger_serialdev[MRAA_TINKEREDGER_UART_COUNT] = { "/dev/ttyS0", "/dev/ttyS4" };

void
mraa_tinkerboard_pininfo(mraa_board_t* board, int index, int sysfs_pin, mraa_pincapabilities_t pincapabilities_t, char* fmt, ...)
{
    va_list arg_ptr;
    if (index > board->phy_pin_count)
        return;

    mraa_pininfo_t* pininfo = &board->pins[index];
    va_start(arg_ptr, fmt);
    vsnprintf(pininfo->name, MRAA_PIN_NAME_SIZE, fmt, arg_ptr);

    if( pincapabilities_t.gpio == 1 ) {
        va_arg(arg_ptr, int);
        pininfo->gpio.gpio_chip = va_arg(arg_ptr, int);
        pininfo->gpio.gpio_line = va_arg(arg_ptr, int);
    }

    pininfo->capabilities = pincapabilities_t;

    va_end(arg_ptr);
    pininfo->gpio.pinmap = sysfs_pin;
    pininfo->gpio.mux_total = 0;
}

mraa_board_t*
mraa_tinkerboard()
{
    syslog(LOG_ERR, "mraa_tinkerboard +++");

    mraa_board_t* b = (mraa_board_t*) calloc(1, sizeof(mraa_board_t));
    if (b == NULL) {
        return NULL;
    }
    b->adv_func = (mraa_adv_func_t*) calloc(1, sizeof(mraa_adv_func_t));
    if (b->adv_func == NULL) {
        free(b);
        return NULL;
    }

    // pin mux for buses are setup by default by kernel so tell mraa to ignore them
    b->no_bus_mux = 1;

    if (mraa_file_exist(DT_BASE "/model")) {
        // We are on a modern kernel, great!!!!
        if (mraa_file_contains(DT_BASE "/model", PLATFORM_NAME_TINKER_BOARD_2)) {
            b->phy_pin_count = MRAA_TINKER2_PIN_COUNT + 1;
            b->platform_name = PLATFORM_NAME_TINKER_BOARD_2;
            b->uart_dev[0].device_path = (char*) tinkerboard2_serialdev[0];
            b->uart_dev[1].device_path = (char*) tinkerboard2_serialdev[1];

            // UART
            b->uart_dev_count = MRAA_TINKER2_UART_COUNT;
            b->def_uart_dev = 0;
            b->uart_dev[0].index = 0;
            b->uart_dev[1].index = 4;

            // I2C
            if (strncmp(b->platform_name, PLATFORM_NAME_TINKER_BOARD_2, MAX_SIZE) == 0) {
                b->i2c_bus_count = MRAA_TINKER2_I2C_COUNT;
                b->def_i2c_bus = 0;
                b->i2c_bus[0].bus_id = 6;
                b->i2c_bus[1].bus_id = 7;
            }

            // SPI
            b->spi_bus_count = MRAA_TINKER2_SPI_COUNT;
            b->def_spi_bus = 0;
            b->spi_bus[0].bus_id = 1;
            b->spi_bus[1].bus_id = 5;

            // PWM
            b->pwm_dev_count = MRAA_TINKER2_PWM_COUNT;
            b->pwm_default_period = 500;
            b->pwm_max_period = 2147483;
            b->pwm_min_period = 1;
            b->pins = (mraa_pininfo_t*) malloc(sizeof(mraa_pininfo_t) * b->phy_pin_count);
            if (b->pins == NULL) {
                free(b->adv_func);
                free(b);
                return NULL;
            }
            b->pins[32].pwm.parent_id = 0;
            b->pins[32].pwm.mux_total = 0;
            b->pins[32].pwm.pinmap = 0;
            b->pins[33].pwm.parent_id = 1;
            b->pins[33].pwm.mux_total = 0;
            b->pins[33].pwm.pinmap = 0;
            b->pins[26].pwm.parent_id = 3;
            b->pins[26].pwm.mux_total = 0;
            b->pins[26].pwm.pinmap = 0;

            //b->aio_count = MRAA_TINKER2_AIO_COUNT;
            //b->adc_raw = 10;
            //b->adc_supported = 10;
            //b->aio_dev[0].pin = 26;
            //b->aio_non_seq = 1;
            mraa_tinkerboard_pininfo(b, 0,   -1, (mraa_pincapabilities_t){0,0,0,0,0,0,0,0}, "INVALID");
            mraa_tinkerboard_pininfo(b, 1,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "3V3");
            mraa_tinkerboard_pininfo(b, 2,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "5V");
            mraa_tinkerboard_pininfo(b, 3,   73, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "SDA6");
            mraa_tinkerboard_pininfo(b, 4,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "5V");
            mraa_tinkerboard_pininfo(b, 5,   74, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "SCL6");
            mraa_tinkerboard_pininfo(b, 6,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 7,    8, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "TEST_CLK2");
            mraa_tinkerboard_pininfo(b, 8,   81, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "TXD0");
            mraa_tinkerboard_pininfo(b, 9,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 10,  80, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "RXD0");
            mraa_tinkerboard_pininfo(b, 11,  83, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "RTSN0");
            mraa_tinkerboard_pininfo(b, 12, 120, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "I2S0_SCLK");
            mraa_tinkerboard_pininfo(b, 13,  85, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "SPI5TX");
            mraa_tinkerboard_pininfo(b, 14,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 15,  84, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "SPI5RX");
            mraa_tinkerboard_pininfo(b, 16,  86, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "SPI5CLK");
            mraa_tinkerboard_pininfo(b, 17,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "3V3");
            mraa_tinkerboard_pininfo(b, 18,  87, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "SPI5CS0");
            mraa_tinkerboard_pininfo(b, 19,  40, (mraa_pincapabilities_t){1,1,0,0,1,0,0,1}, "SPI1TX,TXD4");
            mraa_tinkerboard_pininfo(b, 20,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 21,  39, (mraa_pincapabilities_t){1,1,0,0,1,0,0,1}, "SPI1RX,RXD4");
            mraa_tinkerboard_pininfo(b, 22, 124, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "I2S0_SDO3");
            mraa_tinkerboard_pininfo(b, 23,  41, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "SPI1CLK");
            mraa_tinkerboard_pininfo(b, 24,  42, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "SPI1CS0");
            mraa_tinkerboard_pininfo(b, 25,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 26,   6, (mraa_pincapabilities_t){1,1,1,0,0,0,0,0}, "PWM3A");
            mraa_tinkerboard_pininfo(b, 27,  71, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "SDA7");
            mraa_tinkerboard_pininfo(b, 28,  72, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "SCL7");
            mraa_tinkerboard_pininfo(b, 29, 126, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "I2S0_SDO1");
            mraa_tinkerboard_pininfo(b, 30,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 31, 125, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "I2S0_SDO2");
            mraa_tinkerboard_pininfo(b, 32, 146, (mraa_pincapabilities_t){1,1,1,0,0,0,0,0}, "PWM0");
            mraa_tinkerboard_pininfo(b, 33, 150, (mraa_pincapabilities_t){1,1,1,0,0,0,0,0}, "PWM1");
            mraa_tinkerboard_pininfo(b, 34,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 35, 121, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "I2S0_FS");
            mraa_tinkerboard_pininfo(b, 36,  82, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "CTSN0");
            mraa_tinkerboard_pininfo(b, 37, 149, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "SPDIFTX");
            mraa_tinkerboard_pininfo(b, 38, 123, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "I2S0_SDI0");
            mraa_tinkerboard_pininfo(b, 39,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 40, 127, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "I2S0_SDO0");
        }
        else if (mraa_file_contains(DT_BASE "/model", PLATFORM_NAME_TINKER_BOARD_S)) {
            b->phy_pin_count = MRAA_TINKERS_PIN_COUNT + 1;
            b->platform_name = PLATFORM_NAME_TINKER_BOARD_S;
            b->chardev_capable = 1;

            b->uart_dev[0].device_path = (char*) tinkerboards_serialdev[0];
            b->uart_dev[1].device_path = (char*) tinkerboards_serialdev[1];
            b->uart_dev[2].device_path = (char*) tinkerboards_serialdev[2];

            // UART
            b->uart_dev_count = MRAA_TINKERS_UART_COUNT;
            b->def_uart_dev = 0;
            b->uart_dev[0].index = 1;
            b->uart_dev[1].index = 2;
            b->uart_dev[2].index = 4;

            // I2C
            if (strncmp(b->platform_name, PLATFORM_NAME_TINKER_BOARD_S, MAX_SIZE) == 0) {
                b->i2c_bus_count = MRAA_TINKERS_I2C_COUNT;
                b->def_i2c_bus = 0;
                b->i2c_bus[0].bus_id = 1;
                b->i2c_bus[1].bus_id = 4;
            }

            // SPI
            b->spi_bus_count = MRAA_TINKERS_SPI_COUNT;
            b->def_spi_bus = 0;
            b->spi_bus[0].bus_id = 0;
            b->spi_bus[1].bus_id = 2;

            // PWM
            b->pwm_dev_count = MRAA_TINKERS_PWM_COUNT;
            b->pwm_default_period = 500;
            b->pwm_max_period = 2147483;
            b->pwm_min_period = 1;
            b->pins = (mraa_pininfo_t*) malloc(sizeof(mraa_pininfo_t) * b->phy_pin_count);
            if (b->pins == NULL) {
                free(b->adv_func);
                free(b);
                return NULL;
            }
            b->pins[32].pwm.parent_id = 3;
            b->pins[32].pwm.mux_total = 0;
            b->pins[32].pwm.pinmap = 0;
            b->pins[33].pwm.parent_id = 2;
            b->pins[33].pwm.mux_total = 0;
            b->pins[33].pwm.pinmap = 0;

            mraa_tinkerboard_pininfo(b, 0,   -1, (mraa_pincapabilities_t){0,0,0,0,0,0,0,0}, "INVALID");
            mraa_tinkerboard_pininfo(b, 1,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "3V3");
            mraa_tinkerboard_pininfo(b, 2,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "5V");
            mraa_tinkerboard_pininfo(b, 3,  252, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO8A4:I2C1_SDA", -1, 8, 4);
            mraa_tinkerboard_pininfo(b, 4,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "5V");
            mraa_tinkerboard_pininfo(b, 5,  253, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO8A5:I2C1_SCL", -1, 8, 5);
            mraa_tinkerboard_pininfo(b, 6,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 7,   17, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO0_C1:CLKOUT", -1, 0, 17);
            mraa_tinkerboard_pininfo(b, 8,  161, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO5_B1:UART1TX", -1, 5, 9);
            mraa_tinkerboard_pininfo(b, 9,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 10, 160, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO5_B0:UART1RX", -1, 5, 8);
            mraa_tinkerboard_pininfo(b, 11, 164, (mraa_pincapabilities_t){1,1,0,0,1,0,0,1}, "GPIO5B4:SPI0_CLK:UART4_CTSN", -1, 5, 12);
            mraa_tinkerboard_pininfo(b, 12, 184, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO6A0:I2S_SCLK", -1, 6, 0);
            mraa_tinkerboard_pininfo(b, 13, 166, (mraa_pincapabilities_t){1,1,0,0,1,0,0,1}, "GPIO5B6:SPI0_TXD:UART4_TXD", -1, 5, 14);
            mraa_tinkerboard_pininfo(b, 14,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 15, 167, (mraa_pincapabilities_t){1,1,0,0,1,0,0,1}, "GPIO5B7:SPI0_RXD:UART4_RXD", -1, 5, 15);
            mraa_tinkerboard_pininfo(b, 16, 162, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO5B2:UART1_CTSN", -1, 5, 10);
            mraa_tinkerboard_pininfo(b, 17,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "3V3");
            mraa_tinkerboard_pininfo(b, 18, 163, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO5B3:UART1_RTSN", -1, 5, 11);
            mraa_tinkerboard_pininfo(b, 19, 257, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO8B1:SPI2_TXD", -1, 8, 9);
            mraa_tinkerboard_pininfo(b, 20,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 21, 256, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO8B0:SPI2_RXD", -1, 8, 8);
            mraa_tinkerboard_pininfo(b, 22, 171, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO5C3", -1, 5, 19);
            mraa_tinkerboard_pininfo(b, 23, 254, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO8A6:SPI2_CLK", -1, 8, 6);
            mraa_tinkerboard_pininfo(b, 24, 255, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO8A7:SPI2_CSN0", -1, 8, 7);
            mraa_tinkerboard_pininfo(b, 25,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 26, 251, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO8A3:SPI2_CSN1", -1, 8, 3);
            mraa_tinkerboard_pininfo(b, 27, 233, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO7C1:I2C4_SDA", -1, 7, 17);
            mraa_tinkerboard_pininfo(b, 28, 234, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO7C2:I2C4_SCL", -1, 7, 18);
            mraa_tinkerboard_pininfo(b, 29, 165, (mraa_pincapabilities_t){1,1,0,0,1,0,0,1}, "GPIO5B5:SPI0_CSN0:UART4_RTSN", -1, 5, 13);
            mraa_tinkerboard_pininfo(b, 30,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 31, 168, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO5C0:SPI0_CSN1", -1, 5, 16);
            mraa_tinkerboard_pininfo(b, 32, 239, (mraa_pincapabilities_t){1,1,1,0,0,0,0,1}, "GPIO7C7:UART2_TXD:PWM3", -1, 7, 23);
            mraa_tinkerboard_pininfo(b, 33, 238, (mraa_pincapabilities_t){1,1,1,0,0,0,0,1}, "GPIO7C6:UART2_RXD:PWM2", -1, 7, 22);
            mraa_tinkerboard_pininfo(b, 34,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 35, 185, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO6A1:I2S_LRCKRX", -1, 6, 1);
            mraa_tinkerboard_pininfo(b, 36, 223, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO7A7:UART3_RXD", -1, 7, 7);
            mraa_tinkerboard_pininfo(b, 37, 224, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO7B0:UART3_TXD", -1, 7, 8);
            mraa_tinkerboard_pininfo(b, 38, 187, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO6A3:I2S_SDI", -1, 6, 3);
            mraa_tinkerboard_pininfo(b, 39,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 40, 188, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO6A4:I2S_SDO0", -1, 6, 4);
        }
        else if (mraa_file_contains(DT_BASE "/model", PLATFORM_NAME_TINKER_EDGE_T)) {
            b->phy_pin_count = MRAA_TINKEREDGET_PIN_COUNT + 1;
            b->platform_name = PLATFORM_NAME_TINKER_EDGE_T;
            b->uart_dev[0].device_path = (char*) tinkeredget_serialdev[0];
            b->uart_dev[1].device_path = (char*) tinkeredget_serialdev[1];
            b->chardev_capable = 1;

            // UART
            b->uart_dev_count = MRAA_TINKEREDGET_UART_COUNT;
            b->def_uart_dev = 0;
            b->uart_dev[0].index = 0;
            b->uart_dev[1].index = 2;

            // I2C
            if (strncmp(b->platform_name, PLATFORM_NAME_TINKER_EDGE_T, MAX_SIZE) == 0) {
                b->i2c_bus_count = MRAA_TINKEREDGET_I2C_COUNT;
                b->def_i2c_bus = 0;
                b->i2c_bus[0].bus_id = 1;
                b->i2c_bus[1].bus_id = 2;
            }

            // SPI
            b->spi_bus_count = MRAA_TINKEREDGET_SPI_COUNT;
            b->def_spi_bus = 0;
            b->spi_bus[0].bus_id = 0;

            // PWM
            b->pwm_dev_count = MRAA_TINKEREDGET_PWM_COUNT;
            b->pwm_default_period = 500;
            b->pwm_max_period = 2147483;
            b->pwm_min_period = 1;
            b->pins = (mraa_pininfo_t*) malloc(sizeof(mraa_pininfo_t) * b->phy_pin_count);
            if (b->pins == NULL) {
                free(b->adv_func);
                free(b);
                return NULL;
            }
            b->pins[32].pwm.parent_id = 0;
            b->pins[32].pwm.mux_total = 0;
            b->pins[32].pwm.pinmap = 0;
            b->pins[33].pwm.parent_id = 1;
            b->pins[33].pwm.mux_total = 0;
            b->pins[33].pwm.pinmap = 0;
            b->pins[15].pwm.parent_id = 2;
            b->pins[15].pwm.mux_total = 0;
            b->pins[15].pwm.pinmap = 0;

            mraa_tinkerboard_pininfo(b, 0,   -1, (mraa_pincapabilities_t){0,0,0,0,0,0,0,0}, "INVALID");
            mraa_tinkerboard_pininfo(b, 1,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "3V3");
            mraa_tinkerboard_pininfo(b, 2,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "5V");
            mraa_tinkerboard_pininfo(b, 3,  145, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO5IO17:I2C2SDA", -1, 4, 17);
            mraa_tinkerboard_pininfo(b, 4,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "5V");
            mraa_tinkerboard_pininfo(b, 5,  144, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO5IO16:I2C2SCL", -1, 4, 16);
            mraa_tinkerboard_pininfo(b, 6,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 7,  155, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO5IO27:UART3TX", -1, 4, 27);
            mraa_tinkerboard_pininfo(b, 8,  151, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO5IO23:UART1TX", -1, 4, 23);
            mraa_tinkerboard_pininfo(b, 9,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 10, 150, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO5IO22:UART1RX", -1, 4, 22);
            mraa_tinkerboard_pininfo(b, 11, 154, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO5IO26:UART3RX", -1, 4, 26);
            mraa_tinkerboard_pininfo(b, 12, 107, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO4IO11:SAI1TXC", -1, 3, 11);
            mraa_tinkerboard_pininfo(b, 13,   6, (mraa_pincapabilities_t){1,1,0,0,1,0,0,1}, "GPIO1IO06", -1, 0, 6);
            mraa_tinkerboard_pininfo(b, 14,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 15, 130, (mraa_pincapabilities_t){1,1,1,0,0,0,0,0}, "GPIO5IO02:PWM4", -1, 4, 2);
            mraa_tinkerboard_pininfo(b, 16,  73, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO3IO09", -1, 2, 9);
            mraa_tinkerboard_pininfo(b, 17,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "3V3");
            mraa_tinkerboard_pininfo(b, 18, 138, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO5IO10", -1, 4, 10);
            mraa_tinkerboard_pininfo(b, 19, 135, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO5IO07:SPI1MOSI", -1, 4, 7);
            mraa_tinkerboard_pininfo(b, 20,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 21, 136, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO5IO08:SPI1MISO", -1, 4, 8);
            mraa_tinkerboard_pininfo(b, 22, 140, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO5IO12", -1, 4 ,12);
            mraa_tinkerboard_pininfo(b, 23, 134, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO5IO06:SPI1SCLK", -1, 4, 6);
            mraa_tinkerboard_pininfo(b, 24, 137, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO5IO09:SPI1SS0", -1, 4, 9);
            mraa_tinkerboard_pininfo(b, 25,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 26,  66, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO3IO02:SPI1SS1", -1, 2, 2);
            mraa_tinkerboard_pininfo(b, 27, 147, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO5IO19:I2C3SDA", -1, 4, 19);
            mraa_tinkerboard_pininfo(b, 28, 146, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO5IO18:I2C3SCL", -1, 4, 18);
            mraa_tinkerboard_pininfo(b, 29,   7, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO1IO07", -1, 0, 7);
            mraa_tinkerboard_pininfo(b, 30,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 31,   8, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO1IO08", -1, 0, 8);
            mraa_tinkerboard_pininfo(b, 32,   1, (mraa_pincapabilities_t){1,1,1,0,0,0,0,0}, "GPIO1IO01:PWM1", -1, 0, 1);
            mraa_tinkerboard_pininfo(b, 33,  13, (mraa_pincapabilities_t){1,1,1,0,0,0,0,0}, "GPIO1IO13:PWM2", -1, 0, 13);
            mraa_tinkerboard_pininfo(b, 34,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 35, 106, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO4IO10:SAI1TXFS", -1, 3, 10);
            mraa_tinkerboard_pininfo(b, 36, 141, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO5IO13", -1, 4, 13);
            mraa_tinkerboard_pininfo(b, 37,  77, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO3IO13", -1, 2, 13);
            mraa_tinkerboard_pininfo(b, 38,  98, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO4IO02:SAI1RXD0", -1, 3, 2);
            mraa_tinkerboard_pininfo(b, 39,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 40, 108, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO4IO12:SAI1TXD0", -1, 3, 12);
        }
        else if (mraa_file_contains(DT_BASE "/model", PLATFORM_NAME_TINKER_EDGE_R)) {
            b->phy_pin_count = MRAA_TINKEREDGER_PIN_COUNT + 1;
            b->platform_name = PLATFORM_NAME_TINKER_EDGE_R;
            b->uart_dev[0].device_path = (char*) tinkeredger_serialdev[0];
            b->uart_dev[1].device_path = (char*) tinkeredger_serialdev[1];
            b->chardev_capable = 1;

            // UART
            b->uart_dev_count = MRAA_TINKEREDGER_UART_COUNT;
            b->def_uart_dev = 0;
            b->uart_dev[0].index = 0;
            b->uart_dev[1].index = 4;

            // I2C
            if (strncmp(b->platform_name, PLATFORM_NAME_TINKER_EDGE_R, MAX_SIZE) == 0) {
                b->i2c_bus_count = MRAA_TINKEREDGER_I2C_COUNT;
                b->def_i2c_bus = 0;
                b->i2c_bus[0].bus_id = 6;
                b->i2c_bus[1].bus_id = 7;
            }

            // SPI
            b->spi_bus_count = MRAA_TINKEREDGER_SPI_COUNT;
            b->def_spi_bus = 0;
            b->spi_bus[0].bus_id = 1;
            b->spi_bus[1].bus_id = 5;

            // PWM
            b->pwm_dev_count = MRAA_TINKEREDGER_PWM_COUNT;
            b->pwm_default_period = 500;
            b->pwm_max_period = 2147483;
            b->pwm_min_period = 1;
            b->pins = (mraa_pininfo_t*) malloc(sizeof(mraa_pininfo_t) * b->phy_pin_count);
            if (b->pins == NULL) {
                free(b->adv_func);
                free(b);
                return NULL;
            }
            b->pins[32].pwm.parent_id = 0;
            b->pins[32].pwm.mux_total = 0;
            b->pins[32].pwm.pinmap = 0;
            b->pins[33].pwm.parent_id = 1;
            b->pins[33].pwm.mux_total = 0;
            b->pins[33].pwm.pinmap = 0;
            b->pins[26].pwm.parent_id = 3;
            b->pins[26].pwm.mux_total = 0;
            b->pins[26].pwm.pinmap = 0;

            mraa_tinkerboard_pininfo(b, 0,   -1, (mraa_pincapabilities_t){0,0,0,0,0,0,0,0}, "INVALID");
            mraa_tinkerboard_pininfo(b, 1,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "3V3");
            mraa_tinkerboard_pininfo(b, 2,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "5V");
            mraa_tinkerboard_pininfo(b, 3,   73, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO2B1:I2C6SDA");
            mraa_tinkerboard_pininfo(b, 4,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "5V");
            mraa_tinkerboard_pininfo(b, 5,   74, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO2B2:I2C6SCL");
            mraa_tinkerboard_pininfo(b, 6,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 7,   89, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO2D1:TESTCLK1");
            mraa_tinkerboard_pininfo(b, 8,   81, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO2C1:UART0TXD");
            mraa_tinkerboard_pininfo(b, 9,   -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 10,  80, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO2C0:UART0RXD");
            mraa_tinkerboard_pininfo(b, 11,  83, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO2C3:UART0RTSN");
            mraa_tinkerboard_pininfo(b, 12, 120, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO3D0:I2S0SCLK");
            mraa_tinkerboard_pininfo(b, 13,  85, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO2C5:SPI5TX");
            mraa_tinkerboard_pininfo(b, 14,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 15,  84, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO2C4:SPI5RX");
            mraa_tinkerboard_pininfo(b, 16,  86, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO2C6:SPI5CLK");
            mraa_tinkerboard_pininfo(b, 17,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "3V3");
            mraa_tinkerboard_pininfo(b, 18,  87, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO2C7:SPI5CSN0");
            mraa_tinkerboard_pininfo(b, 19,  40, (mraa_pincapabilities_t){1,1,0,0,1,0,0,1}, "GPIO1B0:SPI1TX:UART4TXD");
            mraa_tinkerboard_pininfo(b, 20,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 21,  39, (mraa_pincapabilities_t){1,1,0,0,1,0,0,1}, "GPIO1A7:SPI1RX:UART4RXD");
            mraa_tinkerboard_pininfo(b, 22, 124, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO3D4:I2S0SDO3");
            mraa_tinkerboard_pininfo(b, 23,  41, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO1B1:SPI1CLK");
            mraa_tinkerboard_pininfo(b, 24,  42, (mraa_pincapabilities_t){1,1,0,0,1,0,0,0}, "GPIO1B2:SPI1CSN0");
            mraa_tinkerboard_pininfo(b, 25,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 26,   6, (mraa_pincapabilities_t){1,1,1,0,0,0,0,0}, "GPIO0A6:PWM3A");
            mraa_tinkerboard_pininfo(b, 27,  71, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO2A7:I2C7SDA");
            mraa_tinkerboard_pininfo(b, 28,  72, (mraa_pincapabilities_t){1,1,0,0,0,1,0,0}, "GPIO2B0:I2C7SCL");
            mraa_tinkerboard_pininfo(b, 29, 126, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO3D6:I2S0SDO1");
            mraa_tinkerboard_pininfo(b, 30,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 31, 125, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO3D5:I2S0SDO2");
            mraa_tinkerboard_pininfo(b, 32, 146, (mraa_pincapabilities_t){1,1,1,0,0,0,0,0}, "GPIO4C2:PWM0");
            mraa_tinkerboard_pininfo(b, 33, 150, (mraa_pincapabilities_t){1,1,1,0,0,0,0,0}, "GPIO4C6:PWM1");
            mraa_tinkerboard_pininfo(b, 34,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 35, 121, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO3D1:I2S0RX");
            mraa_tinkerboard_pininfo(b, 36,  82, (mraa_pincapabilities_t){1,1,0,0,0,0,0,1}, "GPIO2C2:UART0CTSN");
            mraa_tinkerboard_pininfo(b, 37, 149, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO4C5:SPDIFTX");
            mraa_tinkerboard_pininfo(b, 38, 123, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO3D3:I2S1SDI0");
            mraa_tinkerboard_pininfo(b, 39,  -1, (mraa_pincapabilities_t){1,0,0,0,0,0,0,0}, "GND");
            mraa_tinkerboard_pininfo(b, 40, 127, (mraa_pincapabilities_t){1,1,0,0,0,0,0,0}, "GPIO3D7:I2S1SDO0");
        }
    }
    syslog(LOG_ERR, "mraa_tinkerboard : %s ---", b->platform_name);
    return b;
}
