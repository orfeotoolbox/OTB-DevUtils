set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/dashboard")
set(CTEST_SITE "otb-debian-testing.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Debian-sid-x86_64-SuperBuild")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 3)
set(CTEST_TEST_TIMEOUT 1500)

set(dashboard_source_name "otb/src/SuperBuild")
set(dashboard_binary_name "otb/build")
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/otb/src)
set(OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/otb/install)

set(CTEST_DASHBOARD_TRACK "develop")
set(dashboard_git_branch "shark_pkg")

list(APPEND CTEST_TEST_ARGS
  BUILD ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build
)

# For centos 5
# CMAKE_CXX_FLAGS:STRING='-w -fPIC -fpermissive'
# CMAKE_C_FLAGS:STRING='-w -fPIC -fpermissive'

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_CXX_FLAGS:STRING='-std=c++11'
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_DATA_ROOT:PATH=/home/otbval/dashboard/data/OTB-Data-shared
DOWNLOAD_LOCATION:PATH=/media/otbnas/otb/DataForTests/SuperBuild-archives

ENABLE_OTB_LARGE_INPUTS:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/otbnas/otb/OTB-LargeInput

CMAKE_VERBOSE_MAKEFILE:BOOL=OFF
BUILD_TESTING:BOOL=ON

USE_SYSTEM_FREETYPE:BOOL=OFF
QT4_SB_ENABLE_GTK:BOOL=OFF

USE_SYSTEM_SWIG:BOOL=ON
USE_SYSTEM_PCRE:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON

OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_QWT:BOOL=ON
OTB_USE_SHARK:BOOL=ON

OTB_WRAP_JAVA:BOOL=OFF

GENERATE_PACKAGE:BOOL=OFF
")
endmacro()


macro(dashboard_hook_test)
  set(ENV{LD_LIBRARY_PATH} ${OTB_INSTALL_PREFIX}/lib)
endmacro()

list(APPEND CTEST_NOTES_FILES
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/CMakeCache.txt
)

#  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/otbConfigure.h

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
