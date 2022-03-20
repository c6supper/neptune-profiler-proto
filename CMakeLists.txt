# Minimum CMake required
cmake_minimum_required(VERSION 3.5)

if(neptune_VERBOSE)
  message(STATUS "Neptune Buffers Configuring...")
endif()

# CMake policies
cmake_policy(SET CMP0022 NEW)
# On MacOS use @rpath/ for target's install name prefix path
if (POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif ()
# Clear VERSION variables when no VERSION is given to project()
if(POLICY CMP0048)
  cmake_policy(SET CMP0048 NEW)
endif()
# MSVC runtime library flags are selected by an abstraction.
if(POLICY CMP0091)
  cmake_policy(SET CMP0091 NEW)
endif()

project(neptune-profiler-proto)

# Add c++11 flags
if (CYGWIN)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11")
else()
  set(CMAKE_CXX_STANDARD 11)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
endif()

# The Intel compiler isn't able to deal with noinline member functions of
# template classes defined in headers.  As such it spams the output with
#   warning #2196: routine is both "inline" and "noinline"
# This silences that warning.
if (CMAKE_CXX_COMPILER_ID MATCHES Intel)
  string(APPEND CMAKE_CXX_FLAGS " -diag-disable=2196")
endif()

# INSTALL default: off
option(INSTALL "Install neptune binaries and files" OFF)

# doc default: off
option(DOC "Generate and update the doc files" OFF)

if (BUILD_SHARED_LIBS)
  set(neptune_BUILD_SHARED_LIBS_DEFAULT ON)
else (BUILD_SHARED_LIBS)
  set(neptune_BUILD_SHARED_LIBS_DEFAULT OFF)
endif (BUILD_SHARED_LIBS)
option(neptune_BUILD_SHARED_LIBS "Build Shared Libraries" ${neptune_BUILD_SHARED_LIBS_DEFAULT})

if (DOC)
  include(cmake/doc.cmake)
endif (DOC)