#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <stdlib.h>
#include <strings.h>
#include <string.h>
#include <poll.h>
#include <getopt.h>
#include <time.h>
#include <linux/serial.h>
#include <errno.h>

/*
 * glibc for MIPS has its own bits/termios.h which does not define
 * CMSPAR, so we vampirise the value from the generic bits/termios.h
 */
#ifndef CMSPAR
#define CMSPAR 010000000000
#endif

int fd1 = -1;
int fd2 = -1;
int DATA_SIZE = 1024;
int baud = B115200;

char *_cl_port1 = NULL;
char *_cl_port2 = NULL;
int _debug_detail = 0;
int _test_pass = 0;
int _cl_2_stop_bit = 0;
int _cl_rts_cts = 0;

int _1to2 = 0;
int _2to1 = 0;
int _1to1 = 0;

int _com1_write = 0;
int _com1_read = 0;
int _com2_write = 0;
int _com2_read = 0;
int _com2_read_2 = 0;

static void debug_print(char *message){
    if(_debug_detail == 1)
        printf("%s", message);
}

static void process_options(int argc, char * argv[])
{
	for (;;) {
		int c = getopt(argc, argv, "Bdfp:123");

		if (c == EOF) {
			break;
		}

		switch (c) {
			case 0:
            case 'B':
				_cl_2_stop_bit = 1;
				break;
			case 'd':
				_debug_detail = 1;
				break;
            case 'f':
                _cl_rts_cts = 1;
                break;
            case 'p':
                _cl_port1 = strdup(optarg);
                _cl_port2 = strdup(argv[optind]);
                break;
			case '1':
				_1to2 = 1;
	            break;
	        case '2':
				_2to1 = 1;
                break;
            case '3':
				_1to1 = 1;
	            break;
		}
	}
}

static unsigned char next_count_value(unsigned char c)
{
	c++;
	return c;
}

static int setup_serial_port(int baud, char *port)
{
	struct termios newtio;
	int _fd = -1;

	_fd = open(port, O_RDWR | O_NONBLOCK);

	if (_fd < 0) {
		printf("Error opening serial port");
		//free(_cl_port);
		exit(1);
	}

	bzero(&newtio, sizeof(newtio)); /* clear struct for new port settings */


	newtio.c_cflag = baud | CS8 | CLOCAL | CREAD;

    if (_cl_rts_cts) {
        newtio.c_cflag |= CRTSCTS;
    }

    if (_cl_2_stop_bit) {
		newtio.c_cflag |= CSTOPB;
	}

	newtio.c_iflag = 0;
	newtio.c_oflag = 0;
	newtio.c_lflag = 0;

	// block for up till 128 characters
	newtio.c_cc[VMIN] = 128;

	// 0.5 seconds read timeout
	newtio.c_cc[VTIME] = 5;

	/* now clean the modem line and activate the settings for the port */
	tcflush(_fd, TCIOFLUSH);
	tcsetattr(_fd, TCSANOW, &newtio);

	return _fd;
}


static int COM_write(int fd){

	unsigned char _write_count_value = 0;
	unsigned char * _write_data;
	ssize_t _write_size = DATA_SIZE;

	_write_data = malloc(_write_size);
	ssize_t i;
	for (i = 0; i < _write_size; i++) {
		_write_data[i] = _write_count_value;
		_write_count_value = next_count_value(_write_count_value);
	}

	if (_debug_detail == 1)
	{
		printf("Write data : ");
		for (i = 0; i < _write_size; i++){
			printf("%d ", (int)_write_data[i]);
		}
		printf("\n");
	}

	ssize_t c = write(fd, _write_data, _write_size);
	if (c < 0) {
		free(_write_data);
		return -1;
	}
	free(_write_data);
	return 0;
}

