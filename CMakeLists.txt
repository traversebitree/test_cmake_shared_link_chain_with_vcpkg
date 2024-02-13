cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
set(VCPKG_HANDLE_DOWNLOAD_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/cmake/VcpkgHandle.cmake")
set(VCPKG_HANDLE_VERSION "v0.4.2")
if(NOT EXISTS "${VCPKG_HANDLE_DOWNLOAD_LOCATION}")
  file(
    DOWNLOAD
    https://github.com/traversebitree/vcpkg-conan-handle-cmake/releases/download/${VCPKG_HANDLE_VERSION}/VcpkgHandle.cmake
    ${VCPKG_HANDLE_DOWNLOAD_LOCATION}
  )
endif()
set(BUILD_SHARED_LIBS TRUE)
include("${VCPKG_HANDLE_DOWNLOAD_LOCATION}")
project(main LANGUAGES CXX VERSION 1.2.3)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE)

if(MSVC)
  add_compile_options(/Zc:__cplusplus /EHsc)
endif()

if(APPLE) # APPLE put first
  set(CMAKE_INSTALL_RPATH "@loader_path")
elseif(UNIX)
  set(CMAKE_INSTALL_RPATH "$ORIGIN")
endif()

if(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
  add_compile_options("-fsanitize=address")
endif()

include(GNUInstallDirs)
include(cmake/InstallArtifacts.cmake)

find_package(fmt CONFIG REQUIRED GLOBAL)
find_package(TinyNPY CONFIG REQUIRED GLOBAL)
find_package(yaml-cpp CONFIG REQUIRED GLOBAL)

add_subdirectory(dylibsrc)
add_subdirectory(src)

install_target(EXEs main)
