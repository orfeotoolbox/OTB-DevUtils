#Contact: Pierre Lassalle <lassallepierre34@gmail.com>

# otb_fetch_module(otbGRM
# 	"GRM OTB Application for region merging segmentation of very high resolution satellite scenes."
# 	GIT_REPOSITORY http://tully.ups-tlse.fr/lassallep/grm/
# 	GIT_TAG master
# 	)

set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(dashboard_module "otbGRM")
set(dashboard_module_url "http://tully.ups-tlse.fr/lassallep/grm.git")
set(MXE_TARGET_ARCH "i686")

include(${CTEST_SCRIPT_DIRECTORY}/bumblebee_common.cmake)

include(${CTEST_SCRIPT_DIRECTORY}/../mxe_common.cmake)
set(dashboard_cache "${mxe_common_cache}")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
