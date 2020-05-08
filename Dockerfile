FROM debian:unstable
RUN apt-get update -qq
RUN apt-get install -yq gcc gdc ldc meson dub
RUN mkdir /build
WORKDIR /build
