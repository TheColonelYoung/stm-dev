file(GLOB FRA_SOURCES "freertos-addons/c/Source/*" "freertos-addons/c++/Source/*")

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)

add_library(freertos-addons ${FRA_SOURCES})

if (MCU_FPU_TYPE STREQUAL "HARD")
    set(FPU_FLAGS "-mfloat-abi=hard -mfpu=fpv4-sp-d16")
else()
    set(FPU_FLAGS "-mfloat-abi=soft")
endif()

set(FRA_FLAGS "-DCPP_FREERTOS_NO_EXCEPTIONS -Wno-shadow")

set(MCU_FLAGS "-mcpu=cortex-m4 ${FPU_FLAGS} -mthumb -mthumb-interwork -ffunction-sections -fdata-sections -g -fno-common -fmessage-length=0 -specs=nosys.specs -specs=nano.specs -u _printf_float")

set(CMAKE_C_FLAGS "${COMMON_FLAGS} ${MCU_FLAGS}")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${MCU_FLAGS} ${FRA_FLAGS} -fno-rtti -fno-exceptions -fno-threadsafe-statics -Wvolatile")
set(CMAKE_EXE_LINKER_FLAGS "-mthumb -Wl,-gc-sections -T ${LINKER_SCRIPT} -Wl,-Map=${PROJECT_BINARY_DIR}/${TARGET}.map -Wl,--print-memory-usage -Wl,--no-wchar-size-warning -Wl,--no-warn-rwx-segment")



target_include_directories(freertos-addons PUBLIC
    ../source/Middlewares/Third_Party/FreeRTOS/Source/include
    ../source/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2
    ../source/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F
    ../source/Core/Inc
    freertos-addons/c/Source/include
    freertos-addons/c++/Source/include
)


