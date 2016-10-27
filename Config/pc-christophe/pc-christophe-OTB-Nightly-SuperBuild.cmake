# Client maintainer: manuel.grizonnetcnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora22-64bits-SuperBuild")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j2 -k")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 2)
set(CTEST_TEST_TIMEOUT 1500)

string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly/SuperBuild")
set(dashboard_binary_name "build/orfeo/trunk/OTB-SuperBuild")

set(OTB_INSTALL_PREFIX "${CTEST_DASHBOARD_ROOT}/install/OTB-SuperBuild")

set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/OTB-Nightly)
#set(dashboard_git_branch release-5.6)

list(APPEND CTEST_TEST_ARGS
  BUILD ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build
)
list(APPEND CTEST_NOTES_FILES
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/CMakeCache.txt
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/otbConfigure.h
)

set(GDAL_EXTRA_OPT "--with-python")

macro(dashboard_hook_start)
# before testing, set the LD_LIBRARY_PATH
set(ENV{LD_LIBRARY_PATH} ${OTB_INSTALL_PREFIX}/lib)
endmacro()

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-fopenmp
CMAKE_CXX_FLAGS:STRING=-fopenmp --std=c++11

CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
OTB_DATA_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-Data
DOWNLOAD_LOCATION:PATH=${CTEST_DASHBOARD_ROOT}/sources/archives-superbuild-develop/
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=/media/TeraDisk2/LargeInput
GDAL_SB_EXTRA_OPTIONS:STRING=${GDAL_EXTRA_OPT}
BUILD_TESTING:BOOL=ON

OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_QWT:BOOL=ON
OTB_USE_SHARK:BOOL=OFF

USE_SYSTEM_QT4:BOOL=OFF
USE_SYSTEM_QWT:BOOL=OFF
GENERATE_PACKAGE:BOOL=OFF
")
# Don't use system's QWT above because FindQwt.cmake can't find it, see:
# https://bugs.orfeo-toolbox.org/view.php?id=1177
# It would work if QWT_LIBRARY and QWT_INCLUDE_DIR were manually set
endmacro()

macro(dashboard_hook_build)
# before building, set the PYTHONPATH to allow custom install for python bindings
set(ENV{PYTHONPATH} ${OTB_INSTALL_PREFIX}/lib)
#and LD_LIBRARY_PATH
set(ENV{LD_LIBRARY_PATH} ${OTB_INSTALL_PREFIX}/lib)
endmacro()

macro(dashboard_hook_test)
# before testing, set the LD_LIBRARY_PATH
set(ENV{LD_LIBRARY_PATH} ${OTB_INSTALL_PREFIX}/lib)
endmacro()

#execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${OTB_INSTALL_PREFIX})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX}/lib)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX}/bin)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${OTB_INSTALL_PREFIX}/include)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)

set(dashboard_git_features_list "${CTEST_SCRIPT_DIRECTORY}/../feature_branches.txt")
