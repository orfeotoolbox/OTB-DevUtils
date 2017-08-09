# set(dashboard_no_clean 1)
# set(dashboard_no_update 1) 
# set(dashboard_no_configure 1)
# set(dashboard_no_build 1)
# set(dashboard_no_test 1)
# set(dashboard_no_submit 1)
# set(dashboard_model Experimental)
# set(dashboard_build_target OTBWavelet-all)
# set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
# set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015") 
# set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015 Win64")

# This variable let you get a freaky minimal build of OTB
# on windows by deactivating all thirdparty libraries 
# and LARGEINPUT tests
set(default_on_off ON)

# SEE 'DOCUMENTATION' SECTION BELOW..

set(otb_data_use_largeinput ${default_on_off})
set(dashboard_cache 
"
OTB_USE_OPENGL:BOOL=${default_on_off}
OTB_USE_GLEW:BOOL=${default_on_off}
OTB_USE_GLFW:BOOL=${default_on_off}
OTB_USE_GLUT:BOOL=${default_on_off}
OTB_USE_QT4:BOOL=${default_on_off}
OTB_USE_QWT:BOOL=${default_on_off}
OTB_USE_6S:BOOL=${default_on_off}
OTB_USE_CURL:BOOL=${default_on_off}
OTB_USE_OPENCV:BOOL=${default_on_off}
OTB_USE_LIBSVM:BOOL=${default_on_off}
OTB_USE_MUPARSER:BOOL=${default_on_off}
OTB_USE_MUPARSERX:BOOL=${default_on_off}
OTB_WRAP_PYTHON:BOOL=${default_on_off}
OTB_USE_SHARK:BOOL=${default_on_off}
BUILD_TESTING:BOOL=ON
")

if("$ENV{dashboard_otb_branch}" STREQUAL "rfc-98-qwt6")
  set(XDK_INSTALL_DIR "C:/dashboard/otb/xdk/otb61_$ENV{COMPILER_ARCH}")
endif()

include(windows_common.cmake)


######################## DOCUMENTATION ###########################

# SuperBuild: DONT EVEN THINK OF ACTIVATING
# ANY SYSTEM LIBRARY AND THEN MAKING OTB PACKAGE!
# THIS WILL REQUIRE SPECIFIC PATCHING IN GENERATED CMAKE FILES
# SEE otb.git/Packaging/install_cmake_files.cmake

## Do not clean build and install directory. Default is to clean
# set( dashboard_no_clean 1 )

## Do not reset otb and otb-data git. This will keep local changes.
# set( dashboard_no_update 1 )

## Do not run ctest_configure step. Default is to run ctest_configure
# set( dashboard_no_configure 1 )

## Do not run ctest_build step. Default is to run ctest_build
# set( dashboard_no_build 1 )

## setting this variable will pass BUILD_TESTING:BOOL=OFF
# set( dashboard_no_test 1 )

## Do not submit build to dashboard. Default is to submit build
# set( dashboard_no_submit 1 )

## Force dashboard_model to Experimental.
# set(dashboard_model Experimental)

## Build target OTBWavelet-all and run only test with label OTBWavelet
## packaging build will force dashboard_build_target to 'install'
# set(dashboard_build_target OTBWavelet-all)

## Change build type to RelWithDebInfo. Default is Release
# set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)

## Use Visual Studio 14 2015 x86/x64 generator (default is ninja)
# set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015") 
# set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015 Win64")

