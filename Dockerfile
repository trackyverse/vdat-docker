FROM alpine:edge

# https://specs.opencontainers.org/image-spec/annotations/
LABEL \
    org.opencontainers.image.authors="Michael O'Brien <obrien@umces.edu>; Benjamin Hlina <benjamin.hlina@gmail.com>" \
    org.opencontainers.image.vendor="Trackyverse" \
    org.opencontainers.image.version="0.1.0.999" \
    org.opencontainers.image.source="https://github.com/trackyverse/vdat-docker" \
    org.opencontainers.image.licenses="CC0-1.0"

ENV WINEDEBUG=fixme-all,err-all
ENV WINEPREFIX=/VDAT/.wine

WORKDIR /VDAT

RUN apk add wine msitools && \
  wineboot