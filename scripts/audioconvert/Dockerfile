FROM alpine:3.23

# Install dependencies
RUN apk add --no-cache ffmpeg fluidsynth curl

# Get MSGS soundfont for fluidsynth
RUN mkdir /opt/sf && curl -o /opt/sf/MSGS_Fixed.sf2 https://defensemech.com/MSGS_Fixed.sf2
