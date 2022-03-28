# ----------------------------------------------------------------
# Copyright (c) Coding Nerd
# Licensed under the Apache License, Version 2.0
# See LICENSE in the project root for license information.
# ----------------------------------------------------------------
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

if(NOT GRPC_CPP_PLUGIN)
  message(FATAL_ERROR "grpc_cpp_plugin not found!")
endif()

# bypass the cmake bug, QNX do not have pthread
find_package(Threads)

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

  set(TARGET_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

  set(CMAKE_TARGET_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cpp)

  message(DEBUG "CMAKE_CURRENT_LIST_DIR=${CMAKE_CURRENT_LIST_DIR}")
  message(DEBUG "CMAKE_TARGET_DIRECTORY=${CMAKE_TARGET_DIRECTORY}")

  file(GLOB PROTO_FILES ${CMAKE_CURRENT_LIST_DIR}/proto/*.proto)
  file(GLOB GRPC_PROTO_FILES ${CMAKE_CURRENT_LIST_DIR}/proto/api/*.proto)

  message(DEBUG "PROTO_FILES=${PROTO_FILES}")

  # Replace .proto -> .pb.cc
  string(REGEX REPLACE "${CMAKE_CURRENT_LIST_DIR}/proto" "${CMAKE_TARGET_DIRECTORY}" SRC_FILES ${PROTO_FILES})
  string(REGEX REPLACE "[.]proto" ".pb.cc;" SRC_FILES ${SRC_FILES})

  # Replace .proto -> .pb.h
  string(REGEX REPLACE "${CMAKE_CURRENT_LIST_DIR}/proto" "${CMAKE_TARGET_DIRECTORY}" INC_FILES ${PROTO_FILES})
  string(REGEX REPLACE "[.]proto" ".pb.h;" INC_FILES ${INC_FILES})

  # Replace .proto -> .grpc.pb.cc
  string(REGEX REPLACE "${CMAKE_CURRENT_LIST_DIR}/proto" "${CMAKE_TARGET_DIRECTORY}" SRC_GRPC_FILES ${GRPC_PROTO_FILES})
  string(REGEX REPLACE "[.]proto" ".grpc.pb.cc;" SRC_GRPC_FILES ${SRC_GRPC_FILES})

  # Replace .proto -> grpc.pb.h
  string(REGEX REPLACE "${CMAKE_CURRENT_LIST_DIR}/proto" "${CMAKE_TARGET_DIRECTORY}" INC_GRPC_FILES ${GRPC_PROTO_FILES})
  string(REGEX REPLACE "[.]proto" ".grpc.pb.h;" INC_GRPC_FILES ${INC_GRPC_FILES})

  message(DEBUG "SRC_FILES=${SRC_FILES}")
  message(DEBUG "SRC_GRPC_FILES=${SRC_GRPC_FILES}")

  file(MAKE_DIRECTORY "${CMAKE_TARGET_DIRECTORY}/api")

  message(STATUS "${CMAKE_TARGET_DIRECTORY}")

  foreach(proto ${PROTO_FILES})
    execute_process(COMMAND ${PROTOC} --cpp_out "${CMAKE_TARGET_DIRECTORY}" -I "${CMAKE_CURRENT_LIST_DIR}/proto" "${proto}"
      RESULT_VARIABLE PROTOC_RESULT)

    if(NOT PROTOC_RESULT EQUAL "0")
      message(FATAL_ERROR "protoc failed with ${PROTOC_RESULT}, please check")
    endif()
  endforeach(proto)

  foreach(proto ${GRPC_PROTO_FILES})
    execute_process(COMMAND ${PROTOC} --grpc_out "${CMAKE_TARGET_DIRECTORY}"
      --cpp_out "${CMAKE_TARGET_DIRECTORY}"
      -I "${CMAKE_CURRENT_LIST_DIR}/proto" --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN} "${proto}"
      RESULT_VARIABLE PROTOC_RESULT)

    if(NOT PROTOC_RESULT EQUAL "0")
      message(FATAL_ERROR "protoc failed with ${PROTOC_RESULT}, please check")
    endif()
  endforeach(proto)

  # execute_process(COMMAND ${PROTOC} --grpc_out "${CMAKE_TARGET_DIRECTORY}/api"
  # -I"${CMAKE_CURRENT_LIST_DIR}/proto"
  # --plugin=protoc-gen-grpc="${GRPC_CPP_PLUGIN}"
  # "${CMAKE_CURRENT_LIST_DIR}/proto/api/*.proto"
  # WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  # RESULT_VARIABLE GRPC_RESULT)
  # if(NOT GRPC_RESULT EQUAL "0")
  # message(FATAL_ERROR "grpc failed with ${PROTOC_RESULT}, please check")
  # endif()
  include_directories("${CMAKE_CURRENT_BINARY_DIR}/cpp")

  add_library(neptune-profiler-proto SHARED
    ${SRC_FILES}
    ${SRC_GRPC_FILES}
  )

  target_link_libraries(neptune-profiler-proto
    ${_REFLECTION}
    ${_GRPC_GRPCPP}
    ${_PROTOBUF_LIBPROTOBUF})

  get_target_property(TARGET_LIBRARIES neptune-profiler-proto LINK_LIBRARIES)
  message(${TARGET_LIBRARIES})

  install(
    DIRECTORY ${CMAKE_TARGET_DIRECTORY}
    DESTINATION ${TARGET_DIRECTORY}
    FILES_MATCHING # install only matched files
    PATTERN "*.h" # select header files
  )

  install(TARGETS neptune-profiler-proto DESTINATION ${TARGET_DIRECTORY}/cpp/${CMAKE_SYSTEM_PROCESSOR}/lib)
endif(CPP)

if(DOC)
  set(DOC_FILE "${CMAKE_CURRENT_LIST_DIR}/doc/neptune-profiler-proto-doc.md")
  add_custom_command(
    OUTPUT ${DOC_FILE}
    COMMAND ${PROTOC}
    ARGS --doc_out=markdown,neptune-profiler-proto-doc.md:${CMAKE_CURRENT_LIST_DIR}/doc
    -I "${CMAKE_CURRENT_LIST_DIR}/proto/"
    -I "${CMAKE_CURRENT_LIST_DIR}/api/proto/"
    "${CMAKE_CURRENT_LIST_DIR}/proto/*.proto"
    "${CMAKE_CURRENT_LIST_DIR}/proto/api/*.proto"
    DEPENDS "${CMAKE_CURRENT_LIST_DIR}/proto/*.proto" "${CMAKE_CURRENT_LIST_DIR}/proto/api/*.proto")

  add_custom_target(doc ALL DEPENDS ${DOC_FILE})
endif(DOC)
