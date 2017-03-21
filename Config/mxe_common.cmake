# File: mxe_common.cmake
# Author: Rashad Kanavath <rashad.kanavath@c-s.fr>
# Description: OTB Common Dashboard Script for MinGW cross compilation
# Copyright: CNES 2014 -2016
# To test this script use test_mxe_common.cmake

string(TOLOWER ${dashboard_model} dashboard_model_l)

if(NOT DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION Release)
endif()

string(TOLOWER ${PROJECT} project)

if(NOT DEFINED dashboard_git_branch)
  if(DEFINED ENV{dashboard_${project}_git_branch})
    set(dashboard_git_branch $ENV{dashboard_${project}_git_branch})
  else()
    set(dashboard_git_branch nightly)
  endif()
endif()

if(NOT DEFINED CTEST_BUILD_NAME)
  if("${dashboard_git_branch}" MATCHES "^(nightly|release.([0-9]+)\\.([0-9]+))$")
    set(CTEST_BUILD_NAME "Win-MinGW-w64-${MXE_TARGET_ARCH}-${CTEST_BUILD_CONFIGURATION}")
  else()
    set(CTEST_BUILD_NAME "Win-MinGW-w64-${MXE_TARGET_ARCH}-${CTEST_BUILD_CONFIGURATION}-${dashboard_git_branch}")
  endif()
endif()

set(build_directory_name MinGW)
if(dashboard_module)
  set(CTEST_BUILD_NAME "${dashboard_module}-${CTEST_BUILD_NAME}")
  set(build_directory_name ${dashboard_module})
elseif(dashboard_remote_modules)
  set(build_directory_name remotes)
endif()

if(NOT DEFINED MXE_ROOT)
  set(MXE_ROOT "/data/tools/mxe")
endif()

if(MXE_TARGET_ARCH MATCHES "i686")
  set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/i686-w64-mingw32.shared")
endif()
if(MXE_TARGET_ARCH MATCHES "x86_64")
  set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/x86_64-w64-mingw32.shared")
endif()

if(DEFINED CMAKE_COMMAND)
  set(CTEST_CMAKE_COMMAND "${CMAKE_COMMAND}")
endif()

if(NOT DEFINED CMAKE_MAKE_PROGRAM)
  set(CMAKE_MAKE_PROGRAM "/usr/bin/make")
endif()

if(NOT DEFINED CMAKE_CROSSCOMPILING_EMULATOR)
  find_program(CMAKE_CROSSCOMPILING_EMULATOR NAMES wine)
endif()

set(CMAKE_CROSSCOMPILING TRUE)

if(NOT DEFINED test_this_script)
  set(test_this_script FALSE)
endif()

if(NOT MSVC)
  set(dashboard_cc_flags -Wall)
  set(dashboard_cxx_flags -Wno-cpp)
endif()

if(dashboard_cc_flags)
  set(dashboard_cc_flags "${dashboard_cc_flags_DEFAULT} ${dashboard_cc_flags}")
endif()
if(dashboard_cxx_flags)
  set(dashboard_cxx_flags "${dashboard_cxx_flags_DEFAULT} ${dashboard_cxx_flags}")
endif()

if(NOT DEFINED dashboard_otbdata_root)
  set(dashboard_otbdata_root "/data/otb-data")
endif()

if(NOT DEFINED dashboard_large_input_root)
  set(dashboard_large_input_root "/media/otbnas/otb/OTB-LargeInput")
endif()

if(NOT DEFINED dashboard_package_target)
  set(dashboard_package_target PACKAGE-OTB)
endif()

if(NOT DEFINED dashboard_make_package)
  if("${project}" STREQUAL "otb")
    set(dashboard_make_package TRUE)
  else()
    set(dashboard_make_package FALSE)
  endif()
endif()

#no matter what. I am not making a package for remote module only build
if(dashboard_module OR dashboard_remote_modules)
  set(dashboard_make_package FALSE)
endif()

#################################### BEGIN #######################################
############### set 'mxe_common_cache' based given configurations ################
##################################################################################

