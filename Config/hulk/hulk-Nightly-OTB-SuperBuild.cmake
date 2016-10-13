# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-SuperBuild")
set(dashboard_no_install 1)
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB/SuperBuild")
set(dashboard_binary_name "build/OTB-SuperBuild")

set(OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/OTB-SuperBuild)

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
OTB_DATA_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
DOWNLOAD_LOCATION:PATH=${CTEST_DASHBOARD_ROOT}/src/SuperBuild-archives
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_USE_QT4:BOOL=ON
USE_SYSTEM_QT4:BOOL=ON
USE_SYSTEM_SWIG:BOOL=ON
ENABLE_OTB_LARGE_INPUTS:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=/home/otbval/Data/OTB-LargeInput
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
BUILD_TESTING:BOOL=ON
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
