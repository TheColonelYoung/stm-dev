#include "cli_thread.hpp"

void writeChar(EmbeddedCli *embeddedCli, char c){
    if(tud_cdc_connected()){
        tud_cdc_write(&c, 1);
        tud_cdc_write_flush();
    }
}

void onCommand(EmbeddedCli *embeddedCli, CliCommand *command) {
    std::string message;
    message = emio::format("Command {}\r\n", command->name);

    tud_cdc_write(message.c_str(), message.length());
    tud_cdc_write_flush();
}

void onLed(EmbeddedCli *cli, char *args, void *context) {
    HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_10);
}
