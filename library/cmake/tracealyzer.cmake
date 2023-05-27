file(GLOB TRA_SOURCES "tracealyzer/*" "tracealyzer/streamports/${TRACEALYZER_STREAM_PORT}/*" "tracealyzer/kernelports/FreeRTOS/*")

add_library(tracealyzer ${TRA_SOURCES})

# Specify the cross compiler
set(CMAKE_C_COMPILER arm-none-eabi-gcc)

set(FPU_FLAGS "-mfloat-abi=hard -mfpu=fpv4-sp-d16")
set(MCU_FLAGS "-mcpu=cortex-m4 ${FPU_FLAGS} -mthumb -mthumb-interwork -ffunction-sections -fdata-sections -g -fno-common -fmessage-length=0 -specs=nosys.specs -specs=nano.specs -u _printf_float")

set(CMAKE_C_FLAGS "${MCU_FLAGS}")

target_compile_definitions(tracealyzer PUBLIC
    ${MCU_SHORT_ID}xx
    ${MCU_SERIES}
    USE_HAL_DRIVER
    USE_TRACEALYZER
)

target_include_directories(tracealyzer PUBLIC
    tracealyzer/include
    tracealyzer/config
    tracealyzer/kernelports/FreeRTOS
    tracealyzer/kernelports/FreeRTOS/config
    tracealyzer/kernelports/FreeRTOS/include
    tracealyzer/streamports/${TRACEALYZER_STREAM_PORT}/config
    tracealyzer/streamports/${TRACEALYZER_STREAM_PORT}/include
    ../source/Drivers/CMSIS/Device/ST/${MCU_SERIES}xx/Include
    ../source/Drivers/${MCU_SERIES}xx_HAL_Driver/Inc
    ../source/Drivers/${MCU_SERIES}xx_HAL_Driver/Inc/Legacy
    ../source/Drivers/CMSIS/Include
    ../source/Middlewares/Third_Party/FreeRTOS/Source/include
    ../source/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2
    ../source/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F
    ../source/Core/Inc
)

if (TRACEALYZER_STREAM_PORT STREQUAL "STM32_USB_CDC")
    target_include_directories(tracealyzer PUBLIC
        ../source/Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc # USB
        ../source/Middlewares/ST/STM32_USB_Device_Library/Core/Inc # USB
        ../source/USB_DEVICE/App # USB
        ../source/USB_DEVICE/Target # USB
    )
endif()

if (TRACEALYZER_STREAM_PORT STREQUAL "STM32_TUSB")
    target_include_directories(tracealyzer PUBLIC
        tinyusb/src
        tinyusb/src/common
        tinyusb/src/device
        tinyusb/src/host
        tinyusb/src/osal
        tinyusb/src/class/cdc
    )
endif()
