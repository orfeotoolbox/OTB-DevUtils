# OTB Common Dashboard Script
#
# This script contains basic dashboard driver code common to all
# clients.
#
# Put this script in a directory such as "~/Dashboards/Scripts" or
# "c:/Dashboards/Scripts".  Also place the script "git_updater.cmake" in the
# same folder to use custom update commands. Create a file next to this script,
# say 'my_dashboard.cmake', with code of the following form:
#
#   # Client maintainer: me@mydomain.net
#   set(CTEST_SITE "machine.site")
#   set(CTEST_BUILD_NAME "Platform-Compiler")
#   set(CTEST_BUILD_CONFIGURATION Debug)
#   set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
#   set(CTEST_SOURCE_DIRECTORY Path_to_source_dir)
#   set(CTEST_BINARY_DIRECTORY Path_to_build_dir)
#   set(dashboard_model Nightly)
#   set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
#   macro(dashboard_hook_init)
#     set(dashboard_cache "${dashboard_cache}
#       # set your initial cmake cache variables
#       ")
#   endmacro()
#   include(${CTEST_SCRIPT_DIRECTORY}/otb_common.cmake)
#
# Then run a scheduled task (cron job) with a command line such as
#
#   ctest -S ~/Dashboards/Scripts/my_dashboard.cmake -V
#
# By default the source and build trees will be placed in the path
# "../My Tests/" relative to your script location.
#
# The following variables may be set before including this script
# to configure it. If a variable is not defined, it may recieve a default value.
# Generally, the variables CTEST_* have priority over dashboard_* variables, as
# they are directly used by ctest :
#
#   ---------------------- General setup ---------------------------------------
#   dashboard_model           = Nightly | Experimental | Continuous
#   dashboard_loop            = Repeat until N seconds have elapsed
#   CTEST_SITE                = Site name
#   CTEST_BUILD_NAME          = Name of the build
#   CTEST_DASHBOARD_TRACK     = Dashboard track (default is guessed based on
#                               tested branch, dashboard model, and source dir)
#
#   -------------------- Directories setup -------------------------------------
#   dashboard_root_name       = Directory name containing source and build trees
#                               (default: "My Tests")
#   CTEST_DASHBOARD_ROOT      = Path to put source and build trees
#                               (default: script_dir/../$dashboard_root_name)
#   dashboard_source_name     = Name of source directory (default : OTB)
#   dashboard_binary_name     = Name of binary directory (default : OTB-build)
#   dashboard_update_dir      = Source directory to update (default :
#                               $CTEST_SOURCE_DIRECTORY)
#   CTEST_SOURCE_DIRECTORY    = Path to source directory (default :
#                               $CTEST_DASHBOARD_ROOT/$dashboard_source_name)
#   CTEST_BINARY_DIRECTORY    = Path to build directory (default :
#                               $CTEST_DASHBOARD_ROOT/$dashboard_binary_name)
#
#   ---------------------- Configure Setup -------------------------------------
#   CTEST_BUILD_CONFIGURATION = Configuration to build (Release/Debug/...)
#   dashboard_cache           = Initial CMakeCache.txt file content
#   dashboard_cache_for_xxx   = Specific cache content for branch 'xxx'
#   dashboard_build_target    = Default target to build (default depends on the
#                               project tested)
#   CTEST_BUILD_COMMAND       = DO NOT USE THIS VARIABLE !! IT OVERRIDES ANY
#                               FLAGS AND TARGET
#   dashboard_git_url         = URL of Git source repository
#   dashboard_git_branch      = Git branch to test (default is 'nightly' when
#                               dashboard model is Nightly, 'develop' otherwise)
#   dashboard_git_features_list = Path to a file containing additional feature
#                               branches to build & test. (incompatible with
#                               SuperBuild & RemoteModules)
#   CTEST_GIT_COMMAND         = Git executable
#   CTEST_GIT_UPDATE_CUSTOM   = Custom Git update command to replace 'git pull'
#                               (default is to use a home-made updater script
#                               git_updater.cmake, which does more cleaning)
#   dashboard_remote_modules  = enable testing of remote modules (official +
#                               incubation)
#   dashboard_module          = Name of the module to enable
#                               (incompatible with SuperBuild and additional
#                               feature branches)
#   dashboard_module_url      = URL of the requested remote module (if
#                               dashboard_module is remote)
#   CTEST_BUILD_FLAGS         = build tool arguments (ex: -j2)
#   CTEST_TEST_CTEST          = Whether to run long CTestTest* tests
#   CTEST_TEST_TIMEOUT        = Per-test timeout length
#   CTEST_TEST_ARGS           = ctest_test args (ex: PARALLEL_LEVEL 4)
#   CMAKE_MAKE_PROGRAM        = Path to "make" tool to use
#
#   ---------------------------- Hooks -----------------------------------------
#   The following macros will be invoked before the corresponding
#   step if they are defined:
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
#   ---------------------------- Flags -----------------------------------------
#   dashboard_fresh_source_checkout = True to checkout sources from scratch
#   dashboard_no_clean        = True to skip build tree wipeout
#   dashboard_no_test         = True to skip testing
#   dashboard_no_install      = True to skip install step
#   dashboard_do_coverage     = True to enable coverage (ex: gcov)
#   dashboard_do_memcheck     = True to enable memcheck (ex: valgrind)
#   dashboard_no_submit       = True to skip submit step
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

