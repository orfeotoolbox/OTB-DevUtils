# OTB Common Dashboard Script
#
# This script contains basic dashboard driver code common to all
# clients.
#
# Put this script in a directory such as "~/Dashboards/Scripts" or
# "c:/Dashboards/Scripts".  Create a file next to this script, say
# 'my_dashboard.cmake', with code of the following form:
#
#   # Client maintainer: me@mydomain.net
#   set(CTEST_SITE "machine.site")
#   set(CTEST_BUILD_NAME "Platform-Compiler")
#   set(CTEST_BUILD_CONFIGURATION Debug)
#   set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
#   include(${CTEST_SCRIPT_DIRECTORY}/itk_common.cmake)
#
# Then run a scheduled task (cron job) with a command line such as
#
#   ctest -S ~/Dashboards/Scripts/my_dashboard.cmake -V
#
# By default the source and build trees will be placed in the path
# "../My Tests/" relative to your script location.
#
# The following variables may be set before including this script
# to configure it:
#
#   dashboard_model           = Nightly | Experimental | Continuous
#   dashboard_loop            = Repeat until N seconds have elapsed
#   dashboard_root_name       = Change name of "My Tests" directory
#   dashboard_source_name     = Name of source directory (ITK)
#   dashboard_binary_name     = Name of binary directory (ITK-build)
#   dashboard_cache           = Initial CMakeCache.txt file content
#   dashboard_do_coverage     = True to enable coverage (ex: gcov)
#   dashboard_do_memcheck     = True to enable memcheck (ex: valgrind)
#   dashboard_no_clean        = True to skip build tree wipeout
#   CTEST_UPDATE_COMMAND      = path to svn command-line client
#   CTEST_BUILD_FLAGS         = build tool arguments (ex: -j2)
#   CTEST_DASHBOARD_ROOT      = Where to put source and build trees
#   CTEST_TEST_CTEST          = Whether to run long CTestTest* tests
#   CTEST_TEST_TIMEOUT        = Per-test timeout length
#   CTEST_TEST_ARGS           = ctest_test args (ex: PARALLEL_LEVEL 4)
#   CMAKE_MAKE_PROGRAM        = Path to "make" tool to use
#
# Options to configure builds from experimental git repository:
#   dashboard_hg_url      = Custom hg clone url
#   dashboard_hg_branch   = Custom remote branch to track
#
# The following macros will be invoked before the corresponding
# step if they are defined:
#
#   dashboard_hook_init       = End of initialization, before loop
#   dashboard_hook_start      = Start of loop body, before ctest_start
#   dashboard_hook_build      = Before ctest_build
#   dashboard_hook_test       = Before ctest_test
#   dashboard_hook_coverage   = Before ctest_coverage
#   dashboard_hook_memcheck   = Before ctest_memcheck
#   dashboard_hook_submit     = Before ctest_submit
#   dashboard_hook_end        = End of loop body, after ctest_submit
#
# For Makefile generators the script may be executed from an
# environment already configured to use the desired compilers.
# Alternatively the environment may be set at the top of the script:
#
#   set(ENV{CC}  /path/to/cc)   # C compiler
#   set(ENV{CXX} /path/to/cxx)  # C++ compiler
#   set(ENV{FC}  /path/to/fc)   # Fortran compiler (optional)
#   set(ENV{LD_LIBRARY_PATH} /path/to/vendor/lib) # (if necessary)
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

set(dashboard_user_home "$ENV{HOME}")

# Select the model (Nightly, Experimental, Continuous, CrossCompile).
if(NOT DEFINED dashboard_model)
  set(dashboard_model Nightly)
endif()
if(NOT "${dashboard_model}" MATCHES "^(Nightly|Experimental|Continuous|CrossCompile)$")
  message(FATAL_ERROR "dashboard_model must be Nightly, Experimental, or Continuous")
endif()

if(EXISTS "$ENV{CTEST33}")
  set(CMAKE_COMMAND "$ENV{CTEST33}")
endif()

# Default to a Debug build.
if(NOT DEFINED CTEST_CONFIGURATION_TYPE AND DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_CONFIGURATION_TYPE ${CTEST_BUILD_CONFIGURATION})
endif()

