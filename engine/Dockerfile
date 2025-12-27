# Dockerfile for ynoengine build container

FROM emscripten/emsdk:3.1.74

RUN apt update && apt install -y ninja-build automake autoconf autotools-dev libtool m4 pkg-config python3 python3-pip libssl-dev

# Get meson from pip (some project need a newer version of meson than what Ubuntu has)
RUN pip3 install --no-cache-dir meson

# Build cmake from source (version in Ubuntu does not support CMakePresets)
RUN wget https://cmake.org/files/v3.29/cmake-3.29.2.tar.gz && tar -xzf cmake-3.29.2.tar.gz && cd cmake-3.29.2 && cmake -B build -G Ninja && ninja -C build && cmake --install build