# find and include macro_common
if(EXISTS ${CTEST_SCRIPT_DIRECTORY}/macro_common.cmake)
  include(${CTEST_SCRIPT_DIRECTORY}/macro_common.cmake)
elseif(EXISTS ${CTEST_SCRIPT_DIRECTORY}/../macro_common.cmake)
  include(${CTEST_SCRIPT_DIRECTORY}/../macro_common.cmake)
elseif(EXISTS ${CTEST_SCRIPT_DIRECTORY}/../../macro_common.cmake)
  include(${CTEST_SCRIPT_DIRECTORY}/../../macro_common.cmake)
endif()

set(dashboard_user_home "$ENV{HOME}")

get_filename_component(dashboard_self_dir ${CMAKE_CURRENT_LIST_FILE} PATH)

# Select the top dashboard directory.
if(NOT DEFINED dashboard_root_name)
  set(dashboard_root_name "My Tests")
endif()
if(NOT DEFINED CTEST_DASHBOARD_ROOT)
  get_filename_component(CTEST_DASHBOARD_ROOT "${CTEST_SCRIPT_DIRECTORY}/../${dashboard_root_name}" ABSOLUTE)
endif()

# Select the model (Nightly, Experimental, Continuous).
if("${dashboard_model}" STREQUAL  "nightly")
  set(dashboard_model Nightly)
endif()

if(NOT DEFINED dashboard_model)
  set(dashboard_model Nightly)
endif()
if(NOT "${dashboard_model}" MATCHES "^(Nightly|Experimental|Continuous)$")
  message(FATAL_ERROR "dashboard_model must be Nightly, Experimental, or Continuous")
endif()

# Default to a Debug build.
if(NOT DEFINED CTEST_CONFIGURATION_TYPE AND DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_CONFIGURATION_TYPE ${CTEST_BUILD_CONFIGURATION})
endif()

if(NOT DEFINED CTEST_CONFIGURATION_TYPE)
  set(CTEST_CONFIGURATION_TYPE Debug)
endif()

if(NOT CTEST_TEST_ARGS)
  set(CTEST_TEST_ARGS PARALLEL_LEVEL 3)
endif()

#PKG
if(DEFINED ENV{OTBNAS_PACKAGES_DIR})
  set(OTBNAS_PACKAGES_DIR "$ENV{OTBNAS_PACKAGES_DIR}")
endif()
  
if(dashboard_label)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-${dashboard_label}")
  # we are sure this is an experimental build
  set(CTEST_DASHBOARD_TRACK Experimental)
endif()

if(NOT CTEST_CMAKE_GENERATOR)
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
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

if(NOT DEFINED dashboard_no_configure)
  set(dashboard_no_configure FALSE)
endif()

if(NOT DEFINED dashboard_no_build)
  set(dashboard_no_build FALSE)
endif()

if(NOT DEFINED dashboard_no_examples)
  set(dashboard_no_examples TRUE)
endif()
if(NOT DEFINED dashboard_enable_large_input)
  set(dashboard_enable_large_input FALSE)
endif()

