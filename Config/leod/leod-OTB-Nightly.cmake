# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}")
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)

string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_root_name "tests")
set(dashboard_source_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build")
set(CTEST_INSTALL_PREFIX "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/install")

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
#set(dashboard_hg_branch "default")

set(dashboard_git_features_list "${CTEST_SCRIPT_DIRECTORY}/../feature_branches.txt")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_PREFIX}

CMAKE_PREFIX_PATH:PATH=/opt/local

CMAKE_C_FLAGS:STRING= -fPIC -Wall
CMAKE_CXX_FLAGS:STRING= -fPIC -Wall -Wno-gnu -Wno-gnu-static-float-init -Wno-\\\\#warnings

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
OTB_USE_QT4:BOOL=ON
OTB_USE_QWT:BOOL=ON
# Ice module
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON
OTB_USE_SHARK:BOOL=ON

PYTHON_EXECUTABLE:FILEPATH=/opt/local/bin/python2.7
PYTHON_INCLUDE_DIR:PATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Headers
PYTHON_LIBRARY:FILEPATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/itkv4/install/lib/cmake/ITK-4.9

GDAL_CONFIG:PATH=/opt/local/bin/gdal-config
GDAL_CONFIG_CHECKING:BOOL=ON
GDAL_INCLUDE_DIR:PATH=/opt/local/include
GDAL_LIBRARY:PATH=/opt/local/lib/libgdal.dylib

OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/ossim/install-1.8.20-3/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/ossim/install-1.8.20-3/lib/libossim.dylib

MUPARSER_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/muparser/install/include
MUPARSER_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/muparser/install/lib/libmuparser.dylib

MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/muparserx/install_4.0.7/include/muparserx
MUPARSERX_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/muparserx/install_4.0.7/lib/libmuparserx.dylib

LIBSVM_INCLUDE_DIR:PATH=/opt/local/include
LIBSVM_LIBRARY:FILEPATH=/opt/local/lib/libsvm.dylib

GLUT_glut_LIBRARY=/usr/X11R6/lib/libglut.3.dylib
GLUT_INCLUDE_DIR=/usr/X11R6/include

SHARK_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/shark/install/lib/libshark.dylib
SHARK_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/shark/install/include
    ")

endmacro()

#remove install dir
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_PREFIX})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_PREFIX})

#
# Specific cache for feature branches {

set( dashboard_cache_for_rfc-98-qwt6 "
# QWT
QWT_INCLUDE_DIR=$ENV{HOME}/local/qwt-6.1.3/lib/qwt.framework/Headers
QWT_LIBRARY=$ENV{HOME}/local/qwt-6.1.3/lib/qwt.framework/qwt
" )

# } Specific cache for feature branches.
#

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
