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
- firmware - for STM32 binary compilation  
- test - for Unit test compilation  

## Configuration  

#### MCU series  
MCU settings should be set in root `CMakeLists.txt`.  
    This contains series and long and short ID of MCU.  

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
    - As wrapper script which executed make target executing tests in container is used  
  - Source files will have to be mapped to host machine similar to GDB  
  
Configuration of extension  
```json  
"testMate.cpp.test.advancedExecutables": [  
    {  
        "pattern": "build/test/test",  
        "executionWrapper": {  
            "path": "/bin/sh",  
            "args": [ "-c", "${workspaceFolder}/run_test.sh \"${cmd}\" ${argsStr} 2>&1" ]  
        },  
        "cwd": "${workspaceFolder}",  
        "sourceFileMap": {  
            "/project": "${workspaceFolder}"  
        }  
    }  
],  
```  

# Coverage  
Coverage is handled by `gcov` which is installed inside docker.  
    Based on tests `gcov` creates report which lines are covered by tests.  
    Test binary needs to be compiled with flags `-fprofile-arcs -ftest-coverage`.  
HTML coverage report can be created by makefile target `report_coverage`.   

# Clangd  
Use `compile_commands.json` located in `build/` file for creating cache which is used by Codium to navigate and suggest code.  
    File is created by adding `-DCMAKE_EXPORT_COMPILE_COMMANDS=1` flag to CMake.  
Because compilation is done in container paths in `compile_commands.json` does not match. This could be fixed by using `--path-mappings` argument.  
    But there will still be problem with Codium navigation.  
Problem could be solved by modifying `compile_commands.json` content by using `sed` utility after file is created.  
    This has to be done after every update of file (compilation).  

```Makefile  
firmware: $(BUILD_DIR)  
	...  
	@$(MAKE) modify_clangd  

modify_clangd:  
	@sed -i 's#/project#$(shell pwd)#g' ./build/compile_commands.json  
```  

Clangd is not able to work with some ARM related compilation flags.  
These flags can be removed for clangd compilation by using `.clangd` config file.  
```yaml  
CompileFlags:  
  Remove:  
  - "-mthumb-interwork"  
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
Is configured by CubeMX located in source/Middlewares/Third_Party/FreeRTOS  

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

## TinyUSB  
For STM32L4 is required to enable USB power before USB initialization.  
Then initialize USb interface and service device task in frequent intervals.
General follow-up of code is:  
```c++  
void main(){  
    ...  
    MX_USB_OTG_FS_PCD_Init();  
    HAL_PWREx_EnableVddUSB();  
    tud_init(BOARD_TUD_RHPORT);  
    ...  
    while (1) {  
        tud_task();  
        if ( tud_cdc_available() ){  
            char buf[4] = "1\r\n";  
            tud_cdc_write(buf, 3);  
            tud_cdc_write_flush();  
        }  
        ...  
        HAL_Delay(10);  
    }  
}  
```  
IRQ handler must be added to `stm32l4xx_it.c` by adding handle call into `OTG_FS_IRQHandler`.  
HAL handler should be called but is regenerated by CubeMX behind return, so it is OK.  
```c++  
void OTG_FS_IRQHandler(void)  
{  
  /* USER CODE BEGIN OTG_FS_IRQn 0 */  
  tud_int_handler(0);  
  return;  
  /* USER CODE END OTG_FS_IRQn 0 */  
  HAL_PCD_IRQHandler(&hpcd_USB_OTG_FS);  
  /* USER CODE BEGIN OTG_FS_IRQn 1 */  
  /* USER CODE END OTG_FS_IRQn 1 */  
}  
```  

If using `picocom` for communication with tinyUSB device, start start of communication is required to send some data to device in order to make CDC interface available. Simply push any key on keyboard. This could be maybe solved on some devices by use of `tud_cdc_connected()` instead of `tud_cdc_available()`.  

Delay in loop which handles `tud_task()` should not be too high otherwise it limits the response of the device. Servicing should be at a relatively high frequency, with less than 20 Hz servicing problems already occur. Better to be on at least 100 Hz.  

For use of TinyUSB with FreeRTOS seems to be ideal to initialize USB before scheduler start and then have thread which will handle `tud_task()`.

# Makefile  
Main targets:  
`docker-build` - build container required for most of other targets  
`firmware` - Compile binary for STM32  
`flash` - Flash binary into STM32 connected via SWD  
`tests` - Compile unit tests  
`run_test` - Run unit tests  
`coverage` - Creates nad opens coverage report for unit tests  
`clean` - Remove build folder  

There are another targets are these are currently used for debugging or testing of system  

# TODO  
- [ ] Debugging thought container, openocd in container, cortex-debug attached into debug serve  
- [ ] Test integration into VSCode  
- [ ] TinyUSB support for FreeRTOS  
- [ ] Solve warnings for library compilations  
