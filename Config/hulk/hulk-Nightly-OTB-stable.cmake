# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(OTB_PROJECT OTB)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}-stable")
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/OTB-stable")

set(OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/OTB-stable)

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wextra
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wextra -Wno-cpp -std=c++11
CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=OFF
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ITK-4.10.0/lib/cmake/ITK-4.10

OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT4:BOOL=ON
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON
OTB_USE_MPI:BOOL=ON
OTB_USE_SPTW:BOOL=ON
OTB_USE_MAPNIK:BOOL=ON
OTB_USE_SHARK:BOOL=ON

MAPNIK_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/mapnik-2.0.0/include
MAPNIK_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/mapnik-2.0.0/lib/libmapnik2.so

OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ossim-1.8.20-3/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/ossim-1.8.20-3/lib/libossim.so

OpenCV_DIR:PATH=/usr/share/OpenCV
MUPARSERX_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/include

SHARK_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/shark/lib/libshark_debug.so
SHARK_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/shark/include

    ")
endmacro()

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${OTB_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
