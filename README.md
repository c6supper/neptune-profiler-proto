Neptune-Profiler-Proto
===========

All the proto message files for Neptune core communication with local and remote plugins.

This is a repository which contains the  [google protobuf](https://github.com/google/protobuf) messages.

An IDL that defines contracts between local & remote plugins and neptune core.

Several components uses this repository as a sub module. It takes neptune-profiler-proto compiles it into the specific language(c++ by default).

Prerequisites
-----------------

> * Install golang
> * Install protoc
> * Install protoc-gen-doc
> * Install [protolint](https://github.com/yoheimuta/protolint/releases)

How to Build
-----------------

> * mkdir build && cd build
> * for x86 testing purpose
>> * cmake ../
> * for QNX
  ```bash
  cmake -DCMAKE_CROSSCOMPILING=1 -DCMAKE_TOOLCHAIN_FILE=$QNX_ROOT/cmake/QNXToolchain.cmake \
  -DProtobuf_DIR=$QNX_TARGET/aarch64le/usr/lib/cmake/protobuf \
  -DgRPC_DIR=$QNX_TARGET/aarch64le/usr/lib/cmake/grpc \
  -DZLIB_LIBRARY=$QNX_TARGET/aarch64le/usr/lib/libz.a \
  -DOPENSSL_CRYPTO_LIBRARY=$QNX_TARGET/aarch64le/usr/lib/libcrypto.a \
  -DOPENSSL_SSL_LIBRARY=$QNX_TARGET/aarch64le/usr/lib/libssl.a ../ && \
  find . -name "link.txt" -exec sed -i "s/-lrt//g" {} + && \
  find . -name "link.txt" -exec sed -i "s/-lpthread//g" {} + && \
  make -j64
  ```
> * make install

Documentation
-----------------

Read the API Docs [here](doc/neptune-profiler-proto-doc.md)

Inspiration
-----------------

The structure for the project is inspired by [Gauge](https://github.com/getgauge/gauge) from ThoughtWorks

License
-------

Neptune-Profiler-Proto is released under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.

Copyright
---------

Copyright 2022 Coding Nerd
