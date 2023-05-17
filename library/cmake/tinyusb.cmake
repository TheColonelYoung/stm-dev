file(GLOB_RECURSE TUSB_SOURCES
    "tinyusb/src/*.*"
)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)

add_library(tinyusb ${TUSB_SOURCES})

if (MCU_FPU_TYPE STREQUAL "HARD")
    set(FPU_FLAGS "-mfloat-abi=hard -mfpu=fpv4-sp-d16")
else()
    set(FPU_FLAGS "-mfloat-abi=soft")
endif()

set(TUSB_FLAGS "")

set(MCU_FLAGS "-mcpu=cortex-m4 ${FPU_FLAGS} -mthumb -mthumb-interwork -ffunction-sections -fdata-sections -g -fno-common -fmessage-length=0 -specs=nosys.specs -specs=nano.specs -u _printf_float")

set(CMAKE_C_FLAGS "${COMMON_FLAGS} ${MCU_FLAGS}")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${MCU_FLAGS} ${FRA_FLAGS} -fno-rtti -fno-exceptions -fno-threadsafe-statics -Wvolatile")
set(CMAKE_EXE_LINKER_FLAGS "-mthumb -Wl,-gc-sections -T ${LINKER_SCRIPT} -Wl,-Map=${PROJECT_BINARY_DIR}/${TARGET}.map -Wl,--print-memory-usage -Wl,--no-wchar-size-warning -Wl,--no-warn-rwx-segment")

add_compile_definitions(tinyusb PUBLIC
    ${MCU_SHORT_ID}xx
    ${MCU_SERIES}
    USE_HAL_DRIVER
)

target_include_directories(tinyusb PUBLIC
    tinyusb/src
    tinyusb/src/common
    tinyusb/src/device
    tinyusb/src/host
    tinyusb/src/osal
    tinyusb/src/class/cdc
    ../source/Core/Inc
    ../source/Drivers/CMSIS/Device/ST/${MCU_SERIES}xx/Include
    ../source/Drivers/CMSIS/Include
    ../source/Drivers/${MCU_SERIES}xx_HAL_Driver/Inc
    ../source/Drivers/${MCU_SERIES}xx_HAL_Driver/Inc/Legacy
)

if (TINYUSB_DRIVER STREQUAL "FSDEV")
    target_include_directories(tinyusb PUBLIC tinyusb/src/portable/st/stm32_fsdev)
elseif(TINYUSB_DRIVER STREQUAL "DCW2")
    target_include_directories(tinyusb PUBLIC tinyusb/src/portable/synopsys/dwc2)
endif()