# Select a source directory name.
if(NOT DEFINED CTEST_SOURCE_DIRECTORY)
  if(DEFINED dashboard_source_name)
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_source_name})
  else()
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/OTB)
  endif()
endif()
get_filename_component(_source_directory_abspath "${CTEST_SOURCE_DIRECTORY}" ABSOLUTE)
get_filename_component(_source_directory_filename "${_source_directory_abspath}" NAME)

# Select a build directory name.
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  if(DEFINED dashboard_binary_name)
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  else()
    set(CTEST_BINARY_DIRECTORY ${CTEST_SOURCE_DIRECTORY}-build)
  endif()
endif()

# Select source directory to update
if(NOT DEFINED dashboard_update_dir)
  set(dashboard_update_dir ${CTEST_SOURCE_DIRECTORY})
endif()

# set default target depending on the project
if("${dashboard_update_dir}" STREQUAL "${CTEST_SOURCE_DIRECTORY}")
  set(default_target install)
else()
  if("${_source_directory_filename}" STREQUAL "SuperBuild")
    set(default_target OTB)
  elseif("${_source_directory_filename}" STREQUAL "Packaging")
    set(default_target PACKAGE-OTB)
  elseif("${_source_directory_filename}" STREQUAL "CookBook")
    set(default_target)
  elseif("${_source_directory_filename}" STREQUAL "SoftwareGuide")
    set(default_target)
  elseif("${_source_directory_filename}" STREQUAL "Examples")
    set(default_target)
  else()
    set(default_target install)
  endif()
endif()

# Select Git source to use.
if(NOT DEFINED dashboard_git_url)
  set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
endif()

if(NOT DEFINED dashboard_git_branch)
  if("${dashboard_model}" STREQUAL "Nightly")
    set(dashboard_git_branch nightly)
  else()
    set(dashboard_git_branch develop)
  endif()
  # handle SuperBuild branch
  if("${_source_directory_filename}" STREQUAL "SuperBuild")
    if(EXISTS ${CTEST_SCRIPT_DIRECTORY}/superbuild_branch.txt)
      set(_superbuild_branch_file ${CTEST_SCRIPT_DIRECTORY}/superbuild_branch.txt)
    elseif(EXISTS ${CTEST_SCRIPT_DIRECTORY}/../superbuild_branch.txt)
      set(_superbuild_branch_file ${CTEST_SCRIPT_DIRECTORY}/../superbuild_branch.txt)
    elseif(EXISTS ${CTEST_SCRIPT_DIRECTORY}/../../superbuild_branch.txt)
      set(_superbuild_branch_file ${CTEST_SCRIPT_DIRECTORY}/../../superbuild_branch.txt)
    endif()
    if(EXISTS ${_superbuild_branch_file})
      file(STRINGS ${_superbuild_branch_file} _superbuild_branch_content
           REGEX "^ *([a-zA-Z0-9]|-|_|\\.)+ *\$")
      if(_superbuild_branch_content)
        list(GET _superbuild_branch_content 0 dashboard_git_branch)
      endif()
    endif()
  endif()
endif()
if(NOT DEFINED dashboard_git_crlf)
  if(UNIX)
    set(dashboard_git_crlf false)
  else(UNIX)
    set(dashboard_git_crlf true)
  endif(UNIX)
endif()

# Detect additional branches to test
if(DEFINED dashboard_git_features_list)
  message("Checking feature branches file : ${dashboard_git_features_list}")
  file(STRINGS ${dashboard_git_features_list} _feature_list_content
       REGEX "^ *([a-zA-Z0-9]|-|_|\\.)+ *([a-zA-Z0-9]|-|_|\\.)* *\$")
  unset(additional_branches)
  foreach(_line ${_feature_list_content})
    string(REGEX REPLACE "^ *(([a-zA-Z0-9]|-|_|\\.)+) *(([a-zA-Z0-9]|-|_|\\.)*) *\$" "\\1" _branch ${_line})
    string(REGEX REPLACE "^ *(([a-zA-Z0-9]|-|_|\\.)+) *(([a-zA-Z0-9]|-|_|\\.)*) *\$" "\\3" _databranch ${_line})
    list(APPEND additional_branches ${_branch})
    if(specific_data_branch_for_${_branch})
      unset(specific_data_branch_for_${_branch})
    endif()
    if(_databranch)
      set(specific_data_branch_for_${_branch} ${_databranch})
      message("Found specific data branch for ${_branch} : ${_databranch}")
    endif()
  endforeach()
  list(LENGTH additional_branches number_additional_branches)
  if(number_additional_branches GREATER 0)
    message("Testing feature branches : ${additional_branches}")
  endif()
