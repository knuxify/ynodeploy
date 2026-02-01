# ynorankings dockerfile.
# NOTE: This file expects the build context to be set to the ynorankings source code directory.

ARG GOLANG_VERSION=1.25
FROM golang:${GOLANG_VERSION}-alpine AS build

WORKDIR /opt/ynorankings

# Copy the source code into the container
COPY . .

# Build the binary
RUN go build

FROM alpine:3.23
WORKDIR /opt/ynorankings
COPY --from=build /opt/ynorankings/ynorankings /opt/ynorankings/ynorankings

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

# Run ynorankings
USER yno
ENTRYPOINT [ "/opt/ynorankings/ynorankings", "--config", "config.yml" ]
