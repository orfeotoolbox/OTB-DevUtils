# Client maintainer: julien.malik@c-s.fr
set(OTB_PROJECT Monteverdi2) # OTB / Monteverdi / Monteverdi2 / Ice
set(OTB_ARCH x86) # x86 / amd64
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Win7-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}")
include(${CTEST_SCRIPT_DIRECTORY}/ironhide_common.cmake)

set(dashboard_source_name "sources/monteverdi")
set(dashboard_binary_name "build/monteverdi/develop")
set(MVD_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/monteverdi/develop)

set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/monteverdi2.git")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
CMAKE_INSTALL_PREFIX:PATH=${MVD_INSTALL_PREFIX}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_INCLUDE_PATH:PATH=$ENV{OSGEO4W_ROOT}/include
CMAKE_LIBRARY_PATH:PATH=$ENV{OSGEO4W_ROOT}/lib

BUILD_TESTING:BOOL=ON
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
#OTB_DATA_LARGEINPUT_ROOT:PATH=

Monteverdi_USE_CPACK:BOOL=ON

OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/otb/develop/lib/cmake/OTB-5.5

#ICUUC_INCLUDE_DIR:PATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/include
#ICUUC_LIBRARY:FILEPATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/lib/icuuc.lib
#LTDL_INCLUDE_DIR:PATH=C:/Program Files (x86)/GnuWin32/include
#LTDL_LIBRARY:FILEPATH=C:/Program Files (x86)/GnuWin32/lib/ltdl.lib
")
endmacro()

macro(dashboard_hook_test)
  set(_SAVE_BUILD_COMMAND ${CTEST_BUILD_COMMAND})
  set(CTEST_BUILD_COMMAND "${dashboard_build_command} PACKAGES")
  ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
  set(CTEST_BUILD_COMMAND ${_SAVE_BUILD_COMMAND})
endmacro()

#Remove install dir
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_PREFIX})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
