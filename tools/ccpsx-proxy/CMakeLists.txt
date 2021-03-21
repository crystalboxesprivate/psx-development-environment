cmake_minimum_required(VERSION 3.20)
project(ccpsx_proxy)
add_executable(ccpsx_proxy ccpsx_proxy.cpp)
add_custom_command(TARGET ccpsx_proxy 
                   POST_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:ccpsx_proxy> ${CMAKE_CURRENT_SOURCE_DIR}/../../GNU)
