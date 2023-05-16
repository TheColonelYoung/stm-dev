# pragma once

#include "cmsis_os2.h"
#include "emio/format.hpp"
#include "thread.hpp"
#include "emio/emio.hpp"

#include <string>

extern UART_HandleTypeDef huart2;

class Example_thread : public cpp_freertos::Thread {

    public:

        Example_thread(std::string name, int i, int delayInSeconds)
           : Thread(name, 500, 1),
             id (i),
             DelayInSeconds(delayInSeconds)
        {

            Start();
        };

    protected:

        virtual void Run() {
            std::string message;

            message = emio::format("Starting thread {}\r\n", id);
            HAL_UART_Transmit(&huart2, (uint8_t *) message.c_str(), message.length(), 10);

            while (true) {

                message = emio::format("Running thread {}\r\n", id);
                HAL_UART_Transmit(&huart2, (uint8_t *) message.c_str(), message.length(), 10);

                osDelay(1000);
            }
        };

    private:
        int id;
        int DelayInSeconds;
};
