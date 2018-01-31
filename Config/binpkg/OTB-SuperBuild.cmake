set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "CentOS-5-x86_64-SuperBuild")
include(${CTEST_SCRIPT_DIRECTORY}/binpkg_common.cmake)

set(dashboard_source_name "otb/src/SuperBuild")
set(dashboard_binary_name "otb/build")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/otb/src)
set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/install)

#set(dashboard_git_branch "bugfix-1241")

list(APPEND CTEST_TEST_ARGS
  BUILD ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build
)

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_DATA_ROOT:PATH=/media/otbnas/otb/DataForTests/OTB-Data
DOWNLOAD_LOCATION:PATH=/media/otbnas/otb/DataForTests/SuperBuild-archives
CMAKE_CXX_FLAGS:STRING='-w -fPIC -fpermissive'
CMAKE_C_FLAGS:STRING='-w -fPIC -fpermissive'

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
#OTB_DATA_LARGEINPUT_ROOT:STRING=/media/otbnas/otb/OTB-LargeInput

BUILD_TESTING:BOOL=ON

QT4_SB_ENABLE_GTK:BOOL=ON
USE_SYSTEM_FREETYPE:BOOL=ON

OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_QWT:BOOL=ON

OTB_USE_MUPARSERX:BOOL=OFF
OTB_USE_SHARK:BOOL=OFF

USE_SYSTEM_SWIG:BOOL=ON
USE_SYSTEM_PCRE:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python26
PYTHON_INCLUDE_DIR:PATH=/usr/include/python2.6
PYTHON_LIBRARY:FILEPATH=/usr/lib64/libpython2.6.so

OTB_WRAP_JAVA:BOOL=OFF

GENERATE_PACKAGE:BOOL=OFF

")
endmacro()


macro(dashboard_hook_test)
  set(ENV{LD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib)
endmacro()

list(APPEND CTEST_NOTES_FILES
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/CMakeCache.txt
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/otbConfigure.h
)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
