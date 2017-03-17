# Client maintainer: julien.malik@c-s.fr
set(dashboard_module "SertitObject")
set(dashboard_module_url "https://github.com/sertit/SertitObject")


set(OTB_PROJECT OTB) # OTB / Monteverdi / Monteverdi2
set(OTB_ARCH x86) # x86 / amd64
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
include(${CTEST_SCRIPT_DIRECTORY}/raoul_common.cmake)
set(CTEST_BINARY_DIRECTORY "C:/OTB-RemoteModules/build/${dashboard_module}-${OTB_ARCH}")
set(CTEST_BUILD_NAME "Win7-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}-Static-${dashboard_module}")

set(dashboard_cache "
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
BUILD_EXAMPLES:BOOL=OFF
BUILD_SHARED_LIBS:BOOL=OFF
BUILD_TESTING:BOOL=ON
CMAKE_PREFIX_PATH:STRING=${OSGEO4W_ROOT}
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
OTB_BUILD_DEFAULT_MODULES:BOOL=OFF
Module_${dashboard_module}:BOOL=ON
")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
