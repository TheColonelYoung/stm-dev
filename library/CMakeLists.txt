
file(GLOB_RECURSE FRA_SOURCES "freertos-addons/c/Source/*.c")
include_directories("freertos-addons/c/Source/include")
include_directories("../source/Middlewares/Third_Party/FreeRTOS/Source/include")
include_directories("../source/Inc")
include_directories("../source/Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2")
include_directories("../source/Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F" )
message("FRA_SOURCES: ${FRA_SOURCES}")

add_library(freertos-addons STATIC ${FRA_SOURCES} )
target_include_directories(freertos-addons INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})
