# File: mxe_common.cmake
# Author: Rashad Kanavath <rashad.kanavath@c-s.fr>
# Description: OTB Common Dashboard Script for MinGW cross compilation
# Copyright: CNES 2014 -2016
# To test this script use test_mxe_common.cmake


# Select the model (nightly, experimental, continuous, crossCompile).
if(NOT DEFINED dashboard_model)
  set(dashboard_model nightly)
else()
  string(TOLOWER ${dashboard_model} dashboard_model)
endif()

string(TOUPPER ${dashboard_model} DASHBOARD_MODEL)

if(DEFINED dashboard_module)
  set(PROJECT otb)
endif()

if(NOT DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION Release)
endif()

string(TOLOWER ${PROJECT} project)

if(NOT DEFINED CTEST_DASHBOARD_ROOT)
  set(CTEST_DASHBOARD_ROOT "/data/dashboard")
endif()

if(NOT DEFINED dashboard_git_branch)
  if(DEFINED ENV{dashboard_${project}_git_branch})
    set(dashboard_git_branch $ENV{dashboard_${project}_git_branch})
  else()
    set(dashboard_git_branch nightly)
  endif()
endif()

if(NOT DEFINED CTEST_BUILD_NAME)
  if("${dashboard_git_branch}" STREQUAL "nightly")
    set(CTEST_BUILD_NAME "Windows-MinGW-w64-${MXE_TARGET_ARCH}-${CTEST_BUILD_CONFIGURATION}")
  else()
    set(CTEST_BUILD_NAME "Windows-MinGW-w64-${MXE_TARGET_ARCH}-${CTEST_BUILD_CONFIGURATION}-${dashboard_git_branch}")
  endif()
endif()


set(build_directory_name MinGW)
if(DEFINED dashboard_module)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-${dashboard_module}")
  set(build_directory_name ${dashboard_module})
endif()

if(NOT DEFINED MXE_ROOT)
  set(MXE_ROOT "/data/tools/mxe")
endif()

if(DEFINED ENV{CTEST_SITE})
  set(CTEST_SITE "$ENV{CTEST_SITE}")
endif()

if(NOT DEFINED CTEST_SITE)
  set(CTEST_SITE "bumblebee.c-s.fr")
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

if(NOT DEFINED CTEST_CROSS_COMMAND)
  find_program(CTEST_GIT_COMMAND NAMES git)
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
  set(dashboard_cxx_flags -Wall)
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

if(NOT DEFINED dashboard_default_target)
  if(DEFINED dashboard_module)
    set(dashboard_default_target all)
  else()
    set(dashboard_default_target install)
  endif()
endif()

if(NOT DEFINED dashboard_make_package)
  if("${project}" STREQUAL "otb" OR "${project}" STREQUAL "monteverdi" )
    set(dashboard_make_package TRUE)
  else()
    set(dashboard_make_package FALSE)
  endif()
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

CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/${dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}

CMAKE_CROSSCOMPILING:BOOL=${CMAKE_CROSSCOMPILING}

CMAKE_CROSSCOMPILING_EMULATOR:FILEPATH=${CMAKE_CROSSCOMPILING_EMULATOR}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_TOOLCHAIN_FILE:FILEPATH=${MXE_TARGET_ROOT}/share/cmake/mxe-conf.cmake

CMAKE_USE_PTHREADS:BOOL=OFF

CMAKE_USE_WIN32_THREADS:BOOL=ON



"
  )

