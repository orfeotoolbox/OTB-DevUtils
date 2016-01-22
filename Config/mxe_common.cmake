# OTB MXE Common Dashboard Script
# Client maintainer: rashad.kanavath@c-s.fr

cmake_minimum_required(VERSION 3.4 FATAL_ERROR)

set(dashboard_user_home "$ENV{HOME}")

# Select the model (Nightly, Experimental, Continuous, CrossCompile).
if(NOT DEFINED dashboard_model)
  set(dashboard_model Nightly)
endif()

string(TOLOWER ${dashboard_model} _dashboard_model)

if(NOT "${dashboard_model}" MATCHES "^(Nightly|Experimental|Continuous|CrossCompile)$")
  message(FATAL_ERROR "dashboard_model must be Nightly, Experimental, or Continuous")
endif()

if(NOT DEFINED CTEST_DASHBOARD_ROOT)
  set(CTEST_DASHBOARD_ROOT "/data/dashboard")
endif()

# Default to a Debug build.
if(NOT DEFINED CTEST_CONFIGURATION_TYPE AND DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_CONFIGURATION_TYPE ${CTEST_BUILD_CONFIGURATION})
endif()

if(NOT DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION Release)
endif()

if(NOT DEFINED CTEST_CONFIGURATION_TYPE)
  set(CTEST_CONFIGURATION_TYPE Release)
endif()

if(NOT CTEST_CMAKE_GENERATOR)
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
endif()

if(NOT CTEST_BUILD_FLAGS)
  set(CTEST_BUILD_FLAGS "-j4 -k" )
endif()

if(NOT CTEST_TEST_ARGS)
  set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
endif()

if(NOT DEFINED MXE_ROOT)
  set(MXE_ROOT "/data/tools/mxe")
endif()

if(NOT DEFINED CTEST_SITE)
  set(CTEST_SITE "bumblebee.c-s.fr")
endif()

if(NOT DEFINED OTB_DATA_ROOT)
  set(OTB_DATA_ROOT_DEFAULT "/data/otb-data")
endif()

if(MXE_TARGET_ARCH MATCHES "i686")
  set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/i686-w64-mingw32.shared")
endif()
if(MXE_TARGET_ARCH MATCHES "x86_64")
  set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/x86_64-w64-mingw32.shared")
endif()

if(NOT MSVC)
  set(C_COMPILER_FLAGS_DEFAULT -Wall)
  set(CXX_COMPILER_FLAGS_DEFAULT -Wall)
endif()

if(C_COMPILER_FLAGS)
  set(C_COMPILER_FLAGS "${C_COMPILER_FLAGS_DEFAULT} ${C_COMPILER_FLAGS}")
endif()
if(CXX_COMPILER_FLAGS)
set(CXX_COMPILER_FLAGS "${CXX_COMPILER_FLAGS_DEFAULT} ${CXX_COMPILER_FLAGS}")
endif()

if(DEFINED CMAKE_COMMAND)
  set(CTEST_CMAKE_COMMAND "${CMAKE_COMMAND}")
endif()

if(NOT DEFINED dashboard_package_target)
  set(dashboard_package_target packages)
endif()

if(NOT DEFINED dashboard_default_target)
  set(dashboard_default_target install)
endif()

if(NOT DEFINED CMAKE_MAKE_PROGRAM)
set(CMAKE_MAKE_PROGRAM "/usr/bin/make")
endif()

string(TOLOWER ${PROJECT} _PROJECT)

if(NOT DEFINED dashboard_make_package)
  if(${_PROJECT} STREQUAL "otb" OR ${_PROJECT} STREQUAL "monteverdi" )
    set(dashboard_make_package TRUE)
  else()
    set(dashboard_make_package FALSE)
  endif()
endif()

set(build_directory_name MinGW)
if(DEFINED dashboard_module)
  set(CTEST_TEST_ARGS INCLUDE_LABEL ${dashboard_module})
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-${dashboard_module}")
  set(CTEST_DASHBOARD_TRACK RemoteModules)
  set(PROJECT otb)
  set(build_directory_name ${dashboard_module})
endif()

set(mxe_common_cache
"
GDAL_CONFIG:FILEPATH='${MXE_TARGET_ROOT}/bin/gdal-config'

OSSIM_LIBRARY:FILEPATH='${MXE_TARGET_ROOT}/lib/libossim.dll.a;${MXE_TARGET_ROOT}/lib/libOpenThreads.dll.a'

CMAKE_C_FLAGS:STRING=${C_COMPILER_FLAGS}

CMAKE_CXX_FLAGS:STRING=${CXX_COMPILER_FLAGS}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/${_dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}

CMAKE_CROSSCOMPILING:BOOL=TRUE

CMAKE_CROSSCOMPILING_EMULATOR:FILEPATH=/usr/bin/wine

"
)

