set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/etc/cmake/Modules)

function(add_ada_target TARGET OUTPUT_FILE OUTPUT_DIRECTORY)
    set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    set(BINARY_DIR ${CMAKE_BINARY_DIR}/${OUTPUT_DIRECTORY})
    set(ALI_DIR ${CMAKE_BINARY_DIR}/gnat-ali)
    set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR})

    set(GPR_PROJECT ${SOURCE_DIR}/${TARGET}.gpr)

    if(NOT EXISTS ${GPR_PROJECT})
        set(GPR_PROJECT ${SOURCE_DIR}/${TARGET}/${TARGET}.gpr)
        set(BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/${TARGET})
    endif()

    file(MAKE_DIRECTORY ${BUILD_DIR} ${BINARY_DIR} ${ALI_DIR})

    set(GPR_FLAGS -F -P${GPR_PROJECT}
        -aP${CMAKE_SOURCE_DIR}/etc/gpr
        -XTARGET=${TARGET}
        -XSOURCE_DIR=${SOURCE_DIR}
        -XBUILD_DIR=${BUILD_DIR}
        -XOUTPUT_DIR=${BINARY_DIR}
        -XALI_DIR=${ALI_DIR}
        -XBUILD_TYPE=${CMAKE_BUILD_TYPE}
    )

    add_custom_target(${TARGET} ALL
        COMMENT "Building target ${TARGET}..."
        COMMAND gprbuild ${GPR_FLAGS}
    )

    add_custom_command(
        OUTPUT ${BINARY_DIR}/${OUTPUT_FILE}
        DEPENDS ${TARGET}
    )

    add_custom_target(clean-${TARGET}
        COMMENT "Cleaning up target ${TARGET}..."
        COMMAND gprclean -q ${GPR_FLAGS}
    )

    add_dependencies(clean-all clean-${TARGET})
endfunction()

function(add_ada_library TARGET)
    if("${ARGV1}" STREQUAL "SHARED")
        set(PREFIX ${CMAKE_STATIC_LIBRARY_PREFIX})
        set(SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})
    else()
        set(PREFIX ${CMAKE_SHARED_LIBRARY_PREFIX})
        set(SUFFIX ${CMAKE_SHARED_LIBRARY_SUFFIX})
    endif()

    add_ada_target(${TARGET} ${PREFIX}${TARGET}${SUFFIX} bin)
endfunction(add_ada_library)

function(add_ada_executable TARGET)
    add_ada_target(${TARGET} ${TARGET}${CMAKE_EXECUTABLE_SUFFIX} bin)
endfunction(add_ada_executable)

function(add_ada_test_executable TARGET)
   add_ada_target(${TARGET} ${TARGET}${CMAKE_EXECUTABLE_SUFFIX} tests)
endfunction()
