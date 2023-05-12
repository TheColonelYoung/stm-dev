cmake_minimum_required(VERSION 3.16)
project(stm-dev C CXX ASM)

set(MCU_SERIES STM32L4)
set(MCU_SHORT_ID STM32L4Q5)
set(MCU_LONG_ID STM32L4Q5CGTx)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)

# Cross compiler

add_subdirectory(library)

add_subdirectory(source)

add_subdirectory(test)


