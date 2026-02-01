# Dockerfile for building gencache from EasyRPG tools

FROM alpine:3.23 AS build

# Install build dependencies
RUN apk update && apk add cmake ninja gcc g++ icu-dev nlohmann-json liblcf-dev

# Build EasyRPG tools
RUN wget https://github.com/EasyRPG/Tools/archive/9aa8e8adad999cf972735ce12d184406495d8dfb.tar.gz && \
		tar xzf 9aa8e8adad999cf972735ce12d184406495d8dfb.tar.gz && \
		cd Tools-9aa8e8adad999cf972735ce12d184406495d8dfb && \
		cmake -B build -G Ninja \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_INSTALL_PREFIX=/easyrpg \
			-DDISABLE_LMU2PNG=ON \
			-DDISABLE_PNG2XYZ=ON \
			-DDISABLE_XYZ2PNG=ON \
			-DDISABLE_XYZCRUSH=ON \
			-DDISABLE_LCFTRANS=ON \
			-DDISABLE_LCFVIZ=ON && \
		cmake --build build && \
		cmake --build build --target install

FROM alpine:3.23
# Install runtime dependencies
RUN apk update && apk add liblcf icu icu-data-full
COPY --from=build /easyrpg /easyrpg
# Command is specified in gencache wrapper script
# ENTRYPOINT [ "/easyrpg/bin/gencache" ]
