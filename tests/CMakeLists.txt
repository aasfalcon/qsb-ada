add_ada_executable(ada_tests)
add_dependencies(ada_tests sound)

add_test(NAME ada_tests COMMAND ${CMAKE_BINARY_DIR}/bin/ada_tests)
