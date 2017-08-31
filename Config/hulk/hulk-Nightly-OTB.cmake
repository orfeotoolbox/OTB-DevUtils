# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}")

include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/OTB-${CTEST_BUILD_CONFIGURATION}")

set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/install/OTB-${CTEST_BUILD_CONFIGURATION})

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")

set(dashboard_git_features_list "${CTEST_SCRIPT_DIRECTORY}/../feature_branches.txt")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-cpp -Wno-unknown-pragmas

CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_DOCUMENTATION:BOOL=ON

OTB_SHOW_ALL_MSG_DEBUG:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ITK-4.10.0/lib/cmake/ITK-4.10

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
OTB_USE_MPI:BOOL=ON
OTB_USE_SPTW:BOOL=ON
OTB_USE_OPENMP:BOOL=ON
OTB_USE_OPENMP:BOOL=ON
OTB_USE_MAPNIK:BOOL=ON
OTB_USE_SHARK:BOOL=ON

MAPNIK_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/mapnik-2.0.0/include
MAPNIK_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/mapnik-2.0.0/lib/libmapnik2.so

OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ossim-1.8.20-3/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/ossim-1.8.20-3/lib/libossim.so

OpenCV_DIR:PATH=/usr/share/OpenCV
MUPARSERX_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/include

SHARK_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/shark/lib/libshark_debug.so
SHARK_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/shark/include

OTB_DOXYGEN_ITK_TAGFILE:FILEPATH=${CTEST_DASHBOARD_ROOT}/src/InsightDoxygenDocTag-4.8
OTB_DOXYGEN_ITK_DOXYGEN_URL:STRING=\"http://www.itk.org/Doxygen48/html\"

    ")
endmacro()

macro(dashboard_hook_end)
  if("${dashboard_current_branch}" STREQUAL "nightly")
    ctest_build(TARGET "Documentation")
  endif()
endmacro()

set(dashboard_cache_for_rfc-98-qwt6 "CMAKE_PREFIX_PATH:PATH=$ENV{HOME}/local/qwt-6.1.3")

execute_process (COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process (COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
