#include "wiringTB.h" 
#include <stdio.h> 
#include <stdlib.h> 
#include <sys/mman.h> 
#include <sys/stat.h> 
#include <fcntl.h> 
#include <errno.h> 
#include <stdint.h> 
#include <unistd.h> 
#include <string.h>

#define CONFIG_I2S_SHORT

#define	BLOCK_SIZE		(4*1024)
#define BLOCK_SIZE_64K		(64*1024)
#define BLOCK_SIZE_32K		(32*1024)

// Pin modes

#define	INPUT			 0
#define	OUTPUT			 1
#define	PWM_OUTPUT		 2
#define	GPIO_CLOCK		 3
#define	SOFT_PWM_OUTPUT		 4
#define	SOFT_TONE_OUTPUT	 5
#define	PWM_TONE_OUTPUT		 6


//jason add for asuspi
static int  mem_fd;
static void* gpio_map0[5];
static volatile unsigned* gpio0[5];

static void *grf_map;
static volatile unsigned *grf;

static void *pmugrf_map;
static volatile unsigned *pmugrf;

static void *pwm_map;
static volatile unsigned *pwm;

static void *pmu_map;
static volatile unsigned *pmu;

static void *cru_map;
static volatile unsigned *cru;

static void *pmucru_map;
static volatile unsigned *pmucru;

static const unsigned int rk3399pro_gpio[5] = { RK3399PRO_GPIO };

/* Format Convert*/
int* asus_get_physToGpio(int rev)
{
	DEBUG("asus_get_physToGpio\n");	

        static int RK3399_physToGpio_AP [64] =
        {
                -1,                     // 0
                -1,     -1,             //1, 2
                RK3399PRO_GPIO2_B1,       -1,             //3, 4
                RK3399PRO_GPIO2_B2,       -1,             //5, 6
                RK3399PRO_GPIO0_B0,       RK3399PRO_GPIO2_C1,       //7, 8
                -1,     RK3399PRO_GPIO2_C0,       //9, 10
                RK3399PRO_GPIO2_C3,       RK3399PRO_GPIO3_D0,       //11, 12
                RK3399PRO_GPIO2_C5,       -1,             //13, 14
                RK3399PRO_GPIO2_C4,       RK3399PRO_GPIO2_C6,       //15, 16
                -1,     RK3399PRO_GPIO2_C7,       //17, 18
                RK3399PRO_GPIO1_B0,       -1,             //19, 20
                RK3399PRO_GPIO1_A7,       RK3399PRO_GPIO3_D4,       //21, 22
                RK3399PRO_GPIO1_B1,       RK3399PRO_GPIO1_B2,       //23, 24
                -1,             RK3399PRO_GPIO0_A6,       //25, 26
                RK3399PRO_GPIO2_A7,       RK3399PRO_GPIO2_B0,       //27, 28
                RK3399PRO_GPIO3_D6,       -1,             //29, 30
                RK3399PRO_GPIO3_D5,       RK3399PRO_GPIO4_C2,       //31, 32
                RK3399PRO_GPIO4_C6,       -1,             //33, 34
                RK3399PRO_GPIO3_D1,       RK3399PRO_GPIO2_C2,       //35, 36
                RK3399PRO_GPIO4_C5,       RK3399PRO_GPIO3_D3,       //37, 38
                -1,     RK3399PRO_GPIO3_D7,       //39, 40
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, //4$
                -1, -1, -1, -1, -1, -1, -1, -1 // 56-> 63
        } ;


	return RK3399_physToGpio_AP;
}
int* asus_get_pinToGpio(int rev)
{
	DEBUG("asus_get_pinToGpio\n");

        static int RK3399_pinToGpio_AP [64] =
        {
                RK3399PRO_GPIO2_C3,          RK3399PRO_GPIO3_D0,        //0, 1
                RK3399PRO_GPIO2_C5,          RK3399PRO_GPIO2_C4,        //2, 3
                RK3399PRO_GPIO2_C6,          RK3399PRO_GPIO2_C7,        //4, 5
                RK3399PRO_GPIO3_D4,          RK3399PRO_GPIO0_B0,        //6, 7
                RK3399PRO_GPIO2_B1,          RK3399PRO_GPIO2_B2,        //8, 9
                RK3399PRO_GPIO1_B2,          RK3399PRO_GPIO0_A6,        //10, 11
                RK3399PRO_GPIO1_B0,          RK3399PRO_GPIO1_A7,        //12, 13
                RK3399PRO_GPIO1_B1,          RK3399PRO_GPIO2_C1,        //14, 15
                RK3399PRO_GPIO2_C0,          -1,              //16, 17
                -1,                -1,              //18, 19
                -1,                RK3399PRO_GPIO3_D6,        //20, 21
                RK3399PRO_GPIO3_D5,          RK3399PRO_GPIO4_C6,        //22, 23
                RK3399PRO_GPIO3_D1,          RK3399PRO_GPIO4_C5,        //24, 25
                RK3399PRO_GPIO4_C2,          RK3399PRO_GPIO2_C2,        //26, 27
                RK3399PRO_GPIO3_D3,          RK3399PRO_GPIO3_D7,        //28. 29
                RK3399PRO_GPIO2_A7,          RK3399PRO_GPIO2_B0,        //30, 31
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // ... 47
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, // ... 63
        } ;
        return RK3399_pinToGpio_AP;
}

int bankPinToNumGroup(int bank_pin);

int rk3399pro_pud_2_tb_format(int bank, int pud, int bank_pin)
{
	DEBUG("rk3399pro_pud_2_tb_format\n");
	int NumGroup = bankPinToNumGroup(bank_pin);	
	DEBUG("rk3399pro_pud_2_tb_format: NumGroup=%d\n",NumGroup);
	if (bank == 0) {
		//GPIO0A_P GPIO0B_P
        	switch(pud)
        	{
                	case 0:
                        	return 0b00;	// Z (Normal operation)
                	case 1:
                        	return 0b01;	// weak 0 (pull-down)
                	case 2:
                        	return 0b11;	// weak 1 (pull-up)
                	default:
                        	return 0;
        	}
	} else if (bank == 1) {
		//GPIO1A_P GPIO1B_P GPIO1C_P GPIO1D_P
                switch(pud)
                {
                        case 0:
                                return 0b00;    // Z
                        case 1:
                                return 0b10;	// pull-down
                        case 2:
                                return 0b01;	// pull-up
                        default:
                                return 0;
                }
	} else if (bank == 2) {
		switch(NumGroup)
		{
			case 0: //GPIO2A_P
                		switch(pud)
                		{
                        		case 0:
                                		return 0b00;    // Z
                        		case 1:
                                		return 0b10;	// pull-down
                        		case 2:
                                		return 0b01;	// pull-up
                        		default:
                                		return 0;
                		}
			case 1: //GPIO2B_P
                		switch(pud)
                		{
                        		case 0:
                                		return 0b00;	// Z
                        		case 1:
                                		return 0b10;	// pull-down
                        		case 2:
                                		return 0b01;	// pull-up
                        		default:
                                		return 0;
                		}
			case 2: //GPIO2C_P
                		switch(pud)
                		{
                        		case 0:
                                		return 0b00;	// Z
                        		case 1:
                                		return 0b01;	// pull-down
                        		case 2:
                                		return 0b11;	// pull-up
                        		default:
                                		return 0;
                		}
			case 3: //GPIO2D_P
                		switch(pud)
                		{
                        		case 0:
                                		return 0b00;	// Z
                        		case 1:
                                		return 0b01;	// pull-down
                        		case 2:
                                		return 0b11;	// pull-up
                        		default:
                                		return 0;
                		}
                        default:
                           	return 0;	
		}
	} else if (bank == 3) {
		//GPIO3A_P GPIO3B_P GPIO3C_P GPIO3D_P
                switch(pud)
                {
                        case 0:
                                return 0b00;    // Z
                        case 1:
                                return 0b10;	// pull-down
                        case 2:
                                return 0b01;	// pull-up
                        default:
                                return 0;
                }
	} else {
                switch(pud)
                {
                        case 0:
                                return 0b00;
                        case 1:
                                return 0b10;
                        case 2:
                                return 0b01;
                        default:
                                return 0;
                }
	}
}

