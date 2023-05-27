set(TRACEALYZER_STREAM_PORT STM32_UART)

set(TINYUSB_DRIVER DCW2)

include(cmake/tracealyzer.cmake)
include(cmake/freertos-addons.cmake)
include(cmake/emio.cmake)
include(cmake/etl.cmake)
include(cmake/tinyusb.cmake)
