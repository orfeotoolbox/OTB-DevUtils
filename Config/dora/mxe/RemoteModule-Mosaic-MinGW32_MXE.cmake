#Contact: cresson.r <cresson.r@gmail.com>

# otb_fetch_module(Mosaic
# 	"Mosaic Module"
# 	GIT_REPOSITORY https://github.com/remicres/otb-mosaic
# 	GIT_TAG master
# 	)

set(dashboard_module "Mosaic")
set(dashboard_module_url "https://github.com/remicres/otb-mosaic")
set(MXE_TARGET_ARCH "i686")

set(dashboard_cache "${mxe_common_cache}")

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)

include(${CTEST_SCRIPT_DIRECTORY}/../../otb_common.cmake)