int alt_2_tb_format(int alt)
{
	DEBUG("alt_2_tb_format\n");
	switch(alt)
	{
		case FSEL_INPT:
		case FSEL_OUTP:
		case FSEL_ALT0:
			return 0;
		case FSEL_ALT1:
			return 1;
		case FSEL_ALT2:
			return 2;
		case FSEL_ALT3:
			return 3;
		case FSEL_ALT4:
			return 4;
		case FSEL_ALT5:
			return 5;
		default:
			return -1;
	}
}

/* Register Offset Table */
int GET_PULL_OFFSET(int bank, int pin)
{
	DEBUG("GET_PULL_OFFSET\n");

        int PULL_TABLE [5][4] =
        {
                {RK3399PRO_PMUGRF_GPIO0A_P, RK3399PRO_PMUGRF_GPIO0B_P,           -1,           -1},       //Bank 0
                {RK3399PRO_PMUGRF_GPIO1A_P, RK3399PRO_PMUGRF_GPIO1B_P,           -1,           -1},       //Bank 1
                {RK3399PRO_GRF_GPIO2A_P, RK3399PRO_GRF_GPIO2B_P,RK3399PRO_GRF_GPIO2C_P,           -1},       //Bank 2
                {           -1,           -1,           -1, RK3399PRO_GRF_GPIO3D_P},       //Bank 3
                {           -1,           -1, RK3399PRO_GRF_GPIO4C_P,           -1},       //Bank 4
        } ;
	return PULL_TABLE[bank][(int)(pin / 8)];

}

int GET_DRV_OFFSET(int bank, int pin)
{
	DEBUG("GET_DRV_OFFSET\n");

	int DRV_TABLE [5][4] =
        {
                {RK3399PRO_PMUGRF_GPIO0A_E,RK3399PRO_PMUGRF_GPIO0B_E,           -1,           -1},       //Bank 0
                {RK3399PRO_PMUGRF_GPIO1A_E, RK3399PRO_PMUGRF_GPIO1B_E,           -1,           -1},       //Bank 1
                {RK3399PRO_GRF_GPIO2A_E, RK3399PRO_GRF_GPIO2B_E,RK3399PRO_GRF_GPIO2C_E,           -1},       //Bank 2
                {           -1,           -1,           -1, RK3399PRO_GRF_GPIO3D_E},       //Bank 3
                {           -1,           -1, RK3399PRO_GRF_GPIO4C_E,           -1},       //Bank 4

        } ;
        return DRV_TABLE[bank][(int)(pin / 8)];
}

/* common */
int gpioToBank(int gpio)
{
	DEBUG("gpioToBank\n");

	//// rk3399pro ////
	return (int)(gpio / 32);
}

int gpioToBankPin(int gpio)
{
	DEBUG("gpioToBankPin\n");

	return (int) (gpio %  32);
}

int bankPinToNumGroup(int bank_pin)
{
	DEBUG("bankPinToNumGroup");

	return (int) (bank_pin / 8); 
}

int tinker_board_setup(int rev)
{
	int i;
	DEBUG("tinker_board_setup\n");
	if ((mem_fd = open("/dev/mem", O_RDWR|O_SYNC) ) < 0)
	{
		if ((mem_fd = open ("/dev/gpiomem", O_RDWR | O_SYNC | O_CLOEXEC) ) < 0)
		{
			printf("can't open /dev/mem and /dev/gpiomem\n");
			printf("wiringPiSetup: Unable to open /dev/mem and /dev/gpiomem: %s\n", strerror (errno));
			return -1;
		}
    	}
	/////////////mmap GPIO////////////
	for(i=0;i<5;i++)
    	{
		unsigned int gpio_block_size;
		gpio_block_size = (i < 2) ? BLOCK_SIZE_64K:BLOCK_SIZE_32K;
		DEBUG("tinker_board_setup:rk3399pro[%d]=%x\n",i,rk3399pro_gpio[i]);
		gpio_map0[i] = mmap(
			NULL,             // Any adddress in our space will do
			gpio_block_size,       // Map length
			PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory
			MAP_SHARED,       // Shared with other processes
			mem_fd,           // File to map
			rk3399pro_gpio[i]         //Offset to GPIO peripheral
		);
		if (gpio_map0[i] == MAP_FAILED)
		{
			printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
			return -1;
		}
		gpio0[i] = (volatile unsigned *)gpio_map0[i];
   	}
	/////////////mmap grf////////////
	grf_map = mmap(
		NULL,             // Any adddress in our space will do
		BLOCK_SIZE_64K,       // Map length
		PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory
		MAP_SHARED,       // Shared with other processes
		mem_fd,           // File to map
		RK3399PRO_GRF         //Offset to GPIO peripheral
	);
	if (grf_map  == MAP_FAILED)
	{
		printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
		return -1;
	}
    	grf = (volatile unsigned *)grf_map;
	////////////////////////////
	////////////mmap pmugrf/////
        pmugrf_map = mmap(
                NULL,             // Any adddress in our space will do
                BLOCK_SIZE_64K,       // Map length
                PROT_READ|PROT_WRITE, // Enable reading & writting to mapped me$
                MAP_SHARED,       // Shared with other processes
                mem_fd,           // File to map
                RK3399PRO_PMUGRF         //Offset to GPIO peripheral
        );
        if (pmugrf_map  == MAP_FAILED)
        {
                printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
                return -1;
        }
        pmugrf = (volatile unsigned *)pmugrf_map;

	////////////mmap pwm////////
	pwm_map = mmap(
		NULL,             // Any adddress in our space will do
		BLOCK_SIZE_64K,       // Map length
		PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory
		MAP_SHARED,       // Shared with other processes
		mem_fd,           // File to map
		RK3399PRO_PWM         //Offset to GPIO peripheral
	);
	if (pwm_map == MAP_FAILED)
	{
		printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
		return -1;
	}
    	pwm = (volatile unsigned *)pwm_map;
	////////////////////////////
	////////////mmap pmu//////////
	pmu_map = mmap(
		NULL,             // Any adddress in our space will do
		BLOCK_SIZE_64K,       // Map length
		PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory
		MAP_SHARED,       // Shared with other processes
		mem_fd,           // File to map
		RK3399PRO_PMU         //Offset to GPIO peripheral
	);
	if (pmu_map == MAP_FAILED)
	{
		printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
		return -1;
	}
    	pmu = (volatile unsigned *)pmu_map;
	///////////////////////////////
	////////////mmap cru//////////
	cru_map = mmap(
		NULL,             // Any adddress in our space will do
		BLOCK_SIZE_64K,       // Map length
		PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory
		MAP_SHARED,       // Shared with other processes
		mem_fd,           // File to map
		RK3399PRO_CRU         //Offset to GPIO peripheral
	);
	if (cru_map == MAP_FAILED)
	{
		printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
		return -1;
	}
	cru = (volatile unsigned *)cru_map;
        ////////////mmap pmucru//////////
        pmucru_map = mmap(
                NULL,             // Any adddress in our space will do
                BLOCK_SIZE_64K,       // Map length
                PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory
                MAP_SHARED,       // Shared with other processes
                mem_fd,           // File to map
                RK3399PRO_PMUCRU         //Offset to GPIO peripheral
        );
        if (pmucru_map == MAP_FAILED)
        {
                printf("wiringPiSetup: Unable to open /dev/mem: %s\n", strerror (errno));
                return -1;
        }
        pmucru = (volatile unsigned *)pmucru_map;
        ///////////////////////////////
	close(mem_fd); // No need to keep mem_fdcru open after mmap
	return 0;
}

