# File: test_mxe_common.cmake
# Author: Rashad Kanavath <rashad.kanavath@c-s.fr>
# Description: OTB Common Dashboard Script for MinGW cross compilation
# Copyright: CNES 2014 -2016
# To test script for mxe_common.cmake
# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)

set(CTEST_SITE "noname.sites.fr")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "otb")

set(test_this_script TRUE)
set(CTEST_BINARY_DIRECTORY "/tmp/")

macro(dashboard_hook_init)
set(dashboard_cache "

dummy_cache

")
endmacro()

# Attach mxe build log to dashboard.
# This log file was created in ~/scripts/cron-nightly.sh
set(CTEST_NOTES_FILES "/home/otbval/logs/mxe_build_log_on_dora.txt")

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

#uncomment to skip ctest_configure()
set(dashboard_no_configure TRUE)

#uncomment to skip ctest_build()
set(dashboard_no_build TRUE)

#uncomment to enable BUILD_EXAMPLES
#set(dashboard_no_examples FALSE)

#uncomment to disable BUILD_TESTING
set(dashboard_no_test TRUE)

#uncomment to skip submission to dashboard
set(dashboard_no_submit TRUE)

#uncomment to skip removing build directory
set(dashboard_no_clean TRUE)

set(dashboard_no_update TRUE)

#change the target default build target. eg: OTBCommon
#set(dashboard_default_target install)

#change the target name to generate packages; eg: OtherPackageTarget
#set(dashboard_package_target packages)



include(${CTEST_SCRIPT_DIRECTORY}/mxe_common.cmake)



