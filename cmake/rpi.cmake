#
# MIT License
#
# Copyright (c) 2018 Joel Winarske
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# create app toolchain file
set(PKG_CONFIG_PATH ${TARGET_SYSROOT}/opt/vc/lib/pkgconfig)
configure_file(${CMAKE_SOURCE_DIR}/cmake/app.clang.toolchain.cmake.in ${CMAKE_BINARY_DIR}/app.toolchain.cmake @ONLY)

option(BUILD_PI_USERLAND "Build Pi userland repo - !!replaces sysroot/opt/vc!!" OFF)
if(BUILD_PI_USERLAND)

    ExternalProject_Add(pi_userland
        GIT_REPOSITORY https://github.com/jwinarske/userland.git
        GIT_TAG vidtext_fix
        GIT_SHALLOW true
        BUILD_IN_SOURCE 0
        PATCH_COMMAND rm -rf ${TARGET_SYSROOT}/opt/vc
        UPDATE_COMMAND ""
        CMAKE_ARGS
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/app.toolchain.cmake
            -DCMAKE_INSTALL_PREFIX=${TARGET_SYSROOT}
            -DVMCS_INSTALL_PREFIX=${TARGET_SYSROOT}/opt/vc
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
    )
    if(BUILD_SYSROOT)    
        add_dependencies(pi_userland sysroot)
    endif()        
    if(BUILD_TOOLCHAIN)
        add_dependencies(pi_userland binutils)
    endif()
    if(BUILD_COMPILER_RT)
        add_dependencies(pi_userland compiler-rt)
    endif()

endif()

option(BUILD_HELLO_PI "Build the apps in {sysroot}/opt/vc/src/hello_pi" ON)
if(BUILD_HELLO_PI)

    # These are C apps...
    ExternalProject_Add(hello_pi
        DOWNLOAD_COMMAND ""
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/cmake/hello_pi.cmake
            ${TARGET_SYSROOT}/opt/vc/src/hello_pi/CMakeLists.txt
        SOURCE_DIR ${TARGET_SYSROOT}/opt/vc/src/hello_pi
        BUILD_IN_SOURCE 0
        UPDATE_COMMAND ""
        CMAKE_ARGS
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/app.toolchain.cmake
            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/target
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
    )
    if(BUILD_SYSROOT)
        add_dependencies(hello_pi sysroot)
    endif()    
    if(BUILD_TOOLCHAIN)
        add_dependencies(hello_pi binutils)
    endif()
    if(BUILD_COMPILER_RT)
        add_dependencies(hello_pi compiler-rt)
    endif()
    if(BUILD_PI_USERLAND)
        add_dependencies(hello_pi pi_userland)
    endif()

endif()

option(BUILD_TSLIB "Checkout and build tslib for target" ON)
if(BUILD_TSLIB)
    ExternalProject_Add(tslib
        GIT_REPOSITORY https://github.com/kergoth/tslib.git
        GIT_TAG master
        GIT_SHALLOW true
        BUILD_IN_SOURCE 0
        UPDATE_COMMAND ""
        CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/app.toolchain.cmake
        -DCMAKE_INSTALL_PREFIX=${TARGET_SYSROOT}
        -DCMAKE_BUILD_TYPE=MinSizeRel
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
    )
    if(BUILD_TOOLCHAIN)
        add_dependencies(tslib clang)
    endif()
    if(BUILD_COMPILER_RT)
        add_dependencies(tslib compiler-rt)
    endif()
    if(BUILD_SYSROOT)
        add_dependencies(tslib sysroot)
    endif()
endif()

#
# build flutter executable
#

set(FLUTTER_TARGET_NAME "Raspberry Pi")
ExternalProject_Add(rpi_flutter
    GIT_REPOSITORY https://github.com/jwinarske/flutter_from_scratch.git
    GIT_TAG clang_fixes
    GIT_SHALLOW true
    PATCH_COMMAND ""
    BUILD_IN_SOURCE 0
    UPDATE_COMMAND ""
    CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/app.toolchain.cmake
        -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/target
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DENGINE_INCLUDE_DIR=${ENGINE_INCLUDE_DIR}
        -DENGINE_LIBRARIES_DIR=${ENGINE_LIBRARIES_DIR}
)
if(BUILD_SYSROOT)
    add_dependencies(rpi_flutter sysroot)
endif()    
add_dependencies(rpi_flutter engine)
