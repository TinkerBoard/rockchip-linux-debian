import os
import time
import numpy as np
import cv2
from rknn.api import RKNN
from time import sleep

def show_outputs(outputs):
    output = outputs[0][0]
    output_sorted = sorted(output, reverse=True)
    top5_str = 'mobilenet_v1\n-----TOP 5-----\n'
    for i in range(5):
        value = output_sorted[i]
        index = np.where(output == value)
        for j in range(len(index)):
            if (i + j) >= 5:
                break
            if value > 0:
                topi = '{}: {}\n'.format(index[j], value)
            else:
                topi = '-1: 0.0\n'
            top5_str += topi
    print(top5_str)

if __name__ == '__main__':
    WorkDirectory = os.getcwd() + "/rockchip_test/src/"
    os.chdir(WorkDirectory)
    WorkDirectory = os.getcwd()
    #print("WorkDirectory : " + WorkDirectory)
    file_name = os.path.join(WorkDirectory, 'npu_inference_time.txt')

    # Create RKNN object
    rknn = RKNN()

    # pre-process config
    #print('--> config model')
    #rknn.config(channel_mean_value='103.94 116.78 123.68 58.82', reorder_channel='0 1 2')
    #print('done')

    # Load rknn model
    #print('--> Load RKNN model')
    ret = rknn.load_rknn('./mobilenet_v1.rknn')
    if ret != 0:
        print('Load mobilenet_v1.rknn failed!')
        exit(ret)
    #print('done')

    # Set inputs
    img = cv2.imread('./dog_224x224.jpg')
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # init runtime environment
    print('--> Init runtime environment')
    ret = rknn.init_runtime(target='rk3399pro')
    if ret != 0:
        print('Init runtime environment failed')
        exit(ret)
    #print('done')

    print('--> SDK version')
    sdk_version = rknn.get_sdk_version()
    print(sdk_version)

    test_num = 0
    delay_time = 0.05
    while True:
        npu_open = open(file_name, 'w+')
        test_num = test_num + 1
        print("---------------" + str(test_num) + "---------------")

        # Inference
        #print('--> Running model')
        outputs = rknn.inference(inputs=[img])
        show_outputs(outputs)
        #print('done')

        # perf
        #print('--> Begin evaluate model performance')
        #perf_results = rknn.eval_perf(inputs=[img])
        #print('done')

        #for item1,time in perf_results.items():
        write_str = str(test_num) + "\n"
        npu_open.write(write_str)
        sleep(delay_time)

    rknn.release()
    npu_open.close()
