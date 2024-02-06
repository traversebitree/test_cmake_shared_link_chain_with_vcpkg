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
include("${VCPKG_HANDLE_DOWNLOAD_LOCATION}")
project(main LANGUAGES CXX VERSION 1.2.3)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN TRUE)

if(MSVC)
  add_compile_options(/Zc:__cplusplus /EHsc)
endif()

set(CMAKE_INSTALL_RPATH "$ORIGIN")

if(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
  add_compile_options("-fsanitize=address")
endif()

include(GNUInstallDirs)

set(BUILD_SHARED_LIBS TRUE)

find_package(fmt CONFIG REQUIRED GLOBAL)

add_subdirectory(dylibsrc)
add_subdirectory(src)

install(TARGETS main RUNTIME COMPONENT "main_exe" DESTINATION ${CMAKE_INSTALL_BINDIR})

install(FILES $<TARGET_RUNTIME_DLLS:main> COMPONENT "main_dll" DESTINATION ${CMAKE_INSTALL_BINDIR})

if(MINGW AND ${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
  get_filename_component(mingw_path ${CMAKE_CXX_COMPILER} PATH)
  file(GLOB mingw_runtimes "${mingw_path}/*.dll")
  list(FILTER mingw_runtimes EXCLUDE REGEX "fortran")
  set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${mingw_runtimes})
  install(PROGRAMS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT "main_dll")
endif()

if(NOT WIN32)
  install(
    CODE [[
                file(GET_RUNTIME_DEPENDENCIES
                RESOLVED_DEPENDENCIES_VAR RESOLVED_DEPS
                UNRESOLVED_DEPENDENCIES_VAR UNRESOLVED_DEPS
                LIBRARIES $<TARGET_FILE:main>
                DIRECTORIES $<TARGET_FILE_DIR:main>
                PRE_INCLUDE_REGEXES $<TARGET_FILE_DIR:main>
                POST_INCLUDE_REGEXES $<TARGET_FILE_DIR:main>
                )
                foreach(DEP_LIB ${RESOLVED_DEPS})
                file(INSTALL ${DEP_LIB} DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
                endforeach()
                ]]
    COMPONENT "main_dll"
  )
endif()

add_custom_target(
  install_project
  COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR} --component "main_dll" --config "${CMAKE_BUILD_TYPE}"
  COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR} --component "main_exe" --config "${CMAKE_BUILD_TYPE}"
  DEPENDS main
)