static int COM_read(int fd){

	unsigned char _read_count_value = 0;
	long long int _error_count = 0;
	unsigned char rb[DATA_SIZE];

	int c = read(fd, &rb, sizeof(rb));
	if (c > 0) {
		int i;

		if(_debug_detail == 1){
			printf("Read exit : ");
			for (i = 0; i < DATA_SIZE; i++){
				printf("%d ", (int)rb[i]);
			}
			printf("\n");
		}

		for (i = 0; i < c; i++) {
			if (rb[i] != _read_count_value) {
				//printf("Error, count: %d, expected %02x, got %02x\n",
						//i, _read_count_value, rb[i]);
				_error_count++;
				//****************************************
				if (_error_count > 0) {
					//printf("Receive Error!\n");
					//exit(1);
					return -1;
				}
				//****************************************
				_read_count_value = rb[i];
			}
			_read_count_value = next_count_value(_read_count_value);
		}
	}
	else
		return -1;

	return 0;
}

int main(int argc, char * argv[])
{
	int ret = -1;

	process_options(argc, argv);

	fd1 = setup_serial_port(baud, _cl_port1);
	if (_1to1 != 1)
		fd2 = setup_serial_port(baud, _cl_port2);

	int status;

	if (_1to2 == 1){
		if ((ret =COM_write(fd1)) >= 0)
			_com1_write = 1;
		sleep(1);
		if ((ret =COM_read(fd2)) >= 0)
			_com2_read = 1;
		if (_com1_write == 0 && _com2_read == 0)
			printf("Error: %s write fail, %s read fail", _cl_port1, _cl_port2);
		else if(_com1_write == 0)
			printf("Error: %s write fail", _cl_port1);
		else if(_com2_read == 0)
			printf("Error: %s read fail", _cl_port2);
		else
			printf("PASS");
		return 0;
	}
	else if (_2to1 == 1){
		if ((ret =COM_write(fd2)) >= 0)
			_com2_write = 1;
		sleep(1);
		if ((ret =COM_read(fd1)) >= 0)
			_com1_read = 1;
		if (_com2_write == 0 && _com1_read == 0)
			printf("Error: %s write fail, %s read fail", _cl_port2, _cl_port1);
		else if(_com2_write == 0)
			printf("Error: %s write fail", _cl_port2);
		else if(_com1_read == 0)
			printf("Error: %s read fail", _cl_port1);
		else
			printf("PASS");
		return 0;
	}
    else if (_1to1 == 1){
		if ((ret =COM_write(fd1)) >= 0)
			_com1_write = 1;
		sleep(1);
		if ((ret =COM_read(fd1)) >= 0)
			_com1_read = 1;
		if (_com1_write == 0 && _com1_read == 0)
			printf("Error: %s write fail, %s read fail", _cl_port1, _cl_port1);
		else if(_com1_write == 0)
			printf("Error: %s write fail", _cl_port1);
		else if(_com1_read == 0)
			printf("Error: %s read fail", _cl_port1);
		else
			printf("PASS");
		return 0;
	}
	else{
		if ((ret =COM_write(fd1)) >= 0)
			_com1_write = 1;
		sleep(1);
		if ((ret =COM_read(fd2)) >= 0)
			_com2_read = 1;

		sleep(1);

		if ((ret =COM_write(fd2)) >= 0)
			_com2_write = 1;
		sleep(1);
		if ((ret =COM_read(fd1)) >= 0)
			_com1_read = 1;
	}

	if(_com1_write == 1 && _com1_read == 1 && _com2_write == 1 && _com2_read == 1)
		_test_pass = 1;

	tcdrain(fd1);
	tcdrain(fd2);
	tcflush(fd1, TCIOFLUSH);
	tcflush(fd2, TCIOFLUSH);
	close(fd1);
	close(fd2);

test_end:
	if (_test_pass == 1)
		printf("PASS\n");
	else {
		printf("FAIL\n");
		if(_com1_write == 0)
			printf("COM1 write fail\n");
		if(_com1_read == 0)
			printf("COM1 read fail\n");
		if(_com2_write == 0)
			printf("COM2 write fail\n");
		if(_com2_read == 0)
			printf("COM2 read fail\n");
	}
	return 0;
}
