# stm-dev
Development setup for STM32 contaning FreeRTOS, TinyUSB and UnitTesting(Catch2 + FakeIt + gcov) mostly in docker container

# Folder structure  
- `source/` - source files for application with `main.cpp`  
- `test/` - test file for testing of application source files  
- `library/` - libraries like FreeRTOS, Tiny usb and others  
- `build/` - build folder for MCu binaries and unit tests binaries  
  
# Docker  
Compilation is done in docker container  
This container have no persistent data, after command is stopped  
Project folder is mapped into docker folder `/project/`  

Main components of Docker container are  
- lcov  
- openocd (currently not used)  
- arm-none-eabi toolchain  

# Compiling  
There are two main environments for compiling due their difference are separated.  
- firmware - for RP2040 binary compilation  
- test - for Unit test compilation  

## Configuration

#### MCU series

#### Tracelyzer

# Unit testing  
Test files are linked to source files by prefix `"test_" + source_file_name + ".cpp"`  
Unit test are build and must be run in docker due to different interpret which could not be compatible with host.  
Makefile target `run_test` will execute unit tests in container and print output  

# VSCode Integration  
Debugging is integrated into vscode but is done localy on host machine  
Building is not integrated is run by Makefile targets  
Unit test are not integrated but probably could be by usage of C++ [Test Mate](https://github.com/matepek/vscode-catch2-test-adapter)  
  - There is problem with running test in docker because test binary cannot be execute on host  
  - Using "wrapper" is not working, stuck on `discovering tests`  
  - Source files will have to be mapped to host machine similar to GDB  
  - Configuration of extension  
```json  
"testMate.cpp.test.advancedExecutables": [  
        {  
            "pattern": "build/test/utest",  
            "executionWrapper": {  
                "path": "/bin/sh",  
                "args": [ "-c", "${workspaceFolder}/run_test.sh \"${cmd}\" ${argsStr} 2>&1" ]  
            },  
            "sourceFileMap": {  
                "/project": "${workspaceFolder}"  
            }  
        }  
    ],  
```  

# Debugging  
Is done via VSCode cortex-debug extension can can be done by any other mean.  
Content of launch.json for cortex debug configuration  
Debugging is done outside of container due to unresolved issues with connection to cortex-debug.  
Because during compilation symbols are referenced to file position in container path substitution is required on order to properly step through files in VSCode.

```json  
{
    "version": "0.2.0",
    "configurations": [

        {
            "type": "cortex-debug",
            "request": "launch",
            "servertype": "openocd",
            "cwd": "${workspaceRoot}",
            "executable": "${workspaceRoot}/build/source/firmware.elf",
            "name": "GDB + OpenOCD",
            "device": "STM32L432xx",
            "configFiles": [
                "interface/stlink.cfg",
                "target/stm32l4x.cfg"
            ],
            "preLaunchCommands": [
                "set substitute-path /project ${workspaceRoot}",
            ],
        }
    ]
}
```  

# Additional libraries

## FreeRTOS

## Tracealyzer
Following code has to be in end of `FreeRTOSConfig.h`
```cpp
#ifdef USE_TRACEALYZER
  #if ( configUSE_TRACE_FACILITY == 1 )
    #include "trcRecorder.h"
  #endif
#endif
```

Stream port is set by CMake variable `TRACEALYZER_STREAM_PORT`
Options:
 - `STM32_USB_CDC`

Enable stream by adding following before `osKernelStart()`:
```cpp
vTraceEnable(TRC_START);
```
Alternatively `vTraceEnable(TRC_START_AWAIT_HOST);` could be used of host port supports Receive operation.

#### Configuration
In `config/trcConfig.h` set:
```cpp
#include "stm32l4xx.h"
...
#define TRC_CFG_HARDWARE_PORT TRC_HARDWARE_PORT_ARM_Cortex_M
```

In `kernelports/FreeRTOS/config/trcKernelPortConfig.h` set:
```cpp
#define TRC_CFG_RECORDER_MODE TRC_RECORDER_MODE_STREAMING
...
#define TRC_CFG_FREERTOS_VERSION TRC_FREERTOS_VERSION_10_3_1
```

In `streamports/STM32_USB_CDC/trcStreamPort.c` change USB interface include to:
```cpp
#include <usbd_cdc_if.h>
```

#### Stream port implementation

## freertos-addons

# Makefile  
Main targets:  
`docker-build` - build container requiren for most of other targets  
`binary` - Compile binary for RP2040  
`flash` - Flash binary into RP2040 connected via SWD (RPi Debug Probe)  
`picotool`-flash - Use picotool to flash binary into device via USB connection  
`tests` - Compile unit tests  
`run_test` - Run unit tests  
`coverage` - Create coverage report for unit tests  
`report_coverage` - Create HTML coverage report by lcov  
`clean` - Remove build folder  

There are another targets are these are currently used for debugging or testing of system  

# TODO
- [ ] - Debugging thought container, openocd in container, cortex-debug attached into debug serve
- [ ] - Test integration into VSCode
- [ ] - Coverage report integration into VSCode (line coverage + report viewer)
- [ ] - Change location of coverage report output folder
- [ ] - TinyUSB support
