cmake_minimum_required(VERSION 3.16)
project(stm-dev C CXX ASM)

# Seris of MCU family (ex. STM32L4)
set(MCU_SERIES STM32L4)

# Short ID from startup wihtout "x" (ex. STM32L4Q5)
set(MCU_SHORT_ID STM32L4Q5)

# Short ID from linker script with x (ex. STM32L4Q5CGTx)
set(MCU_LONG_ID STM32L4Q5CGTx)

# Select MCU FPU TYPE: SOFT / HARD
set(MCU_FPU_TYPE HARD)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)

set(COMMON_FLAGS "-Wall -Wextra -Wpedantic -Wshadow -Wformat=2 -Wformat-truncation")

add_subdirectory(library)

add_subdirectory(source)

add_subdirectory(test)