endif()

# Look for a GIT command-line client.
if(NOT DEFINED CTEST_GIT_COMMAND)
  find_program(CTEST_GIT_COMMAND NAMES git git.cmd)
endif()

if(NOT DEFINED CTEST_GIT_COMMAND)
  message(FATAL_ERROR "No Git Found.")
endif()

# Q : can we try to use a simple string with all commands separated by &&
# something like :
#   set(CTEST_GIT_UPDATE_CUSTOM git fetch && git clean && git checkout && git reset)
# A : it doesn't work, the && are not interpreted, and grouping all the command
# inside double quotes doesn't work either (tested with cmake 2.8)

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
if(NOT EXISTS "${dashboard_update_dir}" AND
   NOT DEFINED CTEST_CHECKOUT_COMMAND)
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
endif()

# CTest delayed initialization is broken, so we put the
# CTestConfig.cmake info here.
if("${_source_directory_filename}" STREQUAL "CookBook" OR
   "${_source_directory_filename}" STREQUAL "SoftwareGuide")
  set(CTEST_PROJECT_NAME "Documentation")
else()
  set(CTEST_PROJECT_NAME "OTB")
endif()
set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "https")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=${CTEST_PROJECT_NAME}")
set(CTEST_DROP_SITE_CDASH TRUE)


# Choose the dashboard track
if(NOT DEFINED CTEST_DASHBOARD_TRACK)
  # Guess using the dashboard model
  if("${dashboard_model}" STREQUAL "Nightly")
    # Guess using the branch name (except with superbuild)
    if("${_source_directory_filename}" STREQUAL "SuperBuild")
      set(CTEST_DASHBOARD_TRACK SuperBuild)
    elseif("${_source_directory_filename}" STREQUAL "Packaging")
      set(CTEST_DASHBOARD_TRACK Packaging)
    elseif("${_source_directory_filename}" STREQUAL "Examples")
      set(CTEST_DASHBOARD_TRACK Examples)
    elseif("${dashboard_git_branch}" STREQUAL "master")
      set(CTEST_DASHBOARD_TRACK Nightly)
    elseif("${dashboard_git_branch}" STREQUAL "nightly")
      set(CTEST_DASHBOARD_TRACK Develop)
    elseif("${dashboard_git_branch}" MATCHES "^release-[0-9]+\\.[0-9]+\$")
      set(CTEST_DASHBOARD_TRACK LatestRelease)
    else()
      #send build to FeatureBranches track if a match for branch name is not found
      #ofcourse, this can be overriden in the other script by directly setting
      #CTEST_DASHBOARD_TRACK or changing dashboard_model to Experimental
      set(CTEST_DASHBOARD_TRACK FeatureBranches)
    endif()
  elseif("${dashboard_model}" STREQUAL "Continuous")
    set(CTEST_DASHBOARD_TRACK Continuous)
  elseif("${dashboard_model}" STREQUAL "Experimental")
    set(CTEST_DASHBOARD_TRACK Experimental)
  endif()

  if(dashboard_module_url OR dashboard_remote_modules)
    # RemoteModules (either specific URL, or all remote modules tested
    set(CTEST_DASHBOARD_TRACK RemoteModules)
  elseif(dashboard_module)
    # Specific module selected (may not be a remote one)
    set(CTEST_DASHBOARD_TRACK Experimental)
  endif()
endif()

#-----------------------------------------------------------------------------
# Handle remote modules
if(dashboard_remote_modules)
  # Parse existing remote modules (official + incubated)
  set(remotes_list_all)
  get_remote_modules(${CTEST_DASHBOARD_ROOT}/${dashboard_source_name}/Modules/Remote remotes_list_all)
  get_remote_modules(${CTEST_SCRIPT_DIRECTORY}/../moduleIncubation remotes_list_all)
  list(REMOVE_DUPLICATES remotes_list_all)
  # filter the list
  if(dashboard_remote_blacklist)
    list(REMOVE_ITEM remotes_list_all ${dashboard_remote_blacklist})
  endif()
