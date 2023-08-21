#ifndef __RKIO_H__
#define __RKIO_H__

#define MAX_PIN_NUM        0x40
#define CENTERPWM          0x01



// Port function select bits

#define FSEL_INPT          0b000
#define FSEL_OUTP          0b001
#define FSEL_ALT0          0b100
#define FSEL_ALT1          0b101
#define FSEL_ALT2          0b110
#define FSEL_ALT3          0b111
#define FSEL_ALT4          0b011
#define FSEL_ALT5          0b010

// Pin modes
#define INPUT              0
#define OUTPUT             1
#define PWM_OUTPUT         2
#define GPIO_CLOCK         3
#define SOFT_PWM_OUTPUT    4
#define SOFT_TONE_OUTPUT   5
#define PWM_TONE_OUTPUT    6
#define SERIAL             40
#define SPI                41
#define I2C                42
#define PWM                43
#define GPIO               44
#define TS                 45
#define RESERVED           46
#define I2S                47
#define GPS_MAG            48
#define HSADCT             49
#define USB                50
#define HDMI               51
#define SC                 52
#define GPIOIN             53
#define GPIOOUT            54
#define CLKOUT             55
#define CLK1_27M           56
#define VOP0_PWM           57
#define VOP1_PWM           58

// Pull up/down/none

#define	PUD_OFF                 0
#define	PUD_DOWN                1
#define	PUD_UP                  2

// Locker: GPIO to HW#
#define GPIO3_B1	105
#define GPIO3_B2	106
#define GPIO3_B3	107
#define GPIO3_B4	108

#define GPIO4_C2	146
#define GPIO4_C3	147
#define GPIO4_C4	148
#define GPIO4_C5	149
#define GPIO4_C6	150

#define PWM12		GPIO4_C5
#define PWM13		GPIO4_C6
#define PWM14		GPIO4_C2
#define PWM15		GPIO4_C3

#define RK3568_CRU		0xfdd20000
#define RK3568_PMU              0xfdcd0000
#define PMU_GPIO0C_IOMUX        0x008c

// Locker: TODO: check calculate
#define RK3568_GPIO(x)          (GPIO0_BASE+x*GPIO_LENGTH+(x>0)*GPIO_CHANNEL)
#define GPIO_LENGTH             0x00010000
#define GPIO_CHANNEL            0x009d0000
#define GPIO0_BASE              0xfdd60000
#define GPIO_BANK               5
#define RK3568_GRF_PHYS         0xfdc20000

#define GRF_GPIO3B_IOMUX_L 	0x0048
#define GRF_GPIO3B_IOMUX_H 	0x004C
#define GRF_GPIO4C_IOMUX_L 	0x0070
#define GRF_GPIO4C_IOMUX_H 	0x0074


/* Pull up / down / Z */
#define GRF_GPIO3B_P        0x00a4
#define GRF_GPIO4C_P        0x00b8

/* Drive Strength */
// Locker: not sure
#define GRF_GPIO3B_DS_0		0x0290
#define GRF_GPIO3B_DS_1		0x0294
#define GRF_GPIO3B_DS_2		0x0298
#define GRF_GPIO3B_DS_3		0x029c
#define GRF_GPIO4C_DS_0		0x02e0
#define GRF_GPIO4C_DS_1		0x02e4
#define GRF_GPIO4C_DS_2		0x02e8
#define GRF_GPIO4C_DS_3		0x02ec



#define RK3568_PWM                      0xfdd70000
#define RK3568_PWM0_CNT                 0x0000
#define RK3568_PWM0_PERIOD              0x0004
#define RK3568_PWM0_DUTY                0x0008
#define RK3568_PWM0_CTR                 0x000c
#define RK3568_PWM1_CNT                 0x0010
#define RK3568_PWM1_PERIOD              0x0014
#define RK3568_PWM1_DUTY                0x0018
#define RK3568_PWM1_CTR                 0x001c
#define RK3568_PWM2_CNT                 0x0020
#define RK3568_PWM2_PERIOD              0x0024
#define RK3568_PWM2_DUTY                0x0028
#define RK3568_PWM2_CTR                 0x002c
#define RK3568_PWM3_CNT                 0x0030
#define RK3568_PWM3_PERIOD              0x0034
#define RK3568_PWM3_DUTY                0x0038
#define RK3568_PWM3_CTR                 0x003c


#define GPIO_SWPORT_DR_L          0x0000
#define GPIO_SWPORT_DR_H          0x0004
#define GPIO_SWPORT_DDR_L         0x0008
#define GPIO_SWPORT_DDR_H         0x000C
#define GPIO_INT_EN_L		0x0010
#define GPIO_INT_EN_H		0x0014
#define GPIO_INT_MASK_L		0x0018
#define GPIO_INT_MASK_H		0x001C
#define GPIO_INT_TYPE_L		0x0020
#define GPIO_INT_TYPE_H		0x0024
#define GPIO_INT_POLARITY_L		0x0028
#define GPIO_INT_POLARITY_H		0x002C
#define GPIO_INT_BOTHEDGE_L		0x0030
#define GPIO_INT_BOTHEDGE_H		0x0034
#define GPIO_DEBOUNCE_L			0x0038
#define GPIO_DEBOUNCE_H			0x003C
#define GPIO_DBCLK_DIV_EN_L		0x0040
#define GPIO_DBCLK_DIV_EN_H		0x0044
#define GPIO_DBCLK_DIV_CON		0x0048
#define GPIO_INT_STATUS			0x0050
#define GPIO_INT_RAWSTATUS		0x0058
#define GPIO_PORT_EOI_L			0x0060
#define GPIO_PORT_EOI_H			0x0064
#define GPIO_EXT_PORT			0x0070
#define GPIO_VER_ID			0x0078

#endif
