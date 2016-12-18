project(geometry)
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

include(${CMAKE_SOURCE_DIR}/etc/cmake/Common.cmake)

message("-- Choosing build type: ${CMAKE_BUILD_TYPE}")
add_custom_target(clean-all)

add_subdirectory(src)

if(NOT SKIP_TESTING)
    enable_testing()
    add_subdirectory(tests)
    add_custom_target(check
        COMMAND ${CMAKE_MAKE_PROGRAM} -f tests/Makefile
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
            --build-config "${CMAKE_BUILD_TYPE}"
    )
endif()
