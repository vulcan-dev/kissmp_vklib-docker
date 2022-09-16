# Compile KissMP (Stage: 0)
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y cargo
RUN apt-get install -y git

WORKDIR /build
RUN git clone https://github.com/vulcan-dev/KISS-multiplayer.git && cd KISS-multiplayer && git checkout lib
WORKDIR /build/KISS-multiplayer/kissmp-server/
RUN CARGO_NET_GIT_FETCH_WITH_CLI=true cargo build --release -j 4

# KissMP Server (Stage: 1)
FROM ubuntu:20.04
COPY --from=0 /build/KISS-multiplayer/target/release/kissmp-server /server/kissmp-server
WORKDIR /server
RUN mkdir mods
RUN mkdir addons
RUN chmod +x kissmp-server

# Final image (Stage: 2)
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y make
RUN apt-get install -y g++
RUN apt-get install -y wget
RUN apt-get install -y patch
RUN apt-get install -y libmongoc-1.0-0
RUN apt-get install -y libbson-1.0-0

WORKDIR /lua_build
RUN wget https://www.lua.org/ftp/lua-5.4.4.tar.gz
RUN tar -xzf lua-5.4.4.tar.gz
RUN rm lua-5.4.4.tar.gz
RUN cd lua-5.4.4
WORKDIR /lua_build/lua-5.4.4
RUN wget https://www.linuxfromscratch.org/patches/blfs/11.2/lua-5.4.4-shared_library-1.patch
RUN patch -Np1 -i lua-5.4.4-shared_library-1.patch && make linux
RUN make INSTALL_TOP=/usr INSTALL_DATA="cp -d" INSTALL_MAN=/usr/share/man/man1 TO_LIB="liblua.so liblua.so.5.4 liblua.so.5.4.4" install
RUN rm /lua_build -r

COPY --from=1 /server /server
WORKDIR /server

ENTRYPOINT ["./kissmp-server"]