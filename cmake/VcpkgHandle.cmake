# Put this before project() !!!
include_guard(GLOBAL)

cmake_host_system_information(RESULT _MACHINE_HARDWARE_NAME QUERY OS_PLATFORM)
string(TOLOWER "${_MACHINE_HARDWARE_NAME}" _MACHINE_HARDWARE_NAME_LOWER)

if((_MACHINE_HARDWARE_NAME_LOWER MATCHES "^arm"
    OR _MACHINE_HARDWARE_NAME_LOWER MATCHES "^aarch64"
    OR _MACHINE_HARDWARE_NAME_LOWER MATCHES "^s390x"
    OR _MACHINE_HARDWARE_NAME_LOWER MATCHES "^ppc64"
   )
   AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"
   AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"
)
  set(ENV{VCPKG_FORCE_SYSTEM_BINARIES} TRUE)
endif()

set(X_VCPKG_APPLOCAL_DEPS_INSTALL TRUE
    CACHE BOOL "Automatically copy dependencies into the install target directory for executables."
)
set(__TEMP_FILE "${CMAKE_BINARY_DIR}/tmp.txt")
set(_VCPKG_ROOT_DIR "${CMAKE_SOURCE_DIR}/.vcpkg")
set(_VCPKG_SOURCE_DIR "${_VCPKG_ROOT_DIR}/vcpkg-src")
set(_VCPKG_SUBBUILD_DIR "${_VCPKG_ROOT_DIR}/vcpkg-subbuild")
set(_VCPKG_DOWNLOAD_DIR "${_VCPKG_ROOT_DIR}")
set(_VCPKG_BINARY_DIR "${_VCPKG_ROOT_DIR}/vcpkg-build")

if(WIN32)
  set(_VCPKG_EXECUTEABLE "${_VCPKG_SOURCE_DIR}/vcpkg.exe")
else()
  set(_VCPKG_EXECUTEABLE "${_VCPKG_SOURCE_DIR}/vcpkg")
endif()

if(NOT EXISTS "${_VCPKG_EXECUTEABLE}")
  file(REMOVE_RECURSE "${_VCPKG_ROOT_DIR}")
  include(FetchContent)
  message(STATUS "Fetching vcpkg ...")
  FetchContent_Declare(
    _vcpkg
    GIT_REPOSITORY "https://github.com/microsoft/vcpkg.git"
    DOWNLOAD_DIR
    "${_VCPKG_DOWNLOAD_DIR}"
    SOURCE_DIR
    "${_VCPKG_SOURCE_DIR}"
    SUBBUILD_DIR
    "${_VCPKG_SUBBUILD_DIR}"
    BINARY_DIR
    "${_VCPKG_BINARY_DIR}"
  )
  FetchContent_MakeAvailable(_vcpkg)
endif()

if(CMAKE_GENERATOR MATCHES "MinGW")
  set(MINGW TRUE)
endif()

set(VCPKG_INSTALLED_DIR "${_VCPKG_ROOT_DIR}/vcpkg-installed")
set(Z_VCPKG_ROOT_DIR "${_VCPKG_SOURCE_DIR}")
set(CMAKE_TOOLCHAIN_FILE "${_VCPKG_SOURCE_DIR}/scripts/buildsystems/vcpkg.cmake")