endif()

#-----------------------------------------------------------------------------
# Send the main script as a note.
list(APPEND CTEST_NOTES_FILES
  "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
  "${CMAKE_CURRENT_LIST_FILE}"
  )

if("${_source_directory_filename}" STREQUAL "SuperBuild")
  set(CTEST_NOTES_FILES
    "${CTEST_BINARY_DIRECTORY}/OTB/src/OTB-stamp/OTB-configure-out.log"
    "${CTEST_BINARY_DIRECTORY}/OTB/src/OTB-stamp/OTB-configure-err.log"
    )
endif()

# Check for required variables.
foreach(req
    CTEST_CMAKE_GENERATOR
    CTEST_SITE
    CTEST_BUILD_NAME
    CTEST_NIGHTLY_START_TIME
    CTEST_DROP_METHOD
    CTEST_DROP_SITE
    CTEST_DROP_LOCATION
    CTEST_DROP_SITE_CDASH
    dashboard_git_branch
    )
  if(NOT DEFINED ${req})
    message(FATAL_ERROR "The containing script must set ${req}")
  endif()
endforeach(req)

# Print summary information.
foreach(v
    CTEST_SITE
    CTEST_BUILD_NAME
    CTEST_SOURCE_DIRECTORY
    CTEST_BINARY_DIRECTORY
    CTEST_CMAKE_GENERATOR
    CTEST_BUILD_CONFIGURATION
    CTEST_GIT_COMMAND
    CTEST_GIT_UPDATE_OPTIONS
    CTEST_CHECKOUT_COMMAND
    CTEST_SCRIPT_DIRECTORY
    CTEST_USE_LAUNCHERS
    CTEST_DASHBOARD_TRACK
    CTEST_NIGHTLY_START_TIME
    CTEST_DROP_METHOD
    CTEST_DROP_SITE
    CTEST_DROP_LOCATION
    CTEST_DROP_SITE_CDASH
    dashboard_git_branch
    OTBNAS_PACKAGES_DIR
    )
  set(vars "${vars}  ${v}=[${${v}}]\n")
endforeach(v)
message("Dashboard script configuration:\n${vars}\n")

# Avoid non-ascii characters in tool output.
set(ENV{LC_ALL} C)

macro(dashboard_copy_packages)
  set(copy_packages_failed FALSE)
  if(WIN32)
    file(GLOB otb_package_file "${CTEST_BINARY_DIRECTORY}/OTB*.zip")
  else()
    file(GLOB otb_package_file "${CTEST_BINARY_DIRECTORY}/OTB*.run")
  endif()

if(EXISTS "${OTBNAS_PACKAGES_DIR}")
  foreach(item ${otb_package_file})
    get_filename_component(package_file_name ${item} NAME)
    # copy packages to otbnas
    execute_process(
      COMMAND ${CMAKE_COMMAND} 
      -E copy
      "${item}"
      "${OTBNAS_PACKAGES_DIR}/${package_file_name}"
      RESULT_VARIABLE copy_rv
      WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY})
 
    if(NOT copy_rv EQUAL 0)
      set(copy_packages_failed TRUE)
    endif()
  endforeach()
endif() #exists OTBNAS_PACKAGES_DIR

if(copy_packages_failed)
  message("Cannot copy '${otb_package_file}' to '${OTBNAS_PACKAGES_DIR}'")
else()
  message("Copied '${otb_package_file}' to '${OTBNAS_PACKAGES_DIR}'")
endif()
endmacro(dashboard_copy_packages)

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
${dashboard_cache_for_${dashboard_current_branch}}
")
endmacro(write_cache)

#------------------------------------------------------------------------------
# Cleaning
file(MAKE_DIRECTORY "${CTEST_BINARY_DIRECTORY}")
if(NOT "${CTEST_SOURCE_DIRECTORY}" STREQUAL "${CTEST_BINARY_DIRECTORY}"
    AND NOT dashboard_no_clean)
  message("Clearing build tree...")
  if(WIN32)
    remove_folder_recurse(${CTEST_BINARY_DIRECTORY})
    file(MAKE_DIRECTORY "${CTEST_BINARY_DIRECTORY}")
  else()
    ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  endif()