int gpio_is_valid(int gpio)
{
	switch (gpio)
	{
		//RK3399PRO
		case RK3399PRO_GPIO2_B1:
		case RK3399PRO_GPIO2_B2:
		case RK3399PRO_GPIO0_B0:
		case RK3399PRO_GPIO2_C1:
		case RK3399PRO_GPIO2_C0:
		case RK3399PRO_GPIO2_C3:
		case RK3399PRO_GPIO3_D0:
		case RK3399PRO_GPIO2_C5:
		case RK3399PRO_GPIO2_C4:
		case RK3399PRO_GPIO2_C6:
		case RK3399PRO_GPIO2_C7:
		case RK3399PRO_GPIO1_B0:
		case RK3399PRO_GPIO1_A7:
		case RK3399PRO_GPIO3_D4:
		case RK3399PRO_GPIO1_B1:
		case RK3399PRO_GPIO1_B2:
		case RK3399PRO_GPIO0_A6:
		case RK3399PRO_GPIO2_A7:
		case RK3399PRO_GPIO2_B0:
		case RK3399PRO_GPIO3_D6:
		case RK3399PRO_GPIO3_D5:
		case RK3399PRO_GPIO4_C2:
		case RK3399PRO_GPIO4_C6:
		case RK3399PRO_GPIO3_D1:
		case RK3399PRO_GPIO2_C2:
		case RK3399PRO_GPIO4_C5:
		case RK3399PRO_GPIO3_D3:
		case RK3399PRO_GPIO3_D7:
			return 1;
		default:
			return 0;

	}
}

