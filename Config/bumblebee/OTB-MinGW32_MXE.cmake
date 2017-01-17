# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(MXE_TARGET_ARCH "i686")
set(PROJECT "otb")
include(${CTEST_SCRIPT_DIRECTORY}/bumblebee_common.cmake)

set(CTEST_TEST_ARGS INCLUDE Tu)

set(dashboard_git_branch release-5.10)

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

# Attach mxe build log to dashboard.
# This log file was created in ~/scripts/cron-nightly.sh
set(CTEST_NOTES_FILES "/home/otbval/logs/mxe_build_log.txt")

#uncomment to update list of c flags
#set(dashboard_cc_flags)

#uncomment to update list of cxx flags
#set(dashboard_cxx_flags)

#change git branch to use for build.
#if 'dashboard_git_<project>_branch' evironment variable is defined.
#It is preferred over whatever value set below
#set(dashboard_git_branch "release-5.2")

#uncomment to enable large input
#set(dashboard_enable_large_input TRUE)

#uncomment to skip clearing source directory
#set(dashboard_no_update TRUE)

#uncomment to skip ctest_configure()
#set(dashboard_no_configure TRUE)

#uncomment to skip ctest_build()
#set(dashboard_no_build TRUE)

#uncomment to enable BUILD_EXAMPLES
#set(dashboard_no_examples FALSE)

#uncomment to disable BUILD_TESTING
#set(dashboard_no_test TRUE)

#uncomment to skip submission to dashboard
#set(dashboard_no_submit TRUE)

#uncomment to skip removing build directory
#set(dashboard_no_clean TRUE)

#change the target default build target. eg: OTBCommon
#set(dashboard_default_target install)

#change the target name to generate packages; eg: OtherPackageTarget
#set(dashboard_package_target packages)

include(${CTEST_SCRIPT_DIRECTORY}/../mxe_common.cmake)


include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
