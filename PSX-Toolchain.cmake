message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}.")

set(PSYQ_DIR $ENV{PSYQ_DIR})

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_CROSSCOMPILING 1)

set(PSX True)

set(CMAKE_C_COMPILER "$ENV{COMPILER_PATH}/ccpsx_proxy.exe")
set(CMAKE_CXX_COMPILER "$ENV{COMPILER_PATH}/ccpsx_proxy.exe")
set(CMAKE_ASM_COMPILER "$ENV{COMPILER_PATH}/ccpsx_proxy.exe")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_SYSROOT ${PSYQ_DIR})

set(CMAKE_C_FLAGS "-O3 -Dpsx -Xo0x80010000")

include_directories(${PSYQ_DIR}/include)

link_directories(${PSYQ_DIR}/lib)

link_libraries(
  libgs
  libgte
  libgpu
  libspu
  libsnd
  libetc
  libapi
  libsn
  libc
  libcd
  libcard
  libmath
)

function(finalize_psx_build target)
  add_custom_command(TARGET ${target} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${target} ${CMAKE_BINARY_DIR}/${target}.cpe)
  add_custom_command(TARGET ${target} POST_BUILD COMMAND cpe2x ${CMAKE_BINARY_DIR}/${target}.cpe)
endfunction()
