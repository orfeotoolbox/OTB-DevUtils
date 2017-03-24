# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(OTB_PROJECT OTB)
set(CTEST_BUILD_CONFIGURATION Release)
include(${CTEST_SCRIPT_DIRECTORY}/dora_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
set(CTEST_BUILD_NAME "Ubuntu16.04-64bits-${CTEST_BUILD_CONFIGURATION}-${dashboard_git_branch}")

string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_root_name "tests")
set(dashboard_source_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build-stable")

set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/install-stable)

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}

CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wextra
CMAKE_CXX_FLAGS:STRING=-std=c++11 -fPIC -Wall -Wextra -Wno-cpp

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT4:BOOL=ON
# Ice module
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON

OTB_USE_MPI:BOOL=ON
OTB_USE_SPTW:BOOL=OFF

MUPARSERX_LIBRARY:PATH=/home/otbval/Tools/muparserx/install/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=/home/otbval/Tools/muparserx/install/include

#MAPNIK_INCLUDE_DIR:PATH=/home/otbval/Tools/mapnik/install/include
#MAPNIK_LIBRARY:FILEPATH=/home/otbval/Tools/mapnik/install/lib/libmapnik2.so
    ")
endmacro()

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