set(otb_version 1.0)
set(otb_cmake_root_dir ${CTEST_DASHBOARD_ROOT}/${_dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}/lib/cmake)
file(GLOB otb_cmake_version_dirs RELATIVE ${otb_cmake_root_dir} ${otb_cmake_root_dir}/*)
foreach(otb_cmake_version_dir ${otb_cmake_version_dirs})
  if(IS_DIRECTORY ${otb_cmake_root_dir}/${otb_cmake_version_dir})
    string(SUBSTRING ${otb_cmake_version_dir} 4 -1 cur_version_dir)
    if(otb_version LESS ${cur_version_dir})
      set(otb_version ${cur_version_dir})
    endif()
  endif()
endforeach()

if(NOT ${_PROJECT} STREQUAL "otb")
  set(mxe_common_cache
" ${mxe_common_cache}

OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/${_dashboard_model}/install-MinGW-${MXE_TARGET_ARCH}/lib/cmake/OTB-${otb_version}

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

if(${_PROJECT} STREQUAL "monteverdi")
  set(mxe_common_cache
    " ${mxe_common_cache}

ICE_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/include

ICE_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/lib/libOTBIce.dll.a

")

endif()

if(DEFINED dashboard_module)
  set(mxe_common_cache
    " ${mxe_common_cache}

BUILD_EXAMPLES:BOOL=OFF

OTB_DATA_USE_LARGEINPUT:BOOL=ON

OTB_DATA_ROOT:STRING=${OTB_DATA_ROOT}

BUILD_TESTING:BOOL=ON

OTB_BUILD_DEFAULT_MODULES:BOOL=OFF

Module_${dashboard_module}:BOOL=ON

")
endif()


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

if(NOT DEFINED CTEST_DASHBOARD_TRACK)
  set(CTEST_DASHBOARD_TRACK CrossCompile)
endif()

if(NOT DEFINED CTEST_BUILD_NAME)
set(CTEST_BUILD_NAME "Windows-MinGW-w64-${MXE_TARGET_ARCH}-${CTEST_BUILD_CONFIGURATION}")
endif()


# Select Git source to use.
if(NOT DEFINED dashboard_git_url)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/${PROJECT}.git")
endif()
if(NOT DEFINED dashboard_git_branch)
  set(dashboard_git_branch nightly)
endif()

if(NOT DEFINED dashboard_git_crlf)
  if(UNIX)
    set(dashboard_git_crlf false)
  else(UNIX)
    set(dashboard_git_crlf true)
  endif(UNIX)
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

# Look for a GIT command-line client.
if(NOT DEFINED CTEST_GIT_COMMAND)
  find_program(CTEST_GIT_COMMAND NAMES git)
endif()

if(NOT DEFINED CTEST_GIT_COMMAND)
  message(FATAL_ERROR "No git command Found.")
endif()

if(NOT DEFINED CTEST_GIT_UPDATE_CUSTOM)
  set(CTEST_GIT_UPDATE_CUSTOM  ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=${dashboard_git_branch} -P ${CTEST_SCRIPT_DIRECTORY}/../../git_updater.cmake)
endif()

# Select a source directory name.
if(NOT DEFINED CTEST_SOURCE_DIRECTORY)
  if(DEFINED dashboard_source_name)
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_source_name})
  else()    
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${_dashboard_model}/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src)
  endif()
endif()

# Select a build directory name.
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  if(DEFINED dashboard_binary_name)
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  else()
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${_dashboard_model}/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-${build_directory_name}-${MXE_TARGET_ARCH})
  endif()
endif()

# Select source directory to update
if(NOT DEFINED dashboard_update_dir)
  set(dashboard_update_dir ${CTEST_SOURCE_DIRECTORY})
endif()


# Delete source tree if it is incompatible with current VCS.
if(EXISTS ${dashboard_update_dir})
  if(NOT EXISTS "${dashboard_update_dir}/.git")
    set(vcs_refresh "because it is not managed by git.")
  endif()
  if(${dashboard_fresh_source_checkout})
    set(vcs_refresh "because dashboard_fresh_source_checkout is specified.")
  endif()
  if(vcs_refresh)
    message("Deleting source tree\n  ${dashboard_update_dir}\n${vcs_refresh}")
    file(REMOVE_RECURSE "${dashboard_update_dir}")
  endif()
endif()

# Support initial checkout if necessary.
if(NOT EXISTS "${dashboard_update_dir}"
    AND NOT DEFINED CTEST_CHECKOUT_COMMAND)
  get_filename_component(_name "${dashboard_update_dir}" NAME)
  message("_name= " ${_name})
  # Generate an initial checkout script.
  set(ctest_checkout_script ${CTEST_DASHBOARD_ROOT}/${_name}-init.cmake)
  message("ctest_checkout_script= " ${ctest_checkout_script})
  file(WRITE ${ctest_checkout_script} "# git repo init script for ${_name}
        execute_process(
            COMMAND \"${CTEST_GIT_COMMAND}\" clone \"${dashboard_git_url}\"
                    \"${dashboard_update_dir}\" )   ")

  set(CTEST_CHECKOUT_COMMAND "\"${CMAKE_COMMAND}\" -P \"${ctest_checkout_script}\"")
  # CTest delayed initialization is broken, so we put the
  # CTestConfig.cmake info here.
  set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
  set(CTEST_DROP_METHOD "http")
  set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
  set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
  set(CTEST_DROP_SITE_CDASH TRUE)
endif()

#-----------------------------------------------------------------------------

# Send the main script as a note.
list(APPEND CTEST_NOTES_FILES
  "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
  "${CMAKE_CURRENT_LIST_FILE}"
  )


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
    CTEST_SCRIPT_DIRECTORY
    CTEST_USE_LAUNCHERS    
    MXE_ROOT
    MXE_TARGET_ARCH
    PROJECT
    CMAKE_COMMAND
    CTEST_CMAKE_COMMAND
    CMAKE_CROSSCOMPILING
    CMAKE_CROSSCOMPILING_EMULATOR
    CTEST_SOURCE_DIRECTORY
    CTEST_BINARY_DIRECTORY
    CTEST_CMAKE_GENERATOR
    CTEST_BUILD_CONFIGURATION
    CTEST_GIT_COMMAND
    CTEST_GIT_UPDATE_OPTIONS
    CTEST_CHECKOUT_COMMAND
    CTEST_DASHBOARD_TRACK
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
${mxe_common_cache}
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

  if(EXISTS "${CTEST_BINARY_DIRECTORY}")
    message("Clearing build tree...")
    ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  endif()
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
  if(NOT "${CMAKE_VERSION}" VERSION_LESS 3.4 OR NOT safe_message_skip)
    message(STATUS ${ARGN})
  endif()
endmacro()

# macro for the full dashboard sequence
macro(run_dashboard)
  # Start a new submission.
  if(COMMAND dashboard_hook_start)
    dashboard_hook_start()
  endif()
  ctest_start(${dashboard_model} TRACK ${CTEST_DASHBOARD_TRACK})

  # Always build if the tree is fresh.
  set(dashboard_fresh 0)
  if(NOT EXISTS "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt")
    set(dashboard_fresh 1)
    safe_message("Starting fresh build...")
    write_cache()
  endif()

  # Look for updates.
  ctest_update(SOURCE ${dashboard_update_dir} RETURN_VALUE count)
  set(CTEST_CHECKOUT_COMMAND) # checkout on first iteration only
  safe_message("Found ${count} changed files")

  # add specific modules (works for OTB only)
  if(DEFINED dashboard_module AND DEFINED dashboard_module_url)
    execute_process(COMMAND "${CTEST_GIT_COMMAND}"
      "clone" "${dashboard_module_url}"  "${dashboard_update_dir}/Modules/Remote/${dashboard_module}" RESULT_VARIABLE rv)
    if(NOT rv EQUAL 0)
      message(FATAL_ERROR "Cannot checkout remote module: ${rv}")
    endif()
  endif()
  
  if(dashboard_fresh OR NOT dashboard_continuous OR count GREATER 0)
   ctest_configure()
   ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
    
   if(COMMAND dashboard_hook_build)
     dashboard_hook_build()
   endif()
    
   ctest_build(BUILD ${CTEST_BINARY_DIRECTORY}
     TARGET ${dashboard_default_target}
     RETURN_VALUE _default_build_rv)
   
   if(dashboard_make_package)
     if(COMMAND dashboard_hook_package)
       dashboard_hook_package()
     endif()
     ctest_build(BUILD ${CTEST_BINARY_DIRECTORY}
       TARGET ${dashboard_package_target}
       RETURN_VALUE _package_build_rv)
   endif()
   
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

  run_dashboard()

  # test additional feature branches
  if(number_additional_branches GREATER 0)
    set(ORIGINAL_CTEST_BUILD_NAME ${CTEST_BUILD_NAME})
    set(ORIGINAL_CTEST_GIT_UPDATE_CUSTOM ${CTEST_GIT_UPDATE_CUSTOM})
    foreach(branch ${additional_branches})
      set(CTEST_BUILD_NAME  ${ORIGINAL_CTEST_BUILD_NAME}-${branch})
      set(CTEST_GIT_UPDATE_CUSTOM  ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=${branch} -P ${CTEST_SCRIPT_DIRECTORY}/../git_updater.cmake)
      run_dashboard()
    endforeach()
    set(CTEST_BUILD_NAME ${ORIGINAL_CTEST_BUILD_NAME})
    set(CTEST_GIT_UPDATE_CUSTOM ${ORIGINAL_CTEST_GIT_UPDATE_CUSTOM})
    # update sources back to their original state
    ctest_update(SOURCE ${dashboard_update_dir} RETURN_VALUE count)
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

ctest_sleep(5)
if(DEFINED dashboard_module AND DEFINED dashboard_module_url)
  file(REMOVE_RECURSE "${dashboard_update_dir}/Modules/Remote/${dashboard_module}")
endif()