if(NOT DEFINED CTEST_CONFIGURATION_TYPE)
  set(CTEST_CONFIGURATION_TYPE Debug)
endif()

if(NOT CTEST_CMAKE_GENERATOR)
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
endif()
if(NOT CTEST_BUILD_COMMAND)
  set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
endif()

if(NOT CTEST_TEST_ARGS)
  set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
endif()

set(CTEST_HG_UPDATE_OPTIONS "-C")



##cross compile parameters
#set(MXE_ROOT "/home/otbval/tools/mxe")
#set(MXE_TARGET_ARCH "i686")
#set(MXE_TARGET_ARCH "x86_64")
if(MXE_TARGET_ARCH MATCHES "i686")
  set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/i686-w64-mingw32.shared")
endif()
if(MXE_TARGET_ARCH MATCHES "x86_64")
  set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/x86_64-w64-mingw32.shared")
endif()


set(otb_cache_common
"
#why these values below? because we know..
OTB_MUPARSER_HAS_CXX_LOGICAL_OPERATORS_EXITCODE:INTERNAL=0

GDAL_HAS_J2K_ECW:INTERNAL=0

GDAL_HAS_J2K_JG2000:INTERNAL=0

GDAL_HAS_J2K_KAK:INTERNAL=0

GDAL_HAS_J2K_OPJG:INTERNAL=1

GDAL_HAS_JPEG:INTERNAL=1

GDAL_HAS_GTIF:INTERNAL=1

GDAL_HAS_HDF5:INTERNAL=1

GDAL_CAN_CREATE_GEOTIFF:INTERNAL=1

GDAL_CAN_CREATE_BIGTIFF:INTERNAL=1

GDAL_CAN_CREATE_JPEG:INTERNAL=1

GDAL_CAN_CREATE_JPEG2000:INTERNAL=1

GDAL_CONFIG:FILEPATH='${MXE_TARGET_ROOT}/bin/gdal-config'

OSSIM_LIBRARY:FILEPATH='${MXE_TARGET_ROOT}/lib/libossim.dll.a;${MXE_TARGET_ROOT}/lib/libOpenThreads.dll.a'

CHECK_HDF4OPEN_SYMBOL_EXITCODE:INTERNAL=0

HAS_SSE2_EXTENSIONS_EXITCODE:INTERNAL=0

HAS_SSE_EXTENSIONS_EXITCODE:INTERNAL=0

RUN_RESULT_VERSION:INTERNAL=1.11.2"

)

# Choose CTest reporting mode.
if(NOT "${CTEST_CMAKE_GENERATOR}" MATCHES "Make")
  # Launchers work only with Makefile generators.
  set(CTEST_USE_LAUNCHERS OFF)
elseif(NOT DEFINED CTEST_USE_LAUNCHERS)
  # The setting is ignored by CTest < 2.8 so we need no version test.
  set(CTEST_USE_LAUNCHERS ON)
endif()

# Configure testing.
if(NOT DEFINED CTEST_TEST_CTEST)
  set(CTEST_TEST_CTEST 1)
endif()
if(NOT CTEST_TEST_TIMEOUT)
  set(CTEST_TEST_TIMEOUT 1500)
endif()


# Select Git source to use.
if(NOT DEFINED dashboard_hg_url)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/${PROJECT}")
endif()
if(NOT DEFINED dashboard_hg_branch)
  set(dashboard_hg_branch default)
endif()

# Look for a GIT command-line client.
if(NOT DEFINED CTEST_HG_COMMAND)
  find_program(CTEST_HG_COMMAND NAMES hg)
endif()

if(NOT DEFINED CTEST_HG_COMMAND)
  message(FATAL_ERROR "No hg command Found.")
endif()


# Select a source directory name.
if(NOT DEFINED CTEST_SOURCE_DIRECTORY)
  if(DEFINED dashboard_source_name)
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_source_name})
  else()
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/src/${PROJECT})
  endif()
endif()

# Select a build directory name.
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  if(DEFINED dashboard_binary_name)
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  else()
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/build/${PROJECT}-MinGW-${MXE_TARGET_ARCH})
  endif()
