#Contact: Pierre Lassalle <lassallepierre34@gmail.com>

# otb_fetch_module(otbGRM
# 	"GRM OTB Application for region merging segmentation of very high resolution satellite scenes."
# 	GIT_REPOSITORY http://tully.ups-tlse.fr/lassallep/grm/
# 	GIT_TAG master
# 	)

set(dashboard_module "otbGRM")
set(dashboard_module_url "http://tully.ups-tlse.fr/lassallep/grm.git")

set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/data/dashboard")
set(CTEST_SITE "bumblebee.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_USE_LAUNCHERS OFF)
set(CMAKE_COMMAND "/data/tools/cmake-git/install/bin/cmake")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k" )
set(MXE_ROOT "/data/tools/mxe")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "otb")
set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-${dashboard_module}-${MXE_TARGET_ARCH}")

set(dashboard_cache "
BUILD_EXAMPLES:BOOL=OFF
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_ROOT:STRING=/data/OTB-Data
BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
OTB_BUILD_DEFAULT_MODULES:BOOL=OFF
Module_${dashboard_module}:BOOL=ON
")

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)



