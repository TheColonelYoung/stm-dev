#pragma once

#include "cdc_device.h"
#include "cmsis_os2.h"
#include "thread.hpp"
#include "tusb.h"

#include "main.h"

#include <string>

class CLI_thread : public cpp_freertos::Thread {
public:

    CLI_thread(std::string name)
        : Thread(name, 1024, 12){
        Start();
    };

protected:

    virtual void Run(){
        while(1){
            if(tud_cdc_connected()){
                uint32_t available = tud_cdc_available();
                if(available){
                    std::string received;
                    received.resize(available);
                    tud_cdc_read(received.data(), available);
                    tud_cdc_write(received.c_str(), received.length());
                    tud_cdc_write_flush();
                }
            }
            osDelay(1);
        }
    };
};
