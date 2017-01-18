# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(dashboard_no_install 1)
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-SuperBuild-${dashboard_git_branch}")

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB/SuperBuild")
set(dashboard_binary_name "build/OTB-SuperBuild-stable")

set(OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/OTB-SuperBuild-stable)

set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/src/OTB)
#set(dashboard_git_branch sb-gdal-s2)

list(APPEND CTEST_TEST_ARGS 
  BUILD ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build
)
list(APPEND CTEST_NOTES_FILES
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/CMakeCache.txt
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/otbConfigure.h
)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_CXX_FLAGS:STRING=-std=c++11
OTB_DATA_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
DOWNLOAD_LOCATION:PATH=${CTEST_DASHBOARD_ROOT}/src/SuperBuild-archives
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=/home/otbval/Data/OTB-LargeInput

USE_SYSTEM_SWIG:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=OFF

BUILD_TESTING:BOOL=ON

OTB_USE_QT4:BOOL=ON
QT4_SB_ENABLE_GTK:BOOL=ON
USE_SYSTEM_QT4:BOOL=OFF
USE_SYSTEM_FREETYPE:BOOL=ON
USE_SYSTEM_PNG:BOOL=ON
USE_SYSTEM_EXPAT:BOOL=ON
USE_SYSTEM_ZLIB:BOOL=ON

OTB_USE_QWT:BOOL=ON

OTB_USE_SHARK:BOOL=ON

OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON

OTB_USE_MUPARSERX:BOOL=ON

GENERATE_PACKAGE:BOOL=OFF
")
endmacro()


macro(dashboard_hook_test)
set(ENV{LD_LIBRARY_PATH} ${OTB_INSTALL_PREFIX}/lib)
endmacro()

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${OTB_INSTALL_PREFIX})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX}/lib)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX}/bin)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX}/include)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
