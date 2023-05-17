cmake_minimum_required(VERSION 3.16)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_OBJCOPY arm-none-eabi-objcopy)

set(TARGET firmware)
set(OUTPUT_ELF ${TARGET}.elf)

string(TOLOWER ${MCU_SHORT_ID} STARTUP_ID)
set(STARTUP_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/startup_${STARTUP_ID}xx.s)
set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/${MCU_LONG_ID}_FLASH.ld)

if (MCU_FPU_TYPE STREQUAL "HARD")
    set(FPU_FLAGS "-mfloat-abi=hard -mfpu=fpv4-sp-d16")
else()
    set(FPU_FLAGS "-mfloat-abi=soft")
endif()

set(MCU_FLAGS "-mcpu=cortex-m4 ${FPU_FLAGS} -mthumb -mthumb-interwork -ffunction-sections -fdata-sections -g -fno-common -fmessage-length=0 -specs=nosys.specs -specs=nano.specs -u _printf_float")

set(CMAKE_C_FLAGS "${COMMON_FLAGS} ${MCU_FLAGS}")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${MCU_FLAGS} -fno-rtti -fno-exceptions -fno-threadsafe-statics -Wvolatile")
set(CMAKE_EXE_LINKER_FLAGS "-mthumb -Wl,-gc-sections -T ${LINKER_SCRIPT} -Wl,-Map=${PROJECT_BINARY_DIR}/${TARGET}.map -Wl,--print-memory-usage -Wl,--no-wchar-size-warning -Wl,--no-warn-rwx-segment")


add_compile_definitions(${TARGET} PUBLIC
    __weak=__attribute__\(\(weak\)\)
    __packed=__attribute__\(\(__packed__\)\)
    ${MCU_SHORT_ID}xx
    ${MCU_SERIES}
    USE_HAL_DRIVER
    CPP_FREERTOS_NO_EXCEPTIONS
    #USE_TRACEALYZER
)

file(GLOB_RECURSE BIN_SOURCES
    "Core/Src/*.*"
    "Core/Inc/*.*"
    "App/*.*"
)

file(GLOB_RECURSE FREERTOS_SOURCES
"Middlewares/Third_Party/FreeRTOS/*.*"
)

file(GLOB_RECURSE USB_SOURCES
    "USB_DEVICE/*.*"
    "Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Src/*.*"
    "Middlewares/ST/STM32_USB_Device_Library/Core/Src/*.*"
)

file(GLOB_RECURSE HAL_SOURCES
    "Drivers/*.*"
)

# Suppress warnings in generated HAL sources
SET_SOURCE_FILES_PROPERTIES(
    ${HAL_SOURCES}
    ${USB_SOURCES}
    PROPERTIES
    COMPILE_FLAGS "-Wno-unused-parameter"
)

# Suppress warnings in generated main.c source file
SET_SOURCE_FILES_PROPERTIES(
    Core/Src/main.c
    PROPERTIES
    COMPILE_FLAGS "-Wno-volatile -Wno-unused-parameter -Wno-missing-field-initializers"
)

add_executable( ${TARGET}
    ${BIN_SOURCES} ${HAL_SOURCES} ${USB_SOURCES} ${FREERTOS_SOURCES}
    ${LINKER_SCRIPT}
    ${STARTUP_SCRIPT}
)

# target_link_libraries(${TARGET} PUBLIC tracealyzer)
# target_link_libraries(${TARGET} PUBLIC freertos-addons)
target_link_libraries(${TARGET} PUBLIC emio)
target_link_libraries(${TARGET} PUBLIC etl)
target_link_libraries(${TARGET} PUBLIC tinyusb)

target_include_directories(${TARGET} PUBLIC
    App
    Core/Inc
    USB_DEVICE/App
    USB_DEVICE/Target
    Drivers/${MCU_SERIES}xx_HAL_Driver/Inc
    Drivers/${MCU_SERIES}xx_HAL_Driver/Inc/Legacy
    Drivers/CMSIS/Device/ST/${MCU_SERIES}xx/Include
    Drivers/CMSIS/Include
    Middlewares/Third_Party/FreeRTOS/Source/include
    Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2
    Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F
    Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc # USB
    Middlewares/ST/STM32_USB_Device_Library/Core/Inc # USB
)

set_source_files_properties(Core/Src/main.c PROPERTIES LANGUAGE CXX )

set_target_properties(${TARGET} PROPERTIES OUTPUT_NAME ${OUTPUT_ELF})

set(HEX_FILE ${PROJECT_BINARY_DIR}/${TARGET}.hex)
set(BIN_FILE ${PROJECT_BINARY_DIR}/${TARGET}.bin)

add_custom_command(TARGET ${TARGET} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -I elf32-little -O ihex    ${OUTPUT_ELF} ${HEX_FILE}
    COMMAND ${CMAKE_OBJCOPY} -I elf32-little -O binary  ${OUTPUT_ELF} ${BIN_FILE}
    COMMENT "Building ${HEX_FILE}
Building ${BIN_FILE}"
)
