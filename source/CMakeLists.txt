cmake_minimum_required(VERSION 3.16)

set(SERIES STM32L4)
set(PROJECT_NAME stm-dev)
set(SHORT_DEVICE_ID STM32L432KCUx)

set(STARTUP_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/startup_stm32l432xx.s)

# Configure the project
project(${PROJECT_NAME} C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)

# Specify the cross compiler
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)

set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/${SHORT_DEVICE_ID}_FLASH.ld)

#Uncomment for hardware floating point
set(FPU_FLAGS "-mfloat-abi=hard -mfpu=fpv4-sp-d16")

#Uncomment for software floating point
#set(FPU_FLAGS "-mfloat-abi=soft")

set(COMMON_FLAGS "-Wall -Wextra -Wpedantic -Wshadow -Wformat=2 -Wformat-truncation")

set(MCU_FLAGS "-mcpu=cortex-m4 ${FPU_FLAGS} -mthumb -mthumb-interwork -ffunction-sections -fdata-sections -g -fno-common -fmessage-length=0 -specs=nosys.specs -specs=nano.specs -u _printf_float")

set(CMAKE_C_FLAGS "${MCU_FLAGS}")
set(CMAKE_CXX_FLAGS "${MCU_FLAGS} -fno-rtti -fno-exceptions -fno-threadsafe-statics")
set(CMAKE_EXE_LINKER_FLAGS "-Wl,-gc-sections -T ${LINKER_SCRIPT} -Wl,-Map=${PROJECT_BINARY_DIR}/${PROJECT_NAME}.map -Wl,--print-memory-usage -Wl,--no-wchar-size-warning -Wl,--no-warn-rwx-segment")
#  -Wl,--no-warn-rwx-segment
add_definitions(-D__weak=__attribute__\(\(weak\)\) -D__packed=__attribute__\(\(__packed__\)\) -DUSE_HAL_DRIVER -DSTM32L432xx -DSTM32_L4 -DUSE_HAL_DRIVER -DCPP_FREERTOS_NO_EXCEPTIONS)

file(GLOB_RECURSE SOURCES "Drivers/*.*" "Src/*.*" "Inc/*.*" "Middlewares/Third_Party/FreeRTOS/*.*" "Middlewares/Third_Party/freertos-addons/c/Source/*.*" "Middlewares/Third_Party/freertos-addons/c++/Source/*.*")
#)

include_directories(Inc
    Drivers/${SERIES}xx_HAL_Driver/Inc
    Drivers/${SERIES}xx_HAL_Driver/Inc/Legacy
    Drivers/CMSIS/Device/ST/${SERIES}xx/Include
    Drivers/CMSIS/Include
    Middlewares/Third_Party/FreeRTOS/Source/include
    Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2
    Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F
    Middlewares/Third_Party/freertos-addons/c/Source/include
    Middlewares/Third_Party/freertos-addons/c++/Source/include)

add_executable(${PROJECT_NAME}.elf ${SOURCES} ${LINKER_SCRIPT} ${STARTUP_SCRIPT})
set(HEX_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.bin)

add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -I elf32-little -O ihex $<TARGET_FILE:${PROJECT_NAME}.elf> ${HEX_FILE}
        COMMAND ${CMAKE_OBJCOPY} -I elf32-little -O binary $<TARGET_FILE:${PROJECT_NAME}.elf> ${BIN_FILE}
        COMMENT "Building ${HEX_FILE}
Building ${BIN_FILE}"
)
