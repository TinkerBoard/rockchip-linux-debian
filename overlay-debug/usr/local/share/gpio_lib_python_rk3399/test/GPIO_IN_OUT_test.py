
#Testing for GPIO
import ASUS.GPIO as GPIO

GPIO.setwarnings(False)

#Pin Table [Begin]
#RK3399PRO
pinTable = []
pinTable += [{'phys':  1, 'wPi': -1, 'TB':  -1, 'BCM': -1}, {'phys':  2, 'wPi': -1, 'TB':  -1, 'BCM': -1}]          #[1]3.3V			|   [2]5V
pinTable += [{'phys':  3, 'wPi':  8, 'TB':  73, 'BCM':  2}, {'phys':  4, 'wPi': -1, 'TB':  -1, 'BCM': -1}]          #[3]GPIO2_B1		|   [4]5V
pinTable += [{'phys':  5, 'wPi':  9, 'TB':  74, 'BCM':  3}, {'phys':  6, 'wPi': -1, 'TB':  -1, 'BCM': -1}]          #[5]GPIO2_B2		|   [6]GND
pinTable += [{'phys':  7, 'wPi':  7, 'TB':  89, 'BCM':  4}, {'phys':  8, 'wPi': 15, 'TB':  81, 'BCM': 14}]          #[7]GPIO2_D1		|   [8]GPIO2_C1
pinTable += [{'phys':  9, 'wPi': -1, 'TB':  -1, 'BCM': -1}, {'phys': 10, 'wPi': 16, 'TB':  80, 'BCM': 15}]          #[9]GND			|   [10]GPIO2_C0
pinTable += [{'phys': 11, 'wPi':  0, 'TB':  83, 'BCM': 17}, {'phys': 12, 'wPi':  1, 'TB': 120, 'BCM': 18}]          #[11]GPIO2_C3		|   [12]GPIO3_D0
pinTable += [{'phys': 13, 'wPi':  2, 'TB':  85, 'BCM': 27}, {'phys': 14, 'wPi': -1, 'TB':  -1, 'BCM': -1}]          #[13]GPIO2_C5		|   [14]GND
pinTable += [{'phys': 15, 'wPi':  3, 'TB':  84, 'BCM': 22}, {'phys': 16, 'wPi':  4, 'TB':  86, 'BCM': 23}]          #[15]GPIO2_C4		|   [16]GPIO2_C6
pinTable += [{'phys': 17, 'wPi': -1, 'TB':  -1, 'BCM': -1}, {'phys': 18, 'wPi':  5, 'TB':  87, 'BCM': 24}]          #[17]3.3V			|   [18]GPIO2_C7
pinTable += [{'phys': 19, 'wPi': 12, 'TB':  40, 'BCM': 10}, {'phys': 20, 'wPi': -1, 'TB':  -1, 'BCM': -1}]          #[19]GPIO1_B0		|   [20]GND
pinTable += [{'phys': 21, 'wPi': 13, 'TB':  39, 'BCM':  9}, {'phys': 22, 'wPi':  6, 'TB': 124, 'BCM': 25}]          #[21]GPIO1_A7		|   [22]GPIO3_D4
pinTable += [{'phys': 23, 'wPi': 14, 'TB':  41, 'BCM': 11}, {'phys': 24, 'wPi': 10, 'TB':  42, 'BCM':  8}]          #[23]GPIO1_B1		|   [24]GPIO1_B2
pinTable += [{'phys': 25, 'wPi': -1, 'TB':  -1, 'BCM': -1}, {'phys': 26, 'wPi': 11, 'TB':   6, 'BCM':  7}]          #[25]GND			|   [26]GPIO0_A6
pinTable += [{'phys': 27, 'wPi': 30, 'TB':  71, 'BCM':  0}, {'phys': 28, 'wPi': 31, 'TB':  72, 'BCM':  1}]          #[27]GPIO2_A7		|   [28]GPIO2_B0
pinTable += [{'phys': 29, 'wPi': 21, 'TB': 126, 'BCM':  5}, {'phys': 30, 'wPi': -1, 'TB':  -1, 'BCM': -1}]          #[29]GPIO3_D6		|   [30]GND 
pinTable += [{'phys': 31, 'wPi': 22, 'TB': 125, 'BCM':  6}, {'phys': 32, 'wPi': 26, 'TB': 146, 'BCM': 12}]          #[31]GPIO3_D5		|   [32]GPIO4_C2
pinTable += [{'phys': 33, 'wPi': 23, 'TB': 150, 'BCM': 13}, {'phys': 34, 'wPi': -1, 'TB':  -1, 'BCM': -1}]          #[33]GPIO4_C6		|   [34]GND
pinTable += [{'phys': 35, 'wPi': 24, 'TB': 121, 'BCM': 19}, {'phys': 36, 'wPi': 27, 'TB':  82, 'BCM': 16}]          #[35]GPIO3_D1		|   [36]GPIO2_C2 
pinTable += [{'phys': 37, 'wPi': 25, 'TB': 149, 'BCM': 26}, {'phys': 38, 'wPi': 28, 'TB': 123, 'BCM': 20}]          #[37]GPIO4_C5		|   [38]GPIO3_D3
pinTable += [{'phys': 39, 'wPi': -1, 'TB':  -1, 'BCM': -1}, {'phys': 40, 'wPi': 29, 'TB': 127, 'BCM': 21}]          #[39]GND			|   [40]GPIO3_D7 

