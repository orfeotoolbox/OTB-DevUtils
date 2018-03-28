# Client maintainer: julien.malik@c-s.fr
#RK: DONT EVEN THINK OF ACTIVATING SYSTEM LIBRARY AND MAKING OTB PACKAGE!
# THIS WILL REQUIRE SPECIFIC PATCHING IN GENERATED CMAKE FILES
# SEE otb.git/Packaging/install_cmake_files.cmake

set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_CONFIGURATION_TYPE Release)
set(CTEST_BUILD_NAME "MacOSX10.10-SuperBuild")
set(dashboard_no_install 1)
set(CTEST_BUILD_FLAGS "-j4 -k" )

set(CTEST_TEST_ARGS PARALLEL_LEVEL 3)
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)

set(dashboard_source_name "nightly/OTB-${CTEST_BUILD_CONFIGURATION}/src/SuperBuild")
set(dashboard_binary_name "nightly/OTB-SuperBuild/build")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/nightly/OTB-${CTEST_BUILD_CONFIGURATION}/src)

set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/nightly/OTB-SuperBuild/install)

list(APPEND CTEST_TEST_ARGS
  BUILD ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build
)

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
CMAKE_VERBOSE_MAKEFILE:BOOL=OFF
CMAKE_CXX_FLAGS:STRING='-std=c++11'
BUILD_TESTING:BOOL=ON
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data
DOWNLOAD_LOCATION:PATH=$ENV{HOME}/Data/SuperBuild-archives
WITH_REMOTE_MODULES:BOOL=ON
OTB_WRAP_PYTHON3:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
#GDAL_SB_EXTRA_OPTIONS:STRING='--with-python=/usr/bin/python'
")
endmacro()

#OTB_ADDITIONAL_CACHE:STRING='-DOTB_SHOW_ALL_MSG_DEBUG:BOOL=ON'

macro(dashboard_hook_test)
  set(ENV{LD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib)
endmacro()

list(APPEND CTEST_NOTES_FILES
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/CMakeCache.txt
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/otbConfigure.h
)

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/lib)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/bin)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/include)


include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
