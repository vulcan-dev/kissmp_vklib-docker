FROM --platform=arm64 ubuntu:20.04

## Install dependencies
RUN apt-get update
RUN apt-get install -y patch
RUN apt-get install -y make
RUN apt-get install -y g++
RUN apt-get install -y gcc
RUN apt-get install -y wget

## Compile Lua
WORKDIR /builds/lua
RUN wget https://www.lua.org/ftp/lua-5.4.4.tar.gz
RUN tar -xzf lua-5.4.4.tar.gz
WORKDIR /builds/lua/lua-5.4.4
RUN wget https://www.linuxfromscratch.org/patches/blfs/11.1/lua-5.4.4-shared_library-1.patch
RUN patch -Np1 -i lua-5.4.4-shared_library-1.patch && make linux
RUN make INSTALL_TOP=/usr INSTALL_DATA="cp -d" INSTALL_MAN=/usr/share/man/man1 TO_LIB="liblua.so liblua.so.5.4 liblua.so.5.4.4" install

## Compile KissMP
FROM rust:alpine
ENV PATH=/root/.cargo/bin:$PATH
RUN apk update
RUN apk add git curl alpine-sdk binutils

COPY --from=0 /usr/lib/ /usr/lib/

WORKDIR /builds/kissmp
RUN git clone https://github.com/vulcan-dev/KISS-multiplayer.git
WORKDIR /builds/kissmp/KISS-multiplayer
RUN git checkout lib
RUN cargo build -p kissmp-server -j 8 --release

## Final image
FROM --platform=arm64 ubuntu:20.04
COPY --from=0 /usr/lib/liblua.so.5.4.4 /usr/lib/liblua.so.5.4.4
COPY --from=0 /usr/lib/liblua.so.5.4 /usr/lib/liblua.so.5.4
COPY --from=0 /usr/lib/liblua.so /usr/lib/liblua.so
COPY --from=1 /builds/kissmp/KISS-multiplayer/target/release/kissmp-server /server/kissmp-server
WORKDIR /server
RUN mkdir mods
RUN mkdir addons
RUN chmod +x kissmp-server
ENTRYPOINT [ "./kissmp-server" ]