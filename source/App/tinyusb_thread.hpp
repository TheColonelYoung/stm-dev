# pragma once

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
           : Thread(name, 2048, 30),
             id (i),
             DelayInMiliSeconds(DelayInMiliSeconds)
        {

            Start();
        };

    protected:

        virtual void Run() {
            MX_USB_OTG_FS_PCD_Init();
            HAL_PWREx_EnableVddUSB();
            tud_init(BOARD_TUD_RHPORT);
            while(1) {
                tud_task();
                if (tud_cdc_available() ) {
                    char buf[4] = "1\r\n";
                    tud_cdc_write(buf, 3);
                    tud_cdc_write_flush();
                }
                osDelay(20);
            }
        };

    private:
        int id;
        int DelayInMiliSeconds;
};
