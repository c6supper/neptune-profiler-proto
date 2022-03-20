#----------------------------------------------------------------
#  Copyright (c) Coding Nerd
#  Licensed under the Apache License, Version 2.0
#  See LICENSE in the project root for license information.
#----------------------------------------------------------------

cmake_minimum_required(VERSION 3.5.1)

set (CMAKE_CXX_STANDARD 11)

find_program(PROTOC "protoc")
if (NOT PROTOC)
    message(FATAL_ERROR "protoc not found!")
ENDIF()

find_program(GO "go")
if (NOT GO)
    message(FATAL_ERROR "golang not found!")
ENDIF()

find_program(PROTOC_GEN_DOC "protoc-gen-doc")
if (NOT PROTOC_GEN_DOC)
    message(FATAL_ERROR "protoc-gen-doc not found!")
ENDIF()
