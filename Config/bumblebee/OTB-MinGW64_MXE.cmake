# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(CTEST_SITE "bumblebee.c-s.fr")
set(MXE_TARGET_ARCH "x86_64")
set(PROJECT "otb")

#set(dashboard_git_branch release-5.6)

set(CTEST_TEST_ARGS INCLUDE Tu)

macro(dashboard_hook_init)
set(dashboard_cache "

${mxe_common_cache}

OTB_USE_CURL:BOOL=ON
OTB_USE_QT4:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_SIFTFAST:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_LIBKML:BOOL=OFF
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_OPENJPEG:BOOL=OFF
OTB_USE_MAPNIK:BOOL=OFF
OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF
# Ice module
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON

")
endmacro()

set(dashboard_make_package FALSE)

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)

include(${CTEST_SCRIPT_DIRECTORY}/../../otb_common.cmake)