endif()
if(IS_DIRECTORY ${CTEST_INSTALL_DIRECTORY} AND NOT dashboard_no_clean)
  if(WIN32)
    remove_folder_recurse(${CTEST_INSTALL_DIRECTORY})
    file(MAKE_DIRECTORY "${CTEST_INSTALL_DIRECTORY}")
  else()
    ctest_empty_binary_directory(${CTEST_INSTALL_DIRECTORY})
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
  if(NOT "${CMAKE_VERSION}" VERSION_LESS 2.8 OR NOT safe_message_skip)
    message(${ARGN})
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
  endif()
  write_cache()

  # Checkout specific data branch if any
  if(DEFINED specific_data_branch_for_${dashboard_current_branch})
    set_git_update_command(${specific_data_branch_for_${dashboard_current_branch}})
    execute_process(COMMAND ${CTEST_GIT_UPDATE_CUSTOM}
                    WORKING_DIRECTORY ${dashboard_otb_data_root})
    message("Set data branch to ${specific_data_branch_for_${dashboard_current_branch}}")
  endif()

  # Look for updates.
  if(NOT dashboard_no_update)
    set_git_update_command(${dashboard_current_branch})
    ctest_update(SOURCE ${dashboard_update_dir} RETURN_VALUE count)
    set(CTEST_CHECKOUT_COMMAND) # checkout on first iteration only
    message("Found ${count} changed files")
  else()
    message("dashboard_no_update is TRUE. skipping update of source tree")
  endif()

  # add specific modules (works for OTB only)
  if(dashboard_module AND dashboard_module_url)
    execute_process(COMMAND "${CTEST_GIT_COMMAND}" "clone" "${dashboard_module_url}"  "${dashboard_update_dir}/Modules/Remote/${dashboard_module}" RESULT_VARIABLE rv)
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

    # find the target to build
    set(_target)
    if(dashboard_build_target)
      message("building requested target ${dashboard_build_target} on ${CTEST_BINARY_DIRECTORY}")
      set(_target "${dashboard_build_target}")
    elseif(dashboard_module)
      set(_target "${dashboard_module}-all")
    elseif(default_target)
      set(_target ${default_target})
    endif()
    if(dashboard_no_install AND "${_target}" STREQUAL "install")
      set(_target)
    endif()

    # ---------- Building ----------
    if(_target)
      ctest_build(
        BUILD "${CTEST_BINARY_DIRECTORY}"
        TARGET "${_target}"
        RETURN_VALUE _build_rv)
    else()
      ctest_build(
        BUILD "${CTEST_BINARY_DIRECTORY}"
        RETURN_VALUE _build_rv)
    endif()

    if(NOT dashboard_no_test)
      # ---------- Testing ----------
      set(CTEST_TEST_ARGS ${ORIGINAL_CTEST_TEST_ARGS})
      if(dashboard_module)
        list(APPEND CTEST_TEST_ARGS INCLUDE_LABEL ${dashboard_module})
      elseif(dashboard_label)
        list(APPEND CTEST_TEST_ARGS INCLUDE_LABEL ${dashboard_label})
      endif()
      if(COMMAND dashboard_hook_test)
        dashboard_hook_test()
      endif()

      ctest_test(${CTEST_TEST_ARGS})
    endif()

    set(safe_message_skip 1) # Block further messages

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

  # reset data to Nightly branch
  if(DEFINED specific_data_branch_for_${dashboard_current_branch})
    set_git_update_command(nightly)
    execute_process(COMMAND ${CTEST_GIT_UPDATE_CUSTOM}
                    WORKING_DIRECTORY ${dashboard_otb_data_root})
    message("Reset data")
  endif()
endmacro()

if(COMMAND dashboard_hook_init)
  dashboard_hook_init()
endif()

# try to find OTB-Data location
if(NOT DEFINED dashboard_otb_data_root)
  if("${dashboard_cache}" MATCHES "^.*OTB_DATA_ROOT:(STRING|PATH)=([^\n\r]+).*\$")
    string(REGEX REPLACE "^.*OTB_DATA_ROOT:(STRING|PATH)=([^\n\r]+).*\$" "\\2" dashboard_otb_data_root "${dashboard_cache}")
    message("Detected data root : ${dashboard_otb_data_root}")
  endif()
