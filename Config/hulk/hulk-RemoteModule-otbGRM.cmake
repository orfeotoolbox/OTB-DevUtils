#Contact: Pierre Lassalle <lassallepierre34@gmail.com>

# otb_fetch_module(otbGRM
# 	"GRM OTB Application for region merging segmentation of very high resolution satellite scenes."
# 	GIT_REPOSITORY http://tully.ups-tlse.fr/lassallep/grm/
# 	GIT_TAG master
# 	)

set(dashboard_module "otbGRM")
set(dashboard_module_url "http://tully.ups-tlse.fr/lassallep/grm.git")

set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}-${dashboard_module}")
set(dashboard_no_install 1)
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)

set(dashboard_model "Nightly")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/build-${dashboard_module}")

set(dashboard_cache "
BUILD_EXAMPLES:BOOL=OFF
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ITK-4.7.1/lib/cmake/ITK-4.7
BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
OTB_BUILD_DEFAULT_MODULES:BOOL=OFF
Module_${dashboard_module}:BOOL=ON
")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
