#pragma once

#include "cdc_device.h"
#include "cmsis_os2.h"
#include "thread.hpp"
#include "tusb.h"

#include "main.h"

#include "stm32l4xx_hal.h"

#include <string>
#include "embedded_cli.h"
#include "emio/emio.hpp"

void writeChar(EmbeddedCli *embeddedCli, char c);

void onCommand(EmbeddedCli *embeddedCli, CliCommand *command);

void onLed(EmbeddedCli *cli, char *args, void *context);

class CLI_thread : public cpp_freertos::Thread {
public:

    CLI_thread(std::string name)
        : Thread(name, 2048, 12){
        Start();
    };

protected:

    virtual void Run(){
        EmbeddedCli *cli = embeddedCliNewDefault();
        cli->writeChar = writeChar;
        cli->onCommand = onCommand;

        embeddedCliAddBinding(cli, {
                "led",          // command name (spaces are not allowed)
                "Get led status",   // Optional help for a command (NULL for no help)
                false,              // flag whether to tokenize arguments (see below)
                nullptr,            // optional pointer to any application context
                onLed               // binding function
        });

        while(1){
            if(tud_cdc_connected()){
                uint32_t available = tud_cdc_available();
                for(int i = 0; i < available; i++){
                    char c;
                    tud_cdc_read(&c, 1);
                    embeddedCliReceiveChar(cli, c);
                }
                embeddedCliProcess(cli);
            }
            osDelay(5);
        }
    };
};