# Get latest version from <install-prefix>/lib/cmake/OTB-version
set(otb_version 1.0)
set(otb_cmake_root_dir ${CTEST_DASHBOARD_ROOT}/${dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}/lib/cmake)
file(GLOB otb_cmake_version_dirs RELATIVE ${otb_cmake_root_dir} ${otb_cmake_root_dir}/*)
foreach(otb_cmake_version_dir ${otb_cmake_version_dirs})
  if(IS_DIRECTORY ${otb_cmake_root_dir}/${otb_cmake_version_dir})
    string(SUBSTRING ${otb_cmake_version_dir} 4 -1 cur_version_dir)
    if(otb_version LESS ${cur_version_dir})
      set(otb_version ${cur_version_dir})
    endif()
  endif()
endforeach()

if(NOT ${project} STREQUAL "otb")
  set(mxe_common_cache
    " ${mxe_common_cache}
OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/${dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}/lib/cmake/OTB-${otb_version}

")
endif( )

#no matter what. I am not making a package for remote module only build
if(DEFINED dashboard_module)
  set(dashboard_make_package FALSE)
endif()

#tiny shiny MXE_TARGET_DIR cmake var is needed if packages are created
if(dashboard_make_package)
  set(mxe_common_cache
    " ${mxe_common_cache}

MXE_TARGET_DIR:PATH=${MXE_ROOT}/usr/${MXE_TARGET_ARCH}-w64-mingw32.shared

")

endif()

if(DEFINED dashboard_module)

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

# Select Git source to use.
if(NOT DEFINED dashboard_git_url)
  set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/${PROJECT}.git")
endif()

if(NOT DEFINED dashboard_git_crlf)
  if(UNIX)
    set(dashboard_git_crlf false)
  else()
    set(dashboard_git_crlf true)
  endif()
endif()

if(DEFINED dashboard_git_features_list)
  message("Checking feature branches file : ${dashboard_git_features_list}")
  file(STRINGS ${dashboard_git_features_list} additional_branches
    REGEX "^ *([a-zA-Z0-9]|-|_)+ *\$")
  list(LENGTH additional_branches number_additional_branches)
  if(number_additional_branches GREATER 0)
    message("Testing feature branches : ${additional_branches}")
  endif()
endif()

# Select a source directory name.
if(NOT DEFINED CTEST_SOURCE_DIRECTORY)
  if(DEFINED dashboard_source_name)
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_source_name})
  else()
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_model}/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src)
  endif()
endif()

# Select a build directory name.
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  if(DEFINED dashboard_binary_name)
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  else()
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_model}/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-${build_directory_name}-${MXE_TARGET_ARCH})
  endif()
endif()

# Select source directory to update
if(NOT DEFINED dashboard_update_dir)
  set(dashboard_update_dir ${CTEST_SOURCE_DIRECTORY})
endif()

#-----------------------------------------------------------------------------

# # Send the main script as a note.
# list(APPEND CTEST_NOTES_FILES
#   "${CTEST_BINARY_DIRECTORY}/summary.txt"
#   "${CMAKE_CURRENT_LIST_FILE}"
#   "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
#   )

# macro(print_summary)
#   # Check for required variables.
#   foreach(req
#       CTEST_CMAKE_COMMAND
#       CMAKE_COMMAND
#       CMAKE_CROSSCOMPILING_EMULATOR
#       CTEST_CMAKE_GENERATOR
#       CTEST_SITE
#       CTEST_BUILD_NAME
#       CTEST_SCRIPT_DIRECTORY
#       CTEST_SOURCE_DIRECTORY
#       CTEST_BINARY_DIRECTORY
#       CTEST_CMAKE_GENERATOR
#       CTEST_BUILD_CONFIGURATION
#       CTEST_GIT_COMMAND
#       PROJECT
#       MXE_ROOT
#       MXE_TARGET_ARCH
#       dashboard_git_branch
#       )
#     if(NOT DEFINED ${req})
#       message(FATAL_ERROR "The containing script must set ${req}")
#     endif()
#     set(vars "${vars}  ${req}=[${${req}}]\n")
#   endforeach(req)

#   # Print summary information.
#   foreach(v
#       CTEST_USE_LAUNCHERS
#       CMAKE_CROSSCOMPILING
#       CTEST_CHECKOUT_COMMAND
#       CTEST_DASHBOARD_TRACK
#       CTEST_GIT_UPDATE_OPTIONS
#       dashboard_no_submit
#       dashboard_no_configure
#       dashboard_no_build
#       dashboard_no_test
#       dashboard_cc_flags
#       dashboard_cxx_flags
#       dashboard_enable_large_input
#       dashboard_no_examples
#       dashboard_no_clean
#       dashboard_default_target
#       dashboard_package_target
#       dashboard_model
#       dashboard_no_update
#       DASHBOARD_MODEL
#       PROJECT
#       CTEST_TEST_TIMEOUT
#       CMAKE_MAKE_PROGRAM
#       )
#     set(vars "${vars}  ${v}=[${${v}}]\n")
#   endforeach(v)

#   message("Dashboard script configuration:\n${vars}\n")

#   file(WRITE ${CTEST_BINARY_DIRECTORY}/summary.txt
#     "Dashboard script configuration:\n${vars}\n")

#   message(STATUS "summary written to ${CTEST_BINARY_DIRECTORY}/summary.txt")

# endmacro(print_summary)

# if(NOT test_this_script)
#   # Start with a fresh build tree.
#   file(MAKE_DIRECTORY "${CTEST_BINARY_DIRECTORY}")
#   if(NOT "${CTEST_SOURCE_DIRECTORY}" STREQUAL "${CTEST_BINARY_DIRECTORY}"
#       AND NOT dashboard_no_clean)

#     if(EXISTS "${CTEST_BINARY_DIRECTORY}")
#       message("Clearing build tree...")
#       ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
#     endif()
#   endif()
# endif()

# set(dashboard_continuous 0)
# if("${dashboard_model}" STREQUAL "continuous")
#   set(dashboard_continuous 1)
# endif()
# if(NOT DEFINED dashboard_loop)
#   if(dashboard_continuous)
#     set(dashboard_loop 43200)
#   else()
#     set(dashboard_loop 0)
#   endif()
# endif()

# # CTest 2.6 crashes with message() after ctest_test.
# macro(safe_message)
#   if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.4 OR NOT safe_message_skip)
#     message(STATUS ${ARGN})
#   endif()
# endmacro()

# # macro for the full dashboard sequence
# macro(run_dashboard)
#   # Start a new submission.
#   if(COMMAND dashboard_hook_start)
#     dashboard_hook_start()
#   endif()

#   ctest_start(${DASHBOARD_MODEL} TRACK ${CTEST_DASHBOARD_TRACK})

#   # Always build if the tree is fresh.
#   set(dashboard_fresh 0)
#   if(NOT EXISTS "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt")
#     set(dashboard_fresh 1)
#     safe_message("Starting fresh build...")
#     write_cache()
#   endif()

#   print_summary()

#   # Look for updates.
#   if(NOT dashboard_no_update)
#     ctest_update(SOURCE ${dashboard_update_dir} RETURN_VALUE count)
#     set(CTEST_CHECKOUT_COMMAND) # checkout on first iteration only
#     safe_message("Found ${count} changed files")

#     # # add specific modules (works for OTB only)
#     # if(DEFINED dashboard_module AND DEFINED dashboard_module_url)
#     #   if(NOT EXISTS ${dashboard_update_dir}/Modules/Remote/${dashboard_module})
#     #     execute_process(COMMAND "${CTEST_GIT_COMMAND}"
#     #       "clone" "${dashboard_module_url}"  "${dashboard_update_dir}/Modules/Remote/${dashboard_module}" RESULT_VARIABLE rv)
#     #     if(NOT rv EQUAL 0)
#     #       message(FATAL_ERROR "Cannot checkout remote module: ${rv}")
#     #     endif()
#     #   else()
#     #     execute_process(COMMAND "${CTEST_GIT_COMMAND}"
#     #       "pull" WORKING_DIRECTORY "${dashboard_update_dir}/Modules/Remote/${dashboard_module}")
#     #   endif()
#     # endif()
#   endif()

#   if(dashboard_fresh OR NOT dashboard_continuous OR count GREATER 0)

#     if(NOT dashboard_no_configure)
#       ctest_configure()
#       ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
#     endif()

#     if(NOT dashboard_no_build)
#       if(COMMAND dashboard_hook_build)
#         dashboard_hook_build()
#       endif()

#       ctest_build(BUILD ${CTEST_BINARY_DIRECTORY}
#         TARGET ${dashboard_default_target}
#         RETURN_VALUE _default_build_rv)
#     endif()

#     if(dashboard_make_package)
#       if(COMMAND dashboard_hook_package)
#         dashboard_hook_package()
#       endif()
#       ctest_build(BUILD ${CTEST_BINARY_DIRECTORY}
#         TARGET ${dashboard_package_target}
#         RETURN_VALUE _package_build_rv)
#     endif()

#     if(dashboard_module)
#       # message(STATUS "Packaging stuff for RemoteModule: ${dasboard_module}")
#       # file(GLOB apps ${CTEST_BINARY_DIRECTORY}/lib/otb/applications/*.dll)
#       # foreach(app ${apps})
#       #   message(STATUS "file copy: ${app} ->  ${CTEST_DASHBOARD_ROOT}/${dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}/lib/otb/applications/")
#       #   execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E copy ${app} ${CTEST_DASHBOARD_ROOT}/${dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}/lib/otb/applications/)
#       # endforeach()
#       # file(GLOB scripts ${CTEST_BINARY_DIRECTORY}/bin/*.bat)
#       # foreach(script ${scripts})
#       #   message(STATUS "file copy: ${script} ->  ${CTEST_DASHBOARD_ROOT}/${dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}/bin/")
#       #   execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E copy ${script} ${CTEST_DASHBOARD_ROOT}/${dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}/bin/)
#       # endforeach()
#     endif()

#     if(NOT dashboard_no_test)
#       if(COMMAND dashboard_hook_test)
#         dashboard_hook_test()
#       endif()
#       ctest_test(${CTEST_TEST_ARGS})
#     endif()

#     set(safe_message_skip 1) # Block furhter messages

#     if(dashboard_do_coverage)
#       if(COMMAND dashboard_hook_coverage)
#         dashboard_hook_coverage()
#       endif()
#       ctest_coverage()
#     endif()
#     if(dashboard_do_memcheck)
#       if(COMMAND dashboard_hook_memcheck)
#         dashboard_hook_memcheck()
#       endif()
#       ctest_memcheck()
#     endif()
#     if(COMMAND dashboard_hook_submit)
#       dashboard_hook_submit()
#     endif()
#     if(NOT dashboard_no_submit)
#       ctest_submit()
#     endif()
#     if(COMMAND dashboard_hook_end)
#       dashboard_hook_end()
#     endif()
#   endif()
# endmacro()

# if(COMMAND dashboard_hook_init)
#   dashboard_hook_init()
# endif()

# if(NOT test_this_script)

#   run_dashboard()

#   ctest_sleep(5)

#   if(DEFINED dashboard_module AND DEFINED dashboard_module_url)
#     file(REMOVE_RECURSE "${dashboard_update_dir}/Modules/Remote/${dashboard_module}")
#   endif()

# else()
#   print_summary()
#   message(FATAL_ERROR "This is a test run. cannot continue anymore")
# endif()
