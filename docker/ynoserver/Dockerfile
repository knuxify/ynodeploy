# ynoserver dockerfile.
# NOTE: This file expects the build context to be set to the ynoserver source code directory.

ARG GOLANG_VERSION=1.25
FROM golang:${GOLANG_VERSION} as base

WORKDIR /opt/ynoserver

# Copy the source code into the container
COPY . .

# Build the binary
RUN go build

# Add yno user
ARG UID=10001
ARG GID=10001
RUN groupadd -g "${GID}" yno
RUN useradd -m -u ${UID} -g yno yno

# Let yno user write to the sockets directory
RUN mkdir -p sockets && \
    chown -R 10001:10001 sockets

# Run ynoserver
USER yno
CMD ./ynoserver --config config.yml