endif()

# Delete source tree if it is incompatible with current VCS.
if(EXISTS ${CTEST_SOURCE_DIRECTORY})
  if(NOT EXISTS "${CTEST_SOURCE_DIRECTORY}/.hg")
    set(vcs_refresh "because it is not managed by hg.")
  endif()
  if(${dashboard_fresh_source_checkout})
    set(vcs_refresh "because dashboard_fresh_source_checkout is specified.")
  endif()
  if(vcs_refresh)
    message("Deleting source tree\n  ${CTEST_SOURCE_DIRECTORY}\n${vcs_refresh}")
    file(REMOVE_RECURSE "${CTEST_SOURCE_DIRECTORY}")
  endif()
endif()

# Support initial checkout if necessary.
if(NOT EXISTS "${CTEST_SOURCE_DIRECTORY}"
    AND NOT DEFINED CTEST_CHECKOUT_COMMAND)
  get_filename_component(_name "${CTEST_SOURCE_DIRECTORY}" NAME)

    # Generate an initial checkout script.
    set(ctest_checkout_script ${CTEST_DASHBOARD_ROOT}/${_name}-init.cmake)
    file(WRITE ${ctest_checkout_script}
"# hg repo init script for ${_name}
execute_process(
  COMMAND \"${CTEST_HG_COMMAND}\" clone -r ${dashboard_hg_branch}  \"${dashboard_hg_url}\"
          \"${CTEST_SOURCE_DIRECTORY}\" )
"
)
  set(CTEST_CHECKOUT_COMMAND "\"${CMAKE_COMMAND}\" -P \"${ctest_checkout_script}\"")
  # CTest delayed initialization is broken, so we put the
  # CTestConfig.cmake info here.
  set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
  set(CTEST_DROP_METHOD "http")
  set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
  set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
  set(CTEST_DROP_SITE_CDASH TRUE)
else()
  set(CTEST_HG_UPDATE_OPTIONS "${CTEST_HG_UPDATE_OPTIONS} -r ${dashboard_hg_branch}")
endif()

#-----------------------------------------------------------------------------

# Send the main script as a note.
list(APPEND CTEST_NOTES_FILES
  "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
  "${CMAKE_CURRENT_LIST_FILE}"
  )

if(NOT DEFINED CTEST_BUILD_NAME)
set(CTEST_BUILD_NAME "Windows-MinGW-w64-${MXE_TARGET_ARCH}-${CTEST_BUILD_CONFIGURATION}")
endif()

# Check for required variables.
foreach(req
    CTEST_CMAKE_GENERATOR
    CTEST_SITE
    CTEST_BUILD_NAME
    MXE_ROOT
    MXE_TARGET_ARCH
    PROJECT
    )
  if(NOT DEFINED ${req})
    message(FATAL_ERROR "The containing script must set ${req}")
  endif()
endforeach(req)

# Print summary information.
foreach(v
    CTEST_SITE
    CTEST_BUILD_NAME
    MXE_ROOT
    MXE_TARGET_ARCH
    PROJECT
    CMAKE_COMMAND
    CTEST_SOURCE_DIRECTORY
    CTEST_BINARY_DIRECTORY
    CTEST_CMAKE_GENERATOR
    CTEST_BUILD_CONFIGURATION
    CTEST_HG_COMMAND
    CTEST_CHECKOUT_COMMAND
    CTEST_SCRIPT_DIRECTORY
    CTEST_USE_LAUNCHERS
    )
  set(vars "${vars}  ${v}=[${${v}}]\n")
endforeach(v)
message("Dashboard script configuration:\n${vars}\n")

# Avoid non-ascii characters in tool output.
set(ENV{LC_ALL} C)

# Helper macro to write the initial cache.
macro(write_cache)
  set(cache_build_type "")
  set(cache_make_program "")
  if(CTEST_CMAKE_GENERATOR MATCHES "Make")
    set(cache_build_type CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION})
    if(CMAKE_MAKE_PROGRAM)
      set(cache_make_program CMAKE_MAKE_PROGRAM:FILEPATH=${CMAKE_MAKE_PROGRAM})
    endif()
  endif()
  file(WRITE ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt "
SITE:STRING=${CTEST_SITE}
BUILDNAME:STRING=${CTEST_BUILD_NAME}
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
DART_TESTING_TIMEOUT:STRING=${CTEST_TEST_TIMEOUT}
${cache_build_type}
${cache_make_program}
${dashboard_cache}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_TOOLCHAIN_FILE:FILEPATH=${MXE_TARGET_ROOT}/share/cmake/mxe-conf.cmake

CMAKE_USE_PTHREADS:BOOL=OFF

CMAKE_USE_WIN32_THREADS:BOOL=ON

")
endmacro(write_cache)

# Start with a fresh build tree.
file(MAKE_DIRECTORY "${CTEST_BINARY_DIRECTORY}")
if(NOT "${CTEST_SOURCE_DIRECTORY}" STREQUAL "${CTEST_BINARY_DIRECTORY}"
    AND NOT dashboard_no_clean)
  message("Clearing build tree...")
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
endif()

set(dashboard_continuous 0)
if("${dashboard_model}" STREQUAL "Continuous")
  set(dashboard_continuous 1)
endif()
if(NOT DEFINED dashboard_loop)
  if(dashboard_continuous)
    set(dashboard_loop 43200)
  else()
    set(dashboard_loop 0)
  endif()
endif()

# CTest 2.6 crashes with message() after ctest_test.
macro(safe_message)
  if(NOT "${CMAKE_VERSION}" VERSION_LESS 2.8 OR NOT safe_message_skip)
    message(${ARGN})
  endif()
endmacro()

if(COMMAND dashboard_hook_init)
  dashboard_hook_init()
endif()

set(dashboard_done 0)
while(NOT dashboard_done)
  if(dashboard_loop)
    set(START_TIME ${CTEST_ELAPSED_TIME})
  endif()
  set(ENV{HOME} "${dashboard_user_home}")

  # Start a new submission.
  if(COMMAND dashboard_hook_start)
    dashboard_hook_start()
  endif()
  ctest_start(${dashboard_model})

  # Always build if the tree is fresh.
  set(dashboard_fresh 0)
  if(NOT EXISTS "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt")
    set(dashboard_fresh 1)
    safe_message("Starting fresh build...")
    write_cache()
  endif()

  # Look for updates.
  ctest_update(RETURN_VALUE count)
  set(CTEST_CHECKOUT_COMMAND) # checkout on first iteration only
  safe_message("Found ${count} changed files")

  if(dashboard_fresh OR NOT dashboard_continuous OR count GREATER 0)
    ctest_configure()
    ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})

    if(COMMAND dashboard_hook_build)
      dashboard_hook_build()
    endif()
    ctest_build()

    if(NOT dashboard_no_test)
      if(COMMAND dashboard_hook_test)
        dashboard_hook_test()
      endif()
      ctest_test(${CTEST_TEST_ARGS})
    endif()

    set(safe_message_skip 1) # Block furhter messages

    if(dashboard_do_coverage)
      if(COMMAND dashboard_hook_coverage)
        dashboard_hook_coverage()
      endif()
      ctest_coverage()
    endif()
    if(dashboard_do_memcheck)
      if(COMMAND dashboard_hook_memcheck)
        dashboard_hook_memcheck()
      endif()
      ctest_memcheck()
    endif()
    if(COMMAND dashboard_hook_submit)
      dashboard_hook_submit()
    endif()
    if(NOT dashboard_no_submit)
      ctest_submit()
    endif()
    if(COMMAND dashboard_hook_end)
      dashboard_hook_end()
    endif()
  endif()

  if(dashboard_loop)
    # Delay until at least 5 minutes past START_TIME
    ctest_sleep(${START_TIME} 300 ${CTEST_ELAPSED_TIME})
    if(${CTEST_ELAPSED_TIME} GREATER ${dashboard_loop})
      set(dashboard_done 1)
    endif()
  else()
    # Not continuous, so we are done.
    set(dashboard_done 1)
  endif()
endwhile()
