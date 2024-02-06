add_library(mydylib dylibsrc.cpp)

target_include_directories(
  mydylib PUBLIC "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/dylibsrc>" "$<INSTALL_INTERFACE:dylibsrc>"
  PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
)

target_link_libraries(mydylib PRIVATE fmt::fmt)
include(GenerateExportHeader)
generate_export_header(mydylib)