set(mxe_common_cache
  "
GDAL_CONFIG:FILEPATH='${MXE_TARGET_ROOT}/bin/gdal-config'

OSSIM_LIBRARY:FILEPATH='${MXE_TARGET_ROOT}/lib/libossim.dll.a;${MXE_TARGET_ROOT}/lib/libOpenThreads.dll.a'

CMAKE_C_FLAGS:STRING=${dashboard_cc_flags}

CMAKE_CXX_FLAGS:STRING=${dashboard_cxx_flags}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/${dashboard_model_l}/install-MinGW-${MXE_TARGET_ARCH}

CMAKE_CROSSCOMPILING:BOOL=${CMAKE_CROSSCOMPILING}

CMAKE_CROSSCOMPILING_EMULATOR:FILEPATH=${CMAKE_CROSSCOMPILING_EMULATOR}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_TOOLCHAIN_FILE:FILEPATH=${MXE_TARGET_ROOT}/share/cmake/mxe-conf.cmake

CMAKE_USE_PTHREADS:BOOL=OFF

CMAKE_USE_WIN32_THREADS:BOOL=ON

"
  )

#tiny shiny MXE_TARGET_DIR cmake var is needed if packages are created
if(dashboard_make_package)
  set(mxe_common_cache
    " ${mxe_common_cache}

MXE_TARGET_DIR:PATH=${MXE_ROOT}/usr/${MXE_TARGET_ARCH}-w64-mingw32.shared

")

endif()

if(dashboard_remote_modules)

  set(mxe_common_cache
    " ${mxe_common_cache}

OTB_BUILD_DEFAULT_MODULES:BOOL=OFF

")
  set(dashboard_no_examples ON)
endif()

if(dashboard_module)

  set(mxe_common_cache
    " ${mxe_common_cache}

OTB_BUILD_DEFAULT_MODULES:BOOL=OFF

Module_${dashboard_module}:BOOL=ON

")
  set(dashboard_no_examples ON)
endif()

if(dashboard_no_examples)
  set(mxe_common_cache "

${mxe_common_cache}

BUILD_EXAMPLES:BOOL=OFF

")
else()
  set(mxe_common_cache "

${mxe_common_cache}

BUILD_EXAMPLES:BOOL=ON

")
endif()

if(dashboard_no_test)
  set(mxe_common_cache "

${mxe_common_cache}

BUILD_TESTING:BOOL=OFF

")
else()
  set(mxe_common_cache "

${mxe_common_cache}

OTB_DATA_ROOT:PATH=${dashboard_otbdata_root}

BUILD_TESTING:BOOL=ON

")
endif()

if(dashboard_enable_large_input)
  set(mxe_common_cache "

${mxe_common_cache}

OTB_DATA_ROOT:PATH=${dashboard_otbdata_root}

OTB_DATA_USE_LARGEINPUT:BOOL=ON

OTB_DATA_LARGEINPUT_ROOT:PATH=${dashboard_large_input_root}")

else()
  set(mxe_common_cache " ${mxe_common_cache}

OTB_DATA_USE_LARGEINPUT:BOOL=OFF

")

endif()

##################################################################################
############### set 'mxe_common_cache' based given configurations ################
##################################### END ########################################

# Select a source directory name.
if(NOT DEFINED CTEST_SOURCE_DIRECTORY)
  if(DEFINED dashboard_source_name)
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_source_name})
  else()
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_model_l}/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src)
  endif()
endif()

# Select a build directory name.
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  if(DEFINED dashboard_binary_name)
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  else()
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_model_l}/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-${build_directory_name}-${MXE_TARGET_ARCH})
  endif()
endif()

# Select source directory to update
if(NOT DEFINED dashboard_update_dir)
  set(dashboard_update_dir ${CTEST_SOURCE_DIRECTORY})
endif()


#---------------------- Hook to build package --------------------------------
macro(dashboard_hook_submit)
  if(dashboard_make_package)
    ctest_build(BUILD ${CTEST_BINARY_DIRECTORY}
                TARGET ${dashboard_package_target}
                RETURN_VALUE _package_build_rv)
  endif()
endmacro()

#-----------------------------------------------------------------------------
