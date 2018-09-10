#
# Docker file for json-patch CI tests
#
FROM debian:unstable

# NOTE: Switch back to debian:testing when GDC 8.1 is default in testing as well

# prepare
RUN apt-get update -qq

# install build essentials
RUN apt-get install -yq gcc gdc ldc meson dub

# finish
RUN mkdir /build
WORKDIR /build
