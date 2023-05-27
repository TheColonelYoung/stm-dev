#pragma once

#include "cdc_device.h"
#include "cmsis_os2.h"
#include "thread.hpp"
#include "tusb.h"

#include "main.h"

#include <string>

class CLI_thread : public cpp_freertos::Thread {
public:

    CLI_thread(std::string name, int i)
        : Thread(name, 1024, 12),
        id(i){
        Start();
    };

protected:

    virtual void Run(){

    };

private:
    int id;
};
