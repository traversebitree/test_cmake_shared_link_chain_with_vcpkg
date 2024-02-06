add_executable(main main.cpp)
target_link_libraries(main PRIVATE mydylib)

if(WIN32)
  add_custom_command(
    TARGET main
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:main> $<TARGET_FILE_DIR:main>
    COMMAND_EXPAND_LISTS
  )
endif()

# set_target_properties(main PROPERTIES INSTALL_RPATH "$ORIGIN")