endif()

# Backup some variables
set(ORIGINAL_CTEST_BUILD_NAME ${CTEST_BUILD_NAME})
set(ORIGINAL_CTEST_DASHBOARD_TRACK ${CTEST_DASHBOARD_TRACK})
set(ORIGINAL_CTEST_TEST_ARGS ${CTEST_TEST_ARGS})

set(dashboard_done 0)
while(NOT dashboard_done)
  if(dashboard_loop)
    set(START_TIME ${CTEST_ELAPSED_TIME})
  endif()
  set(ENV{HOME} "${dashboard_user_home}")
  set(dashboard_current_branch ${dashboard_git_branch})

  if(dashboard_remote_modules)
    # ----------------- remote modules mode -------------------------
    # update sources on default branch
    if(NOT dashboard_no_update)
      set_git_update_command(${dashboard_current_branch})
      execute_process(COMMAND ${CTEST_GIT_UPDATE_CUSTOM}
                      WORKING_DIRECTORY ${dashboard_update_dir})
    endif()
    # copy incubation remote modules
    file(GLOB _incubated_files "${CTEST_SCRIPT_DIRECTORY}/../moduleIncubation/*.remote.cmake")
    foreach(_i_file ${_incubated_files})
      file(COPY ${_i_file} DESTINATION ${dashboard_update_dir}/Modules/Remote)
    endforeach()
    # call a configure with all remotes enabled
    get_module_enable_cache(remotes_list_all all_remote_cache)
    set(original_dashboard_cache ${dashboard_cache})
    set(dashboard_cache "${original_dashboard_cache}
      ${all_remote_cache}")
    ctest_start(${dashboard_model} TRACK ${CTEST_DASHBOARD_TRACK})
    write_cache()
    ctest_configure()
    # disable update
    set(dashboard_no_update 1)

    # Loop over remote modules
    foreach(mod ${remotes_list_all})
      set(_enabled_remote ${mod})
      set(_disabled_remotes ${remotes_list_all})
      list(REMOVE_ITEM _disabled_remotes ${mod})
      set(_current_remote_cache)
      get_module_enable_cache(_enabled_remote _current_remote_cache)
      get_module_disable_cache(_disabled_remotes _current_remote_cache)
      set(dashboard_cache "${original_dashboard_cache}
        ${_current_remote_cache}")
      set(CTEST_BUILD_NAME "${mod}-${ORIGINAL_CTEST_BUILD_NAME}")
      message("Run dashboard for module ${mod}")
      run_dashboard()
    endforeach()
  else()
    # ------------------- Standard mode ---------------------------
    # Run the main dashboard macro
    run_dashboard()

    # test additional feature branches
    if(number_additional_branches GREATER 0)
      set(CTEST_DASHBOARD_TRACK FeatureBranches)
      # no install for additional branches
      set(dashboard_no_install 1)
      foreach(branch ${additional_branches})
        set(dashboard_current_branch ${branch})
        set(CTEST_BUILD_NAME  ${branch}-${ORIGINAL_CTEST_BUILD_NAME})
        # clean testing directoy and lib directory
        #building feature branches in the same directory can lead to multiple versions of OTB libraries in ${CTEST_BINARY_DIRECTORY}/lib/
        #remove lib directories to avoid segfault (trigger re-linking for otb libraries)
        clean_directories(${CTEST_BINARY_DIRECTORY}/Testing/Temporary ${CTEST_BINARY_DIRECTORY}/lib)
        
        message("Run dashboard for ${branch}")
        run_dashboard()
      endforeach()
      set(CTEST_DASHBOARD_TRACK ${ORIGINAL_CTEST_DASHBOARD_TRACK})
      set(CTEST_BUILD_NAME ${ORIGINAL_CTEST_BUILD_NAME})
      set(dashboard_no_install 0)
      # update sources back to their original state
      set_git_update_command(${dashboard_git_branch})
      ctest_update(SOURCE ${dashboard_update_dir} RETURN_VALUE count)
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

ctest_sleep(5)
#~ if(DEFINED dashboard_module AND DEFINED dashboard_module_url)
  #~ file(REMOVE_RECURSE "${dashboard_update_dir}/Modules/Remote/${dashboard_module}")
#~ endif()
