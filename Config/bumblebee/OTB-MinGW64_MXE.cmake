# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(MXE_TARGET_ARCH "x86_64")
set(PROJECT "otb")
include(${CTEST_SCRIPT_DIRECTORY}/bumblebee_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
set(CTEST_TEST_ARGS INCLUDE Tu)

macro(dashboard_hook_init)
set(dashboard_cache "
${mxe_common_cache}
OTB_USE_CURL:BOOL=ON
OTB_USE_QT4:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_SIFTFAST:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON

OTB_USE_MUPARSERX:BOOL=OFF
OTB_USE_SHARK:BOOL=OFF

OTB_USE_LIBKML:BOOL=OFF
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
# Ice module
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON
# Monteverdi
OTB_USE_QWT:BOOL=ON

OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF

GENERATE_PACKAGE=ON
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../mxe_common.cmake)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
