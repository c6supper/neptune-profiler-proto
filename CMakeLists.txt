#----------------------------------------------------------------
#  Copyright (c) Coding Nerd
#  Licensed under the Apache License, Version 2.0
#  See LICENSE in the project root for license information.
#----------------------------------------------------------------
cmake_minimum_required(VERSION 3.5.1)

include(cmake/common.cmake)

project(neptune-profiler-proto)

# INSTALL default: off
option(INSTALL "Install neptune binaries and files" OFF)

# doc default: on
option(DOC "Generate and update the doc files" ON)

# cpp default: on
option(CPP "Generate and update the COO files" ON)

find_program(GRPC_CPP_PLUGIN "grpc_cpp_plugin")
if (NOT GRPC_CPP_PLUGIN)
    message(FATAL_ERROR "grpc_cpp_plugin not found!")
ENDIF()

if(CPP)
  # Find Protobuf installation
  # Looks for protobuf-config.cmake file installed by Protobuf's cmake installation.
  set(protobuf_MODULE_COMPATIBLE TRUE)
  find_package(Protobuf CONFIG REQUIRED)
  message(STATUS "Using protobuf ${Protobuf_VERSION}")
  set(_PROTOBUF_LIBPROTOBUF protobuf::libprotobuf)
  set(_REFLECTION gRPC::grpc++_reflection)

  # Find gRPC installation
  # Looks for gRPCConfig.cmake file installed by gRPC's cmake installation.
  find_package(gRPC CONFIG REQUIRED)
  message(STATUS "Using gRPC ${gRPC_VERSION}")
  set(_GRPC_GRPCPP gRPC::grpc++)

  # Generated sources
  set(api_proto_src "${CMAKE_CURRENT_BINARY_DIR}/cpp/api.pb.cc")
  set(api_proto_hdr "${CMAKE_CURRENT_BINARY_DIR}/cpp/api.pb.h")
  file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/cpp")
  add_custom_command(
    OUTPUT "${api_proto_src}" "${api_proto_hdr}"
    COMMAND ${PROTOC}
    ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}/cpp"
      --cpp_out "${CMAKE_CURRENT_BINARY_DIR}/cpp"
      -I "${CMAKE_CURRENT_LIST_DIR}/proto"
      --plugin=protoc-gen-grpc="${GRPC_CPP_PLUGIN}"
      "${CMAKE_CURRENT_LIST_DIR}/proto/*.proto"
    DEPENDS "${CMAKE_CURRENT_LIST_DIR}/proto/*.proto")

  include_directories("${CMAKE_CURRENT_BINARY_DIR}")

  add_library(neptune-profiler-proto SHARED
    ${api_proto_src}
    ${api_proto_hdr})

  target_link_libraries(neptune-profiler-proto
    ${_REFLECTION}
    ${_GRPC_GRPCPP}
    ${_PROTOBUF_LIBPROTOBUF})

  install(
    DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cpp
    DESTINATION ${CMAKE_CURRENT_LIST_DIR}/
    FILES_MATCHING # install only matched files
    PATTERN "*.h" # select header files
  )

  install(TARGETS neptune-profiler-proto DESTINATION ${CMAKE_CURRENT_LIST_DIR}/cpp/lib)

endif(CPP)

if(DOC)
  set(DOC_FILE "${CMAKE_CURRENT_LIST_DIR}/doc/neptune-profiler-proto-doc.md")
  add_custom_command(
    OUTPUT ${DOC_FILE}
    COMMAND ${PROTOC}
    ARGS --doc_out=markdown,neptune-profiler-proto-doc.md:${CMAKE_CURRENT_LIST_DIR}/doc
      -I "${CMAKE_CURRENT_LIST_DIR}/proto/"
      "${CMAKE_CURRENT_LIST_DIR}/proto/*.proto"
    DEPENDS "${CMAKE_CURRENT_LIST_DIR}/proto/*.proto")

  add_custom_target(doc ALL DEPENDS ${DOC_FILE})
endif(DOC)

