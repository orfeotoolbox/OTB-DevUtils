# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
set(CTEST_SITE "leod.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "MacOSX10.10-SuperBuild")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j8 -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_USE_LAUNCHERS ON)
set(CTEST_GIT_COMMAND "/opt/local/bin/git")

string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_root_name "tests")
set(dashboard_source_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src/SuperBuild")
set(dashboard_binary_name "${lcdashboard_model}/OTB-SuperBuild/build")

set(OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/install)

set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src)
set(dashboard_git_branch superbuild-versions)

set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)

list(APPEND CTEST_TEST_ARGS 
  BUILD ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build
)
list(APPEND CTEST_NOTES_FILES
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/CMakeCache.txt
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/otbConfigure.h
)

set(GDAL_EXTRA_OPT "--with-gif=/opt/local")

set(ENV{DISPLAY} ":0.0")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
OTB_DATA_ROOT:PATH=$ENV{HOME}/Data/OTB-Data
DOWNLOAD_LOCATION:PATH=$ENV{HOME}/Data/SuperBuild-archives
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_USE_QT4:BOOL=OFF
USE_SYSTEM_QT4:BOOL=OFF
USE_SYSTEM_SQLITE:BOOL=OFF
USE_SYSTEM_JPEG:BOOL=OFF
USE_SYSTEM_TIFF:BOOL=OFF
USE_SYSTEM_GEOTIFF:BOOL=OFF
OTB_USE_CURL:BOOL=OFF
ENABLE_OTB_LARGE_INPUTS:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=$ENV{HOME}/Data/OTB-LargeInput
GDAL_SB_EXTRA_OPTIONS:STRING=${GDAL_EXTRA_OPT}
OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF
BUILD_TESTING:BOOL=ON
")
endmacro()

macro(dashboard_hook_test)
# before testing, set the DYLD_LIBRARY_PATH
set(ENV{DYLD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib)
endmacro()

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/lib)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/bin)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/include)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
