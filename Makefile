.PHONY: firmware tests run_test
.SILENT:

IMAGE_NAME := stm-dev
TOOLCHAIN_SCRIPT=stm-toolchain

PWD = $(shell pwd)
USER_ID = $(shell id -u)
GROUP_ID = $(shell id -g)
BUILD_DIR = build

CONTAINER_RUN := docker run --rm --privileged -t -v /dev:/dev -v $(PWD):/project
ROOT_RUN := $(CONTAINER_RUN) $(IMAGE_NAME) /bin/sh -c
USER_RUN := $(CONTAINER_RUN) --user "$(USER_ID):$(GROUP_ID)" $(IMAGE_NAME) /bin/sh -c

all: firmware test run_test

init: docker-build
	cat <<EOF > ${TOOLCHAIN_SCRIPT} \
		#!/bin/bash \
		$(CONTAINER_RUN) ${IMAGE_NAME} $@ \
	EOF

install:
	chmod ugo+x /tmp/${TOOLCHAIN_SCRIPT}
	sudo mv ${TOOLCHAIN_SCRIPT} /usr/bin/${TOOLCHAIN_SCRIPT}

docker-build: docker-clean
	docker build . --tag $(IMAGE_NAME) --build-arg USER_ID=$(USER_ID) --build-arg GROUP_ID=$(GROUP_ID)

docker-shell:
	docker exec -it -t --privileged $(IMAGE_NAME) /bin/sh -l

docker-deamon:
	docker run -d -it --name $(IMAGE_NAME) -p 3333:3333 --privileged -v /dev:/dev -v $(PWD):/project $(IMAGE_NAME)

docker-stop:
	docker stop $(IMAGE_NAME) 2> /dev/null > /dev/null || true

docker-clean: docker-stop
	docker rm $(IMAGE_NAME) 2> /dev/null > /dev/null || true

docker-openocd:
	$(ROOT_RUN) -f interface/stlink.cfg -f target/stm32l0.cfg -c \"bindto 0.0.0.0\" -c \"reset_config srst_only\""

docker-gdb:
	$(ROOT_RUN) "gdb-multiarch -ex \"target remote localhost:3333\""

firmware: $(BUILD_DIR)
	$(USER_RUN) "cd $(BUILD_DIR) && cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1 && make firmware -j$(nproc)"
	@$(MAKE) modify_clangd

modify_clangd:
	@sed -i 's#/project#$(shell pwd)#g' ./build/compile_commands.json

$(BUILD_DIR):
	mkdir build/

run_test: $(BUILD_DIR) test
	-$(USER_RUN) "./build/test/test"

test_coverage: run_test
	$(USER_RUN) "cd build/test/CMakeFiles/test.dir/__/source && gcov **/*.gcno"

report_coverage: test_coverage
	$(USER_RUN) " lcov -q -c --directory build/test/CMakeFiles/test.dir/__/source/ --output-file build/coverage.info"
	$(USER_RUN) "genhtml -q -o build/coverage_report build/coverage.info"

coverage: report_coverage
	@xdg-open build/coverage_report/index.html 1>/dev/null 2>/dev/null &

test: $(BUILD_DIR)
	$(USER_RUN) "cd $(BUILD_DIR) && cmake .. -DCMAKE_BUILD_TYPE=Debug && make test -j$(nproc)"
	@$(MAKE) modify_clangd

clean:
	rm -rf build

flash: firmware
	openocd -f interface/stlink.cfg -f target/stm32l4x.cfg -c "program build/firmware.bin verify reset exit 0x08000000"

reset:
	openocd -f interface/stlink.cfg -f target/stm32l4x.cfg -c init -c "reset halt"
