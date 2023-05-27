#pragma once

#include "cdc_device.h"
#include "cmsis_os2.h"
#include "thread.hpp"
#include "tusb.h"

#include "main.h"
#include "stm32l4xx_hal.h"

#include <string>

extern UART_HandleTypeDef huart2;
extern void MX_USB_OTG_FS_PCD_Init(void);

class TinyUSB_thread : public cpp_freertos::Thread {
public:

    TinyUSB_thread(std::string name, int i, int DelayInMiliSeconds)
        : Thread(name, 1024, 5),
        id(i),
        DelayInMiliSeconds(DelayInMiliSeconds){
        Start();
    };

protected:

    virtual void Run(){
        MX_USB_OTG_FS_PCD_Init();
        HAL_PWREx_EnableVddUSB();
        tud_init(BOARD_TUD_RHPORT);
        tud_task();

        // Tracealyzer must be connected during following cycle
        for (int i = 0; i < 500; i++) {
            tud_task();
            osDelay(10);
        }

        xTraceEnable(TRC_START);

        while (1) {
            osDelay(1);
        }
    }; // Run

private:
    int id;
    int DelayInMiliSeconds;
};
