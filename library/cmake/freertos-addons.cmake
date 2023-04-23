file(GLOB FRA_SOURCES "freertos-addons/c/Source/*" "freertos-addons/c++/Source/*")

add_library(freertos-addons ${FRA_SOURCES})

target_include_directories(freertos-addons PUBLIC
    ../source/Middlewares/Third_Party/FreeRTOS/Source/include
    ../source/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2
    ../source/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F
    ../source/Inc
    freertos-addons/c/Source/include
    freertos-addons/c++/Source/include
)


