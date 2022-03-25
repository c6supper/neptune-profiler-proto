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

  set(TARGET_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cpp_install/${CMAKE_SYSTEM_PROCESSOR})

  set(CMAKE_TARGET_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cpp)

  message(STATUS "CMAKE_CURRENT_LIST_DIR=${CMAKE_CURRENT_LIST_DIR}")
  message(STATUS "CMAKE_TARGET_DIRECTORY=${CMAKE_TARGET_DIRECTORY}")

  file(GLOB PROTO_FILES ${CMAKE_CURRENT_LIST_DIR}/proto/*.proto)

  message(STATUS "PROTO_FILES=${PROTO_FILES}")
  
  # Replace .proto -> .pb.cc
  string(REGEX REPLACE "${CMAKE_CURRENT_LIST_DIR}/proto" "${CMAKE_TARGET_DIRECTORY}" SRC_FILES ${PROTO_FILES})
  string(REGEX REPLACE "[.]proto" ".pb.cc;" SRC_FILES ${SRC_FILES})
  
  # Replace .proto -> .grpc.pb.cc
  string(REGEX REPLACE "${CMAKE_CURRENT_LIST_DIR}/proto" "${CMAKE_TARGET_DIRECTORY}" SRC_GRPC_FILES ${PROTO_FILES})
  string(REGEX REPLACE "[.]proto" ".grpc.pb.cc;" SRC_GRPC_FILES ${SRC_GRPC_FILES})

  # Replace .proto -> .pb.h
  string(REGEX REPLACE "${CMAKE_CURRENT_LIST_DIR}/proto" "${CMAKE_TARGET_DIRECTORY}" INC_FILES ${PROTO_FILES})
  string(REGEX REPLACE "[.]proto" ".pb.h;" INC_FILES ${INC_FILES})

  # Replace .proto -> grpc.pb.h
  string(REGEX REPLACE "${CMAKE_CURRENT_LIST_DIR}/proto" "${CMAKE_TARGET_DIRECTORY}" INC_GRPC_FILES ${PROTO_FILES})
  string(REGEX REPLACE "[.]proto" ".grpc.pb.h;" INC_GRPC_FILES ${INC_GRPC_FILES})
  
  message(STATUS "SRC_FILES=${SRC_FILES}")
  message(STATUS "SRC_GRPC_FILES=${SRC_GRPC_FILES}")

  file(MAKE_DIRECTORY "${CMAKE_TARGET_DIRECTORY}")
  add_custom_command(
    OUTPUT "${SRC_FILES}" "${INC_FILES}" "${SRC_GRPC_FILES}" "${INC_GRPC_FILES}"
    COMMAND ${PROTOC}
    ARGS --grpc_out "${CMAKE_TARGET_DIRECTORY}"
      --cpp_out "${CMAKE_TARGET_DIRECTORY}"
      -I "${CMAKE_CURRENT_LIST_DIR}/proto"
      --plugin=protoc-gen-grpc="${GRPC_CPP_PLUGIN}"
      "${CMAKE_CURRENT_LIST_DIR}/proto/*.proto"
    DEPENDS "${CMAKE_CURRENT_LIST_DIR}/proto/*.proto")

  include_directories("${CMAKE_CURRENT_BINARY_DIR}")

  add_library(neptune-profiler-proto STATIC
    ${SRC_FILES}
    ${SRC_GRPC_FILES}
  )

  target_link_libraries(neptune-profiler-proto
    ${_REFLECTION}
    ${_GRPC_GRPCPP}
    ${_PROTOBUF_LIBPROTOBUF})

  install(
    DIRECTORY ${CMAKE_TARGET_DIRECTORY}
    DESTINATION ${TARGET_DIRECTORY}
    FILES_MATCHING # install only matched files
    PATTERN "*.h" # select header files
  )

  install(TARGETS neptune-profiler-proto DESTINATION ${TARGET_DIRECTORY}/lib)

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

