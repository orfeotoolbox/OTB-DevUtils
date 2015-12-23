
set(dashboard_model Nightly)

set (CTEST_DASHBOARD_ROOT "/home/otbtesting")
set (CTEST_SITE "pc-christophe.cst.cnes.fr" )
set (CTEST_BUILD_CONFIGURATION "Release")
set (CTEST_BUILD_NAME "Fedora22-64bits-${CTEST_BUILD_CONFIGURATION}")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -k install" )

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}/install")
set (ICE_INSTALL_PREFIX "${INSTALLROOT}/orfeo/trunk/Ice/${CTEST_BUILD_CONFIGURATION}")
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory "${ICE_INSTALL_PREFIX}")

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/Ice")
set(dashboard_binary_name "build/orfeo/trunk/Ice")

macro(dashboard_hook_init)
set (dashboard_cache "${dashboard_cache}

BUILDNAME:STRING=${CTEST_BUILD_NAME}
BUILD_ICE_APPLICATION:BOOL=ON

SITE:STRING=${CTEST_SITE}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
BUILD_TESTING:BOOL=ON

CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall -Wextra -Wno-cpp
CMAKE_INSTALL_PREFIX:PATH=${ICE_INSTALL_PREFIX}

GLFW_INCLUDE_DIR:PATH=/usr/include/GLFW
GLFW_LIBRARY:PATH=/usr/lib64/libglfw.so

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/itk/stable/${CTEST_BUILD_CONFIGURATION}
OTB_DIR:STRING=${CTEST_DASHBOARD_ROOT}/install/orfeo/trunk/OTB-Nightly/${CTEST_BUILD_CONFIGURATION}/lib/cmake/OTB-5.3/
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