int gpio_clk_disable(int gpio)
{
	int bank, bank_clk_en;
	int write_bit, reg_offset;
	bank = gpioToBank(gpio);

	write_bit = ((bank == 0) || (bank == 1)) ? bank+3 : bank+1;
	reg_offset = ((bank == 0) || (bank == 1)) ? RK3399PRO_PMUCRU_CLKGATE_CON1 : RK3399PRO_CRU_CLKGATE_CON31;

	DEBUG("gpio_clk_disable: write_bit=%d,reg_offset=%x\n",write_bit,reg_offset);

        if ((bank == 0) || (bank == 1)) {
		bank_clk_en = (*(pmucru+reg_offset/4) >> write_bit) & 0x1;
		(*(pmucru+reg_offset/4)) = (*(pmucru+reg_offset/4) & ~(0x1 << write_bit))
						| (0x1 << (16 + write_bit));
		DEBUG("gpio_clk_disable: (*(pmucru+reg_offset))=%x\n",(*(pmucru+reg_offset/4)));
	} else {
		bank_clk_en = (*(cru+reg_offset/4) >> write_bit) & 0x1;
		(*(cru+reg_offset/4)) = (*(cru+reg_offset/4) & ~(0x1 << write_bit))
						| (0x1 << (16 + write_bit));
		DEBUG("gpio_clk_disable: (*(cru+reg_offset))=%x\n",(*(cru+reg_offset/4)));
	}

	return bank_clk_en;
}
void gpio_clk_recovery(int gpio, int flag)
{
	int bank;
	int write_bit, reg_offset;

	bank = gpioToBank(gpio);

        write_bit = ((bank == 0) || (bank == 1)) ? bank+3 : bank+1;
        reg_offset = ((bank == 0) || (bank == 1)) ? RK3399PRO_PMUCRU_CLKGATE_CON1 : RK3399PRO_CRU_CLKGATE_CON31;

	DEBUG("gpio_clk_disable: write_bit=%d,reg_offset=%x\n",write_bit,reg_offset);

        if ((bank == 0) || (bank == 1)) {
                (*(pmucru+reg_offset/4)) = (*(pmucru+reg_offset/4) | (flag << write_bit)) | (0x1 << (16 + write_bit));
		DEBUG("gpio_clk_disable: (*(pmucru+reg_offset))=%x\n",(*(pmucru+reg_offset/4)));
        } else {
                (*(cru+reg_offset/4)) = (*(cru+reg_offset/4) | (flag << write_bit)) | (0x1 << (16 + write_bit));
		DEBUG("gpio_clk_disable: (*(cru+reg_offset))=%x\n",(*(cru+reg_offset/4)));
        }


}
int asus_get_pin_mode(int pin)
{
	int value, func;
	int bank_clk_en;
	int bank, bank_pin;

	bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
	bank_clk_en = gpio_clk_disable(pin);

	DEBUG("gpio_clk_disable: pin=%d, bank=%d, bank_pin=%d, bank_clk_en=%d\n",pin, bank, bank_pin, bank_clk_en);

	switch(pin)
	{
		//RK3399PRO_GPIO0_A6
		case 6: value = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO0A_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			switch (value) {
				case 0:	func=GPIO;		break;
				case 1:	func=PWM;		break;
				case 2: func=PMU_DEBUG;		break;
				case 3: func=RESERVED;		break;
				default: func=-1;		break;
			}
			break;
		//RK3399PRO_GPIO0_B0
		case 8: value = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO0B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			switch (value) {
				case 0:	func=GPIO;		break;
				case 1:	func=SDMMC_WRPRT;		break;
				case 2: func=PMUM0_WFI;		break;
				case 3: func=CLKOUT;		break;
				default: func=-1;		break;
			}
			break;
		//RK3399PRO_GPIO1_A7
		case 39: value = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO1A_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			switch (value) {
				case 0: func=GPIO;		break;
				case 1: func=SERIAL;		break;
				case 2: func=SPI;		break;
				case 3: func=RESERVED;		break;
				default: func=-1;		break;
			}
			break;

		//RK3399PRO_PMUGRF_GPIO1B
		case 40: value = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO1B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			switch (value) {
				case 0: func=GPIO;		break;
				case 1: func=SERIAL;		break;
				case 2: func=SPI;		break;
				case 3: func=RESERVED;		break;
				default: func=-1;		break;
			}
			break;
		case 41:
		case 42:
			value = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO1B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			switch (value) {
				case 0: func=GPIO;		break;
				case 1: func=PMUM0_JTAG;	break;
				case 2: func=SPI;		break;
				case 3: func=RESERVED;		break;
				default: func=-1;		break;
			}
			break;
		//RK3399PRO_GRF_GPIO2A
		case 71: value = ((*(grf+RK3399PRO_GRF_GPIO2A_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			switch (value) {
				case 0: func=GPIO;		break;
				case 1: func=VOP_DATA;		break;
				case 2: func=I2C;		break;
				case 3: func=CIF;		break;
			}
			break;
		//RK3399PRO_GRF_GPIO2B
		case 72: value = ((*(grf+RK3399PRO_GRF_GPIO2B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			switch (value) {
				case 0: func=GPIO;		break;
				case 1: func=VOP;		break;
				case 2: func=I2C;		break;
				case 3:	func=CIF;		break;
			}
			break;
		case 73:
                case 74:
			value = ((*(grf+RK3399PRO_GRF_GPIO2B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        switch (value) {
                                case 0: func=GPIO;              break;
                                case 1: func=SPI;               break;
                                case 2: func=I2C;               break;
                                case 3: func=CIF;               break;
                        }
			break;
		//RK3399PRO_GRF_GPIO2C
               	case 80:
		case 81:
		case 82:
		case 83:
			value = ((*(grf+RK3399PRO_GRF_GPIO2C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        switch (value) {
                                case 0: func=GPIO;              break;
                                case 1: func=SERIAL;               break;
                                case 2: func=RESERVED;               break;
                                case 3: func=RESERVED;               break;
                        }
			break;
                case 84:
                case 85:
                case 86:
                case 87:
                        value = ((*(grf+RK3399PRO_GRF_GPIO2C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        switch (value) {
                                case 0: func=GPIO;              break;
                                case 1: func=SDIO;               break;
                                case 2: func=SPI;               break;
                                case 3: func=RESERVED;               break;
                        }
			break;
                //RK3399PRO_GRF_GPIO2D
                case 89:
                        value = ((*(grf+RK3399PRO_GRF_GPIO2D_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        switch (value) {
                                case 0: func=GPIO;              break;
                                case 1: func=SDIO;               break;
                                case 2: func=CLKOUT;               break;
                                case 3: func=RESERVED;               break;
                        }
                        break;
                //RK3399PRO_GRF_GPIO3D
                case 120:
                case 121:
		case 126:
                        value = ((*(grf+RK3399PRO_GRF_GPIO3D_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        switch (value) {
                                case 0: func=GPIO;              break;
                                case 1: func=I2S;               break;
                                case 2: func=TRACE_DATA;               break;
                                case 3: func=A72_WFI;               break;
                        }
                        break;
                case 122:
                case 123:
                case 124:
                case 125:
                case 127:
                        value = ((*(grf+RK3399PRO_GRF_GPIO3D_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        switch (value) {
                                case 0: func=GPIO;              break;
                                case 1: func=I2S;               break;
                                case 2: func=TRACE_DATA;               break;
                                case 3: func=A53_WFI;               break;
                        }
                        break;

                //RK3399PRO_GRF_GPIO4C
                case 146:
                        value = ((*(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        switch (value) {
                                case 0: func=GPIO;              break;
                                case 1: func=PWM;               break;
                                case 2: func=VOP0_PWM;               break;
                                case 3: func=VOP1_PWM;               break;
                        }
                        break;

                case 149:
                        value = ((*(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        switch (value) {
                                case 0: func=GPIO;              break;
                                case 1: func=SPDIF;               break;
                                case 2: func=RESERVED;               break;
                                case 3: func=RESERVED;               break;
                        }
                        break;

                case 150:
                        value = ((*(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        switch (value) {
                                case 0: func=GPIO;              break;
                                case 1: func=PWM;               break;
                                case 2: func=RESERVED;               break;
                                case 3: func=RESERVED;               break;
                        }
                        break;
                default:
                        func=-1; break;
	}
	if (func == GPIO)
	{
		if (*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DDR_OFFSET/4) & (1<<bank_pin))
                        func = OUTPUT;
                else
                        func = INPUT;

		DEBUG("*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DDR_OFFSET/4)=%x\n",
						*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DDR_OFFSET/4));
	}
	gpio_clk_recovery(pin, bank_clk_en);
	return func;
}

void asus_set_pinmode_as_gpio(int pin)
{

	DEBUG("asus_set_pinmode_as_gpio\n");
	switch(pin)
	{
		//RK3399PRO_GPIO0_A6
		case 6: *(pmugrf+RK3399PRO_PMUGRF_GPIO0A_IOMUX/4) =
				((*(pmugrf+RK3399PRO_PMUGRF_GPIO0A_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2+16)));
			break;
		//RK3399PRO_GPIO0_B0
		case 8: *(pmugrf+RK3399PRO_PMUGRF_GPIO0B_IOMUX/4) =
				((*(pmugrf+RK3399PRO_PMUGRF_GPIO0B_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2+16)));
			break;

		//RK3399PRO_GPIO1_A7
		case 39: *(pmugrf+RK3399PRO_PMUGRF_GPIO1A_IOMUX/4) =
                                ((*(pmugrf+RK3399PRO_PMUGRF_GPIO1A_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2+16)));
                        break;

		//RK3399PRO_PMUGRF_GPIO1B
		case 40:
		case 41:
		case 42:
			 *(pmugrf+RK3399PRO_PMUGRF_GPIO1B_IOMUX/4) =
                                ((*(pmugrf+RK3399PRO_PMUGRF_GPIO1B_IOMUX/4) & (~(0x03<<((pin%8)*2))))  | (0x03<<((pin%8)*2+16)));
                        break;

		//RK3399PRO_GRF_GPIO2A
		case 71: *(grf+RK3399PRO_GRF_GPIO2A_IOMUX/4) =
                                ((*(grf+RK3399PRO_GRF_GPIO2A_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2+16)));
                        break;

		//RK3399PRO_GRF_GPIO2B
		case 72:
		case 73:
		case 74:
			 *(grf+RK3399PRO_GRF_GPIO2B_IOMUX/4) =
                                ((*(grf+RK3399PRO_GRF_GPIO2B_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2+16)));
                        break;
		//RK3399PRO_GRF_GPIO2C
               	case 80:
		case 81:
		case 82:
		case 83:
		case 84:
		case 85:
		case 86:
		case 87:
			*(grf+RK3399PRO_GRF_GPIO2C_IOMUX/4) =
                                ((*(grf+RK3399PRO_GRF_GPIO2C_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2+16)));
                        break;

                //RK3399PRO_GRF_GPIO2D
                case 89:
			*(grf+RK3399PRO_GRF_GPIO2D_IOMUX/4) =
                                ((*(grf+RK3399PRO_GRF_GPIO2D_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2+16)));
                        break;

                //RK3399PRO_GRF_GPIO3D
                case 120:
                case 121:
		case 126:
                case 122:
                case 123:
                case 124:
                case 125:
                case 127:
			*(grf+RK3399PRO_GRF_GPIO3D_IOMUX/4) =
                                ((*(grf+RK3399PRO_GRF_GPIO3D_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2+16)));
                        break;

                //RK3399PRO_GRF_GPIO4C
                case 146:
		case 149:
		case 150:
                        *(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4) =
                                ((*(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4) & (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2+16)));
                        break;

		default:
			printf("wrong gpio\n");
			break;

	}	//switch(pin)

}

void asus_set_pin_mode(int pin, int mode)
{
	int bank_clk_en;
	int bank, bank_pin;

	if(!gpio_is_valid(pin))
		return;
	bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
	bank_clk_en = gpio_clk_disable(pin);
	DEBUG("asus_set_pin_mode: mode=%d, bank=%d, bank_pin=%d, bank_clk_en=%d\n",mode, bank, bank_pin, bank_clk_en);
	if(INPUT == mode)
	{
		asus_set_pinmode_as_gpio(pin);
		*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DDR_OFFSET/4) &= ~(1<<bank_pin);
	}
	else if(OUTPUT == mode)
	{
		asus_set_pinmode_as_gpio(pin);
		*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DDR_OFFSET/4) |= (1<<bank_pin);

	}
	else if(PWM_OUTPUT == mode)
	{
		//set pin PWMx to pwm mode
		if(pin == RK3399PRO_PWM0 || pin == RK3399PRO_PWM1)
		{
                        *(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4) =
                                (((*(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4) | (0x03<<((pin%8)*2+16)))
					& (~(0x02<<((pin%8)*2))))) | (0x01<<((pin%8)*2));
		}
		// RK3288 PWM3//
		/* else if(pin == PWM3)
		{
			*(grf+GRF_GPIO7CH_IOMUX/4) =  (*(grf+GRF_GPIO7CH_IOMUX/4) | (0x0f<<(16+(pin%8-4)*4))) | (0x03<<((pin%8-4)*4));
		}*/
		else if(pin == RK3399PRO_PWM3)
                {
                        *(pmugrf+RK3399PRO_PMUGRF_GPIO0A_IOMUX/4) =
                                (((*(pmugrf+RK3399PRO_PMUGRF_GPIO0A_IOMUX/4) | (0x03<<((pin%8)*2+16)))
						& (~(0x02<<((pin%8)*2))))) | (0x01<<((pin%8)*2));
                }
		else
		{
			printf("This pin cannot set as pwm out\n");
		}
	}
	else if(GPIO_CLOCK == mode)
	{
		if(pin == RK3399PRO_GPIO0_B0)
		{
			(*(pmugrf+RK3399PRO_PMUGRF_GPIO0B_IOMUX/4) = (((*(pmugrf+RK3399PRO_PMUGRF_GPIO0B_IOMUX/4) | (0x03<<((pin%8)*2+16)))) 
									& (~(0x03<<((pin%8)*2)))) | (0x03<<((pin%8)*2)));
			*(cru+RK3399PRO_CRU_CLKGATE_CON13/4) = (*(cru+RK3399PRO_CRU_CLKGATE_CON13/4) & (~(0x1)<<15))
									| 0x1 << (16+15) | ( 0<<15);
		}
		else
			printf("This pin cannot set as gpio clock\n");
	}
	gpio_clk_recovery(pin, bank_clk_en);
}

void asus_digitalWrite(int pin, int value)
{
	int bank_clk_en;
	int bank, bank_pin;

	DEBUG("asus_digitalWrite: pin=%d,value=%d\n",pin,value);
	if(!gpio_is_valid(pin))
		return;
	bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
	bank_clk_en = gpio_clk_disable(pin);
	DEBUG("pin=%d, value=%d, bank=%d, bank_pin=%d, bank_clk_en=%d\n", pin, value, bank, bank_pin, bank_clk_en);
	if(value > 0)
	{
		*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DR_OFFSET/4) |= (1<<bank_pin);
	}
	else
	{
		*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DR_OFFSET/4) &= ~(1<<bank_pin);
	}
	gpio_clk_recovery(pin, bank_clk_en);
}

int asus_digitalRead(int pin)
{
	int value;
	int bank_clk_en;
	int bank, bank_pin;

	DEBUG("asus_digitalRead\n");

	bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
	bank_clk_en = gpio_clk_disable(pin);
	value = (((*(gpio0[bank]+RK3399PRO_GPIO_EXT_PORTA_OFFSET/4)) & (1 << bank_pin)) >> bank_pin);
	gpio_clk_recovery(pin, bank_clk_en);
	return value;
}

void asus_pullUpDnControl (int pin, int pud)
{
	int bank, bank_pin;
	int GPIO_P_offset;
	int write_bit;

	if(!gpio_is_valid(pin))
	{
		printf("wrong gpio\n");
		return;
	}
	bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
	GPIO_P_offset = GET_PULL_OFFSET(bank, bank_pin);
	printf("asus_pullUpDnControl: pin=%d, pud=%d, bank=%d, bank_pin=%d\n",pin, pud, bank,bank_pin);
	if(GPIO_P_offset == -1)
	{
		printf("wrong offset\n");
		return;
	}
	write_bit = (bank_pin % 8) << 1;
	pud = rk3399pro_pud_2_tb_format(bank, pud, bank_pin);
	if(bank == 0 || bank == 1)
	{
		*(pmugrf+GPIO_P_offset/4) = ((*(pmugrf+GPIO_P_offset/4) & (0b00 << write_bit)) | (pud << write_bit))
								| (0b11 << (16 + write_bit));	//without write_en
	}
	else
	{
		*(grf+GPIO_P_offset/4) = ((*(grf+GPIO_P_offset/4) & (0b00 << write_bit)) | (pud << write_bit)) 
									| (0b11 << (16 + write_bit));
	}
}

int asus_get_pwm_value(int pin)
{
	unsigned int range;
	unsigned int value;
	int PWM_PERIOD_OFFSET = -1;
	int PWM_DUTY_OFFSET = -1;

	DEBUG("asus_get_pwm_value: pin=%d\n",pin);

	switch (pin)
        {
                case RK3399PRO_PWM0:
                        PWM_PERIOD_OFFSET=RK3399PRO_PWM0_PERIOD_HPR;
                        PWM_DUTY_OFFSET=RK3399PRO_PWM0_DUTY_LPR;
                        break;
                case RK3399PRO_PWM1:
                        PWM_PERIOD_OFFSET=RK3399PRO_PWM1_PERIOD_HPR;
                        PWM_DUTY_OFFSET=RK3399PRO_PWM1_DUTY_LPR;
                        break;
                case RK3399PRO_PWM3:
                        PWM_PERIOD_OFFSET=RK3399PRO_PWM3_PERIOD_HPR;
                        PWM_DUTY_OFFSET=RK3399PRO_PWM3_DUTY_LPR;
                        break;
                default:
                        break;
        }
        if(asus_get_pin_mode(pin)==PWM && PWM_PERIOD_OFFSET != -1 && PWM_DUTY_OFFSET != -1)
        {
                range = *(pwm+PWM_PERIOD_OFFSET/4);     //Get period
                value = range - *(pwm+PWM_DUTY_OFFSET/4); //Get duty
                return value;
        }
        else
        {
		printf("Get_PWM_value: please set this pin to pwmmode first\n");
                return -1; 
        }
}

void asus_set_pwmPeriod(int pin, unsigned int period)
{
	int pwm_value;
	int PWM_CTRL_OFFSET = -1;
	int PWM_PERIOD_OFFSET = -1;
	DEBUG("asus_set_pwmPeriod: pin=%d, period=%d\n", pin, period);
	switch (pin)
	{
		case RK3399PRO_PWM0:
			PWM_CTRL_OFFSET=RK3399PRO_PWM0_CTRL;
			PWM_PERIOD_OFFSET=RK3399PRO_PWM0_PERIOD_HPR;
			break;
		case RK3399PRO_PWM1:
			PWM_CTRL_OFFSET=RK3399PRO_PWM1_CTRL;
			PWM_PERIOD_OFFSET=RK3399PRO_PWM1_PERIOD_HPR;
			break;
		case RK3399PRO_PWM3:
			PWM_CTRL_OFFSET=RK3399PRO_PWM3_CTRL;
			PWM_PERIOD_OFFSET=RK3399PRO_PWM3_PERIOD_HPR;
			break;
		default:
			break;
	}
	if(asus_get_pin_mode(pin)==PWM && PWM_CTRL_OFFSET != -1 && PWM_PERIOD_OFFSET != -1)
	{
		pwm_value = asus_get_pwm_value(pin);
		*(pwm+PWM_CTRL_OFFSET/4) &= ~(1<<0);	//Disable PWM
		*(pwm+PWM_PERIOD_OFFSET/4) = period;	//Set period PWM
		*(pwm+PWM_CTRL_OFFSET/4) |= (1<<0); 	//Enable PWM
		if(pwm_value != -1)
			asus_pwm_write(pin, pwm_value);
	}
}

void asus_set_pwmRange(unsigned int range)
{
	DEBUG("asus_set_pwmRange: range=%d\n", range);
	asus_set_pwmPeriod(RK3399PRO_PWM0, range);
	asus_set_pwmPeriod(RK3399PRO_PWM1, range);
	asus_set_pwmPeriod(RK3399PRO_PWM3, range);
}

void asus_set_pwmFrequency(int pin, int divisor)
{
	int PWM_CTRL_OFFSET = -1;
	DEBUG("asus_set_pwmFrequency: pin=%d, divisor=%d\n", pin, divisor);
	switch (pin)
	{
		case RK3399PRO_PWM0:
			PWM_CTRL_OFFSET=RK3399PRO_PWM0_CTRL;
			break;
		case RK3399PRO_PWM1:
			PWM_CTRL_OFFSET=RK3399PRO_PWM1_CTRL;
			break;
		case RK3399PRO_PWM3:
			PWM_CTRL_OFFSET=RK3399PRO_PWM3_CTRL;
			break;
		default:
			break;
	}
	if (divisor > 0xff)
		divisor = 0x100;
	else if(divisor < 2)
		divisor = 0x02;
	if(asus_get_pin_mode(pin)==PWM && PWM_CTRL_OFFSET != -1)
	{
		*(pwm+PWM_CTRL_OFFSET/4) &= ~(1<<0);	//Disable PWM
		*(pwm+PWM_CTRL_OFFSET/4) = (*(pwm+PWM_CTRL_OFFSET/4) & ~(0xff << 16)) | ((0xff & (divisor/2)) << 16) | (1<<9) ;	//PWM div
		*(pwm+PWM_CTRL_OFFSET/4) |= (1<<0); //Enable PWM
	}
}


void asus_set_pwmClock(int divisor)
{
	DEBUG("asus_set_pwmClock: divisor=%d\n", divisor);
	asus_set_pwmFrequency(RK3399PRO_PWM0, divisor);
	asus_set_pwmFrequency(RK3399PRO_PWM1, divisor);
	asus_set_pwmFrequency(RK3399PRO_PWM3 , divisor);
}

void asus_pwm_write(int pin, int value)
{
	int mode = 0;
	unsigned int range;
	int PWM_CTRL_OFFSET = -1;
	int PWM_PERIOD_OFFSET = -1;
	int PWM_DUTY_OFFSET = -1;

	DEBUG("asus_pwm_write: pin=%d, value=%d\n", pin, value);

	switch (pin)
	{
		case RK3399PRO_PWM0:
			PWM_CTRL_OFFSET=RK3399PRO_PWM0_CTRL;
			PWM_PERIOD_OFFSET=RK3399PRO_PWM0_PERIOD_HPR;
			PWM_DUTY_OFFSET=RK3399PRO_PWM0_DUTY_LPR;
			break;
		case RK3399PRO_PWM1:
			PWM_CTRL_OFFSET=RK3399PRO_PWM1_CTRL;
			PWM_PERIOD_OFFSET=RK3399PRO_PWM1_PERIOD_HPR;
			PWM_DUTY_OFFSET=RK3399PRO_PWM1_DUTY_LPR;
			break;
		case RK3399PRO_PWM3:
			PWM_CTRL_OFFSET=RK3399PRO_PWM3_CTRL;
			PWM_PERIOD_OFFSET=RK3399PRO_PWM3_PERIOD_HPR;
			PWM_DUTY_OFFSET=RK3399PRO_PWM3_DUTY_LPR;
			break;
		default:
			break;
	}
	if(asus_get_pin_mode(pin)==PWM && PWM_CTRL_OFFSET != -1 && PWM_PERIOD_OFFSET != -1 && PWM_DUTY_OFFSET != -1)
	{
		range = *(pwm+PWM_PERIOD_OFFSET/4);
		*(pwm+PWM_CTRL_OFFSET/4) &= ~(1<<0);	//Disable PWM
		*(pwm+PWM_DUTY_OFFSET/4) = range - value; //Set duty
		if(mode == CENTERPWM)
		{
			*(pwm+PWM_CTRL_OFFSET/4) |= (1<<5);
		}
		else
		{
			*(pwm+PWM_CTRL_OFFSET/4) &= ~(1<<5);
		}
		*(pwm+PWM_CTRL_OFFSET/4) |= (1<<1);
		*(pwm+PWM_CTRL_OFFSET/4) &= ~(1<<2);
		*(pwm+PWM_CTRL_OFFSET/4) |= (1<<4);
		*(pwm+PWM_CTRL_OFFSET/4) |= (1<<0); //Enable PWM
	}
	else
	{
		printf("please set this pin to pwmmode first\n");
	}
}

void asus_pwmToneWrite(int pin, int freq)
{
	int divi, pwm_clock, range;
	DEBUG("asus_pwmToneWrite: pin=%d, freq=%d\n", pin, freq);
	switch (pin)
	{
		case RK3399PRO_PWM0:divi=((*(pwm+RK3399PRO_PWM0_CTRL/4) >> 16) & 0xff) << 1; break;
		case RK3399PRO_PWM1:divi=((*(pwm+RK3399PRO_PWM1_CTRL/4) >> 16) & 0xff) << 1; break;
		case RK3399PRO_PWM3:divi=((*(pwm+RK3399PRO_PWM3_CTRL/4) >> 16) & 0xff) << 1; break;
		default:divi=-1;break;
	}
	if(divi == 0)
		divi = 512;
	if (freq == 0)
		asus_pwm_write (pin, 0) ;
	else
	{
		pwm_clock = 48285715 / divi;		//48.28Mhz / divi
		range = pwm_clock / freq ;
		asus_set_pwmPeriod (pin, range) ;
		asus_pwm_write (pin, range / 2) ;
	}
}

void asus_set_gpioClockFreq(int pin, int freq)
{
	int divi;
	DEBUG("asus_set_gpioClockFreq: pin=%d, freq=%d\n", pin, freq);
	if(pin != RK3399PRO_GPIO0_B0)
	{
		printf("This pin cannot set as gpio clock\n");
		return;
	}
	// b0 clock_testout_src b1 xin_24m	
	divi = 24000000 / freq - 1;
	if (divi > 31) {
		divi = 31;
	} else if(divi < 0) {
		divi = 0;
	}
	DEBUG("asus_set_gpioClockFreq: divi=%d\n",divi);
	*(cru+RK3399PRO_CRU_CLKSEL_CON38/4) = (*(cru+RK3399PRO_CRU_CLKSEL_CON38/4) & (~(0x1F)))
									| 0x1f << (16) | (~(0x1f) | (divi));//(divi & 0x1f);

}

int asus_get_pinAlt(int pin)
{
	int alt;
	int bank_clk_en;
	int bank, bank_pin;
	bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
	bank_clk_en = gpio_clk_disable(pin);

	DEBUG("asus_get_pinAlt: pin=%d, bank=%d, bank_pin=%d, bank_clk_en=%d\n", pin, bank, bank_pin, bank_clk_en);
	switch(pin)
	{
		//RK3399PRO_GPIO0_A6
		case 6: alt = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO0A_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;

		//RK3399PRO_GPIO0_B0
		case 8: alt = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO0B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;

		//RK3399PRO_GPIO1_A7
		case 39: alt = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO1A_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;

		//RK3399PRO_PMUGRF_GPIO1B
		case 40: alt = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO1B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;
		case 41:
		case 42:
			alt = ((*(pmugrf+RK3399PRO_PMUGRF_GPIO1B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;
		//RK3399PRO_GRF_GPIO2A
		case 71: alt = ((*(grf+RK3399PRO_GRF_GPIO2A_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;
		//RK3399PRO_GRF_GPIO2B
		case 72: alt = ((*(grf+RK3399PRO_GRF_GPIO2B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;
		case 73:
                case 74:
			alt = ((*(grf+RK3399PRO_GRF_GPIO2B_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;
		//RK3399PRO_GRF_GPIO2C
               	case 80:
		case 81:
		case 82:
		case 83:
			alt = ((*(grf+RK3399PRO_GRF_GPIO2C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;
                case 84:
                case 85:
                case 86:
                case 87:
                        alt = ((*(grf+RK3399PRO_GRF_GPIO2C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
			break;
                //RK3399PRO_GRF_GPIO2D
                case 89:
                        alt = ((*(grf+RK3399PRO_GRF_GPIO2D_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        break;
                //RK3399PRO_GRF_GPIO3D
                case 120:
                case 121:
		case 126:
                        alt = ((*(grf+RK3399PRO_GRF_GPIO3D_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        break;
                case 122:
                case 123:
                case 124:
                case 125:
                case 127:
                        alt = ((*(grf+RK3399PRO_GRF_GPIO3D_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        break;

                //RK3399PRO_GRF_GPIO4C
                case 146:
                        alt = ((*(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        break;

                case 149:
                        alt = ((*(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        break;

                case 150:
                        alt = ((*(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4))>>((pin%8)*2)) & 0x00000003;
                        break;
		default:
			alt=-1;
			break;

	}
	//RPi alt ("   GPIO  "), "ALT0", "ALT1", "ALT2", "ALT3", "ALT4", "ALT5"
	//          0      1        2      3        4      5       6       7
	//RPi alt ("IN", "OUT"), "ALT5", "ALT4", "ALT0", "ALT1", "ALT2", "ALT3"
	int alts[7] = {0, FSEL_ALT0, FSEL_ALT1, FSEL_ALT2, FSEL_ALT3, FSEL_ALT4, FSEL_ALT5};
	if(alt < 7)
	{
		alt = alts[alt];
	}
    	if (alt == 0)
    	{
		if (*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DDR_OFFSET/4) & (1<<bank_pin))
			alt = FSEL_OUTP;
		else
			alt = FSEL_INPT;
    	}
	gpio_clk_recovery(pin, bank_clk_en);
	return alt;
}

void SetGpioMode(int pin, int alt)
{
	alt = ~alt & 0x3;
	DEBUG("SetGpioMode\n");
	switch(pin)
	{
		//RK3399PRO_GPIO0_A6
		case 6: *(pmugrf+RK3399PRO_PMUGRF_GPIO0A_IOMUX/4) =
				(*(pmugrf+RK3399PRO_PMUGRF_GPIO0A_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
			break;

		//RK3399PRO_GPIO0_B0
		case 8: *(pmugrf+RK3399PRO_PMUGRF_GPIO0B_IOMUX/4) =
				(*(pmugrf+RK3399PRO_PMUGRF_GPIO0B_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
			break;

		//RK3399PRO_GPIO1_A7
		case 39: *(pmugrf+RK3399PRO_PMUGRF_GPIO1A_IOMUX/4) =
                                (*(pmugrf+RK3399PRO_PMUGRF_GPIO1A_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
                        break;

		//RK3399PRO_PMUGRF_GPIO1B
		case 40:
		case 41:
		case 42:
			 *(pmugrf+RK3399PRO_PMUGRF_GPIO1B_IOMUX/4) =
                                (*(pmugrf+RK3399PRO_PMUGRF_GPIO1B_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
                        break;

		//RK3399PRO_GRF_GPIO2A
		case 71: *(grf+RK3399PRO_GRF_GPIO2A_IOMUX/4) =
                                (*(grf+RK3399PRO_GRF_GPIO2A_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
                        break;

		//RK3399PRO_GRF_GPIO2B
		case 72:
		case 73:
		case 74:
			 *(grf+RK3399PRO_GRF_GPIO2B_IOMUX/4) =
                                (*(grf+RK3399PRO_GRF_GPIO2B_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
                        break;
		//RK3399PRO_GRF_GPIO2C
               	case 80:
		case 81:
		case 82:
		case 83:
		case 84:
		case 85:
		case 86:
		case 87:
			*(grf+RK3399PRO_GRF_GPIO2C_IOMUX/4) =
                                (*(grf+RK3399PRO_GRF_GPIO2C_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
                        break;

                //RK3399PRO_GRF_GPIO2D
                case 89:
			*(grf+RK3399PRO_GRF_GPIO2D_IOMUX/4) =
                                (*(grf+RK3399PRO_GRF_GPIO2D_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
                        break;

                //RK3399PRO_GRF_GPIO3D
                case 120:
                case 121:
		case 126:
                case 122:
                case 123:
                case 124:
                case 125:
                case 127:
			*(grf+RK3399PRO_GRF_GPIO3D_IOMUX/4) =
                                (*(grf+RK3399PRO_GRF_GPIO3D_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
                        break;

                //RK3399PRO_GRF_GPIO4C
                case 146:
		case 149:
		case 150:
                        *(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4) =
                                (*(grf+RK3399PRO_GRF_GPIO4C_IOMUX/4) | (0x03<<((pin%8)*2+16))
					| (0x3 << ((pin % 8)*2))) & (~(alt<<((pin%8)*2)));
                        break;
                default:
                        printf("wrong gpio\n");
                        break;

	}
}

void asus_set_pinAlt(int pin, int alt)
{
	int bank_clk_en;
	int bank, bank_pin;
	int tb_format_alt;

	if(!gpio_is_valid(pin))
		return;
	bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
	tb_format_alt = alt_2_tb_format(alt);
	DEBUG("asus_set_pinAlt: pin=%d, alt=%d, tb_format_alt=%d\n", pin, alt, tb_format_alt);
	if(tb_format_alt == -1)
	{
		printf("wrong alt\n");
		return;
	}
	bank_clk_en = gpio_clk_disable(pin);
	SetGpioMode(pin, tb_format_alt);
	if(alt == FSEL_INPT)
	{
		*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DDR_OFFSET/4) &= ~(1<<bank_pin);
	}
	else if(alt == FSEL_OUTP)
	{
		*(gpio0[bank]+RK3399PRO_GPIO_SWPORTA_DDR_OFFSET/4) |= (1<<bank_pin);
	}
	gpio_clk_recovery(pin, bank_clk_en);
}


//drv_type={0:2mA, 1:4mA, 2:8mA, 3:12mA}
void asus_set_GpioDriveStrength(int pin, int drv_type)
{
	int bank, bank_pin;
	int GPIO_E_offset;
	int write_bit;
	DEBUG("asus_set_GpioDriveStrength: pin=%d, drv_type=%d\n", pin, drv_type);
	if(!gpio_is_valid(pin))
	{
		printf("wrong gpio\n");
		return;
	}
	bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
	GPIO_E_offset = GET_DRV_OFFSET(bank, bank_pin);
	if(GPIO_E_offset == -1)
	{
		printf("wrong offset\n");
		return;
	}
	write_bit = (bank_pin % 8) << 1;
	drv_type &= 0x3;
	if(bank == 0 || bank == 1)
	{
		*(pmugrf+GPIO_E_offset/4) = (((*(pmugrf+GPIO_E_offset/4) | (0x3 << (16 + write_bit))) 
							& ~(0x3 << write_bit))) | (drv_type << write_bit);
	}
	else
	{
                *(grf+GPIO_E_offset/4) = (((*(grf+GPIO_E_offset/4) | (0x3 << (16 + write_bit))) 
                                                        & ~(0x3 << write_bit))) | (drv_type << write_bit);						//with write_en
	}
}

int asus_get_GpioDriveStrength(int pin)
{
	int bank, bank_pin;
	int GPIO_E_offset;
	int write_bit;
	volatile unsigned *reg;
	DEBUG("asus_get_GpioDriveStrength: pin=%d\n", pin);
	if(!gpio_is_valid(pin))
	{
		printf("wrong gpio\n");
		return -1;
	}
	bank = gpioToBank(pin);
	bank_pin = gpioToBankPin(pin);
	reg = (bank == 0 || bank == 1) ? pmugrf : grf;
	GPIO_E_offset = GET_DRV_OFFSET(bank, bank_pin);
	if(GPIO_E_offset == -1)
	{
		printf("wrong offset\n");
		return -1;
	}
	write_bit = (bank_pin % 8) << 1;
	return (*(reg+GPIO_E_offset/4) >> write_bit) & 0x3;
}

void asus_cleanup(void)
{
	int i;
	DEBUG("asus_cleanup\n");
	for(i=0;i<GPIO_BANK;i++)
	{
    	munmap((caddr_t)gpio_map0[i], BLOCK_SIZE);
	}
	munmap((caddr_t)grf_map, BLOCK_SIZE);
	munmap((caddr_t)pwm_map, BLOCK_SIZE);
	munmap((caddr_t)pmu_map, BLOCK_SIZE);
	munmap((caddr_t)cru_map, BLOCK_SIZE);
	munmap((caddr_t)pmucru_map, BLOCK_SIZE);
	munmap((caddr_t)pmugrf_map, BLOCK_SIZE);
}