#RK3399PRO
pairPins = [( 3,  5),
            ( 7,  8),
            (10, 12),
            (11, 13),
            (15, 16),
            (19, 18),
            (21, 23),
            (22, 24),
            (26, 29),
            (27, 28),
            (31, 32),
            (33, 36),
            (35, 37),
            (38, 40)]

gpioUsedPins = [3, 5, 7, 8, 10, 11, 12, 13, 15, 16, 18, 19, 21, 22, 23, 24, 26, 27, 28, 29, 31, 32, 33, 35, 36, 37, 38, 40]
#RK3399PRO
PullUpDnPins = {3: GPIO.PUD_UP, 7: GPIO.PUD_UP, 27: GPIO.PUD_UP, 29: GPIO.PUD_UP}
modeMap = {'phys': GPIO.BOARD, 'TB': GPIO.ASUS, 'BCM': GPIO.BCM}
modeNameMap = {'phys': 'GPIO.BOARD', 'TB': 'GPIO.ASUS', 'BCM': 'GPIO.BCM'}
InternalPullUpDnValue = {GPIO.PUD_UP: GPIO.HIGH, GPIO.PUD_DOWN: GPIO.LOW}
#Pin Table [End]

def GPIO_IO_TESTING():
    print('== Testing GPIO INPUT/OUTPUT ==')
    for mode in ['phys', 'TB', 'BCM']:
        GPIO.setmode(modeMap[mode])
        LPin = [pinTable[pins[0] - 1][mode] for pins in pairPins]
        RPin = [pinTable[pins[1] - 1][mode] for pins in pairPins]
	if(-1 in LPin or -1 in RPin):
            print('Some pins use the 3.3V or GND pin.')
            exit()
        for IPin, OPin in [(LPin, RPin), (RPin, LPin)]:
            GPIO.setup( IPin, GPIO.IN)
            GPIO.setup( OPin, GPIO.OUT)

            if(False in [GPIO.gpio_function(pin) == GPIO.IN for pin in IPin] or
                False in [GPIO.gpio_function(pin) == GPIO.OUT for pin in OPin]):
                print('Check GPIO.gpio_function or GPIO.setup.')
                exit()
            for volt in [GPIO.HIGH, GPIO.LOW]:
                GPIO.output(OPin, volt)
                OResult = [GPIO.input(pin) == volt for pin in OPin]
                IResult = [GPIO.input(IPin[i]) == GPIO.input(OPin[i]) for i in range(len(IPin))]
                if(False in OResult):
                    print('Check OUTPUT Pin[%d].' % (OPin[OResult.index(False)]))
                    exit()
                if(False in IResult):
                    print('Check INPUT Pin[%d].' % (IPin[IResult.index(False)]))
                    exit()
        print("[PASS] GPIO.setmode(%s)" % (modeNameMap[mode]))
        GPIO.cleanup()
    print('===============================')

def GPIO_PULL_UPDW_TESTING():
    checkPins = []
    print('== Testing GPIO PULL_UP_DOWN ==')
    testPin = gpioUsedPins
    print("Check that nothing connects to those pins: %s" % (','.join([str(x) for x in testPin])))
    GPIO.setmode(GPIO.BOARD)
    for pin in testPin:
	GPIO.setup(pin , GPIO.IN, pull_up_down=GPIO.PUD_UP)
	value = GPIO.input(pin)
	print('Check OUTPUT GPIO.input[%d]=%d.' % (pin,value))
	print('Check OUTPUT internal=%d.' % (InternalPullUpDnValue[PullUpDnPins[pin] if pin in PullUpDnPins else GPIO.PUD_UP]))
        if (GPIO.input(pin) != InternalPullUpDnValue[PullUpDnPins[pin] if pin in PullUpDnPins else GPIO.PUD_UP]):
            checkPins.append(pin)
    GPIO.setup(testPin , GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    for pin in testPin:
        if (GPIO.input(pin) != InternalPullUpDnValue[PullUpDnPins[pin] if pin in PullUpDnPins else GPIO.PUD_DOWN]):
            checkPins.append(pin)
    print("[%s] Pull Up and Down" % ('PASS' if len(checkPins) <= 0 else 'FAILED'))
    if(len(checkPins) > 0 ):
        print('Please check those pins: %s' % (','.join([str(x) for x in checkPins])))
    GPIO.cleanup()
    print('===============================')

GPIO_IO_TESTING()
#GPIO_PULL_UPDW_TESTING()
