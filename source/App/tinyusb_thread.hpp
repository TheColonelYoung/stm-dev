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

    TinyUSB_thread(std::string name)
        : Thread(name, 2048, 20){
        Start();
    };

protected:

    virtual void Run(){
        MX_USB_OTG_FS_PCD_Init();
        HAL_PWREx_EnableVddUSB();
        tud_init(BOARD_TUD_RHPORT);
        tud_task();

        while (1) {
            tud_task();
            osDelay(10);
        }
    }; // Run

};
