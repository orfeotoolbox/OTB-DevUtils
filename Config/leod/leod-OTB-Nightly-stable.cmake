# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(OTB_PROJECT OTB)
set(CTEST_BUILD_CONFIGURATION Release)
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)

set(CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}-${dashboard_git_branch}")
string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_root_name "tests")
set(dashboard_source_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build-stable")
set(CTEST_INSTALL_PREFIX "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/install-stable")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_PREFIX}

CMAKE_PREFIX_PATH:PATH=/Users/otbval/Dashboard/xdk-6.6

CMAKE_C_FLAGS:STRING= -fPIC -Wall
CMAKE_CXX_FLAGS:STRING= -fPIC -Wall -Wno-gnu -Wno-gnu-static-float-init -Wno-\\\\#warnings -std=c++11

OPENTHREADS_CONFIG_HAS_BEEN_RUN_BEFORE:BOOL=ON

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT:BOOL=ON
OTB_USE_QWT:BOOL=ON
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_SHARK:BOOL=ON
OTB_USE_OPENMP:BOOL=ON
GDAL_CONFIG_CHECKING:BOOL=ON

PYTHON_EXECUTABLE:FILEPATH=/opt/local/bin/python2.7
PYTHON_INCLUDE_DIR:PATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Headers
PYTHON_LIBRARY:FILEPATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python

OPENGL_INCLUDE_DIR:PATH=/System/Library/Frameworks/OpenGL.framework
OPENGL_gl_LIBRARY:PATH=/System/Library/Frameworks/OpenGL.framework
OPENGL_glu_LIBRARY:PATH=/System/Library/Frameworks/AGL.framework
")
endmacro()

#remove install dir
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_PREFIX})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
