# Dockerfile for ynoengine build container

FROM emscripten/emsdk:3.1.74

RUN apt update && apt install -y ca-certificates gpg wget ninja-build automake autoconf autotools-dev m4 pkg-config python3 python3-pip

# Get meson from pip (some projects need a newer version of meson than what Ubuntu has)
RUN pip3 install --no-cache-dir meson

# Get cmake from Kitware PPA (version in Ubuntu does not support CMakePresets)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg && \
	echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list && \
	apt update && apt install -y cmake
