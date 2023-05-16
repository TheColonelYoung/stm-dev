FROM alpine:3.17

# Install toolchain

RUN apk update && \
    apk upgrade && \
    apk add git \
            python3 \
            py3-pip \
            cmake \
            build-base \
            libusb-dev \
            libtool \
            texinfo \
            automake\
            autoconf \
            bsd-compat-headers \
            newlib-arm-none-eabi \
            gcc-arm-none-eabi \
            gdb-multiarch \
            bash

#RUN apt -y install pkg-config libusb-1.0-0-dev gcc-12

RUN cd /usr/share/ &&\
    git clone https://github.com/linux-test-project/lcov.git --branch v1.16 lcov/ && \
    cd lcov && \
    make install

# openocd
RUN cd /usr/share/ &&\
    git clone https://github.com/raspberrypi/openocd.git --branch rp2040-v0.12.0 --depth=1 && \
    cd openocd &&\
    ./bootstrap &&\
    ./configure &&\
    make -j"$(nproc)" &&\
    make install
    #remove unneeded directories
RUN cd ..
RUN rm -rf /usr/share/openocd

EXPOSE 3333

ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID user
RUN adduser --disabled-password --gecos '' -S user --uid $USER_ID -G user

RUN apk add --no-cache tzdata
ENV TZ=Europe/Prague

WORKDIR /project
