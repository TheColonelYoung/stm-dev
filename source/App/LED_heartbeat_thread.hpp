# pragma once

#include "cmsis_os2.h"
#include "thread.hpp"
#include "tusb.h"

#include "stm32l4xx_hal.h"

#include <string>

extern UART_HandleTypeDef huart2;

class LED_heartbeat_thread : public cpp_freertos::Thread {

    public:

        LED_heartbeat_thread(std::string name, uint32_t delay)
           : Thread(name, 1000, 8),
             delay(delay)
        {
            Start();
        };

    public:
        uint32_t delay;

    protected:
        virtual void Run() {
            uint32_t delay_time = delay;
            HAL_GPIO_WritePin(GPIOB, GPIO_PIN_10, GPIO_PIN_SET);
            while(true) {
                vTaskDelay(delay_time);
                HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_RESET);
                vTaskDelay(delay_time);
                HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_SET);
            }
        };

};
