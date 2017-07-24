# set(dashboard_no_clean 1)
# set(dashboard_no_update 1) 
# set(dashboard_no_configure 1)
# set(dashboard_no_submit 1)
# set(dashboard_model Experimental)
# set(dashboard_build_target OTBWavelet-all)
# set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
# set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015") 
# set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015 Win64")

set(otb_data_use_largeinput ON)

set(dashboard_cache 
"
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON
OTB_USE_QT4:BOOL=ON
OTB_USE_QWT:BOOL=ON
OTB_USE_6S:BOOL=ON
OTB_USE_CURL:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
OTB_USE_SHARK:BOOL=ON
"
)

set(dashboard_cache_for_rfc-98-qwt6 "CMAKE_PREFIX_PATH=C:/Qwt-6.1.3")

include(windows_common.cmake)


############################# NOTES #############################
# set( dashboard_no_clean 1 )
## Do not clean build and install directory. Default is to clean

# set( dashboard_no_update 1 )
## Do not reset otb and otb-data git. This will keep local changes. Default is to delete local changes

# set( dashboard_no_configure 1 )
## Do not run ctest_configure step. Default is to run ctest_configure

# set( dashboard_no_submit 1 )
## Do not submit build to dashboard. Default is to submit build

# set(dashboard_model Experimental)
## Force dashboard_model to Experimental. Default value depends on selected branch

# set(dashboard_build_target OTBWavelet-all)
## Build target OTBWavelet-all and run only test with label OTBWavelet

# set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
## Change build type to RelWithDebInfo. Default is Release

# set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015") 
## Use Visual Studio 14 2015 generator x86 (default is ninja)

# set(CTEST_CMAKE_GENERATOR "Visual Studio 14 2015 Win64")
## Use Visual Studio 14 2015 generator x64 (default is ninja)

