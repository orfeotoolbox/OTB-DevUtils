set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/dashboard")
set(CTEST_SITE "otb-debian-testing.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Debian-sid-x86_64-SuperBuild")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 3)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_GIT_COMMAND "/usr/bin/git")
set(CTEST_USE_LAUNCHERS ON)

set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)

set(dashboard_source_name "otb/src/SuperBuild")
set(dashboard_binary_name "otb/build")
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/otb/src)
set(OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/otb/install)

#set(dashboard_git_branch "bugfix-1241")

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
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_DATA_ROOT:PATH=/home/otbval/dashboard/data/OTB-Data-shared
DOWNLOAD_LOCATION:PATH=/media/otbnas/otb/DataForTests/SuperBuild-archives
ENABLE_OTB_LARGE_INPUTS:BOOL=OFF

CMAKE_VERBOSE_MAKEFILE:BOOL=OFF

BUILD_TESTING:BOOL=ON

USE_SYSTEM_FREETYPE:BOOL=ON

QT4_SB_ENABLE_GTK:BOOL=ON

USE_SYSTEM_SWIG:BOOL=ON
USE_SYSTEM_PCRE:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON

OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_QWT:BOOL=ON

OTB_WRAP_JAVA:BOOL=OFF

PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python2.7
PYTHON_INCLUDE_DIR:PATH=/usr/include/python2.7
PYTHON_LIBRARY:FILEPATH=/usr/lib/x86_64-linux-gnu/libpython2.7.so

GENERATE_PACKAGE:BOOL=OFF
")
endmacro()


macro(dashboard_hook_test)
  set(ENV{LD_LIBRARY_PATH} ${OTB_INSTALL_PREFIX}/lib)
endmacro()

list(APPEND CTEST_NOTES_FILES
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/CMakeCache.txt
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/otbConfigure.h
)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
