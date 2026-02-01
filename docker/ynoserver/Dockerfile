# ynoserver dockerfile.
# NOTE: This file expects the build context to be set to the ynoserver source code directory.

ARG GOLANG_VERSION=1.25
FROM golang:${GOLANG_VERSION}-alpine AS build

WORKDIR /opt/ynoserver

# Copy the source code into the container
COPY . .

# Build the binary
RUN go build

FROM alpine:3.23
WORKDIR /opt/ynoserver
COPY --from=build /opt/ynoserver/ynoserver /opt/ynoserver/ynoserver

# Add yno user
ARG UID=10001
ARG GID=10001
RUN apk add shadow
RUN groupadd -g "${GID}" yno
RUN useradd -m -u ${UID} -g yno yno
RUN apk del shadow

# Let yno user write to the sockets directory
RUN mkdir -p sockets && \
    chown -R 10001:10001 sockets

# Make logs directory and let yno user write to it
RUN mkdir -p logs && \
    chown -R 10001:10001 logs

# Make saves directory and let yno user write to it
RUN mkdir -p saves && \
    chown -R 10001:10001 saves

# Make screenshots directory and let yno user write to it
RUN mkdir -p screenshots && \
    chown -R 10001:10001 screenshots

# Run ynoserver
USER yno
ENTRYPOINT [ "/opt/ynoserver/ynoserver", "--config", "config.yml" ]
