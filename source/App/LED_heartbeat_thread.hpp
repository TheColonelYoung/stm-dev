# pragma once

#include "cmsis_os2.h"
#include "thread.hpp"
#include "tusb.h"

#include "stm32l4xx_hal.h"

#include <string>

extern UART_HandleTypeDef huart2;

class LED_heartbeat_thread : public cpp_freertos::Thread {

    public:

        LED_heartbeat_thread(std::string name, int i, int DelayInMiliSeconds)
           : Thread(name, 500, 8),
             id (i),
             DelayInMiliSeconds(DelayInMiliSeconds)
        {
            Start();
        };

    protected:

        virtual void Run() {
            while(true) {
                osDelay(20);
                HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_RESET);
                HAL_GPIO_WritePin(GPIOB, GPIO_PIN_10, GPIO_PIN_SET);
                osDelay(20);
                HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_SET);
                HAL_GPIO_WritePin(GPIOB, GPIO_PIN_10, GPIO_PIN_RESET);
            }
        };

    private:
        int id;
        int DelayInMiliSeconds;
};
