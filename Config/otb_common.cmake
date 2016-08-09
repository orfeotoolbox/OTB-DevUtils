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
#   dashboard_build_command   = Executable to call in CTEST_BUILD_COMMAND
#   dashboard_build_target    = Default target to build (default is 'install',
#                               unless dashboard_no_install is true)
#   CTEST_BUILD_COMMAND       = Build command given to ctest (default is
#                               $dashboard_build_command $dashboard_build_target)
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
#   dashboard_module          = Name of the remote module to enable
#                               (incompatible with SuperBuild and additional
#                               feature branches)
#   dashboard_module_url      = URL of the remote module to enable
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

if(NOT CTEST_BUILD_FLAGS)
  set(CTEST_BUILD_FLAGS "-j4 -k" )
endif()

if(NOT CTEST_TEST_ARGS)
  set(CTEST_TEST_ARGS PARALLEL_LEVEL 3)
endif()

if(NOT CTEST_CMAKE_GENERATOR)
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
endif()


# Create build command
if(NOT DEFINED CTEST_BUILD_COMMAND)
  if(DEFINED dashboard_build_command)
    if(DEFINED dashboard_build_target)
      # use custom target
      set(CTEST_BUILD_COMMAND "${dashboard_build_command} ${dashboard_build_target}")
    else()
      if(NOT dashboard_no_install)
        # default target : install
        set(CTEST_BUILD_COMMAND "${dashboard_build_command} install")
      else()
        set(CTEST_BUILD_COMMAND "${dashboard_build_command}")
      endif()
    endif()
  endif()
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

if(NOT DEFINED CTEST_GIT_UPDATE_CUSTOM)
  if(EXISTS ${CTEST_SCRIPT_DIRECTORY}/git_updater.cmake)
    set(_git_updater_script ${CTEST_SCRIPT_DIRECTORY}/git_updater.cmake)
  elseif(EXISTS ${CTEST_SCRIPT_DIRECTORY}/../git_updater.cmake)
    set(_git_updater_script ${CTEST_SCRIPT_DIRECTORY}/../git_updater.cmake)
  endif()
  if(_git_updater_script)
    set(CTEST_GIT_UPDATE_CUSTOM ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=${dashboard_git_branch} -P ${_git_updater_script})
  endif()
endif()

# Select a source directory name.
if(NOT DEFINED CTEST_SOURCE_DIRECTORY)
  if(DEFINED dashboard_source_name)
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_source_name})
  else()
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/OTB)
  endif()
endif()

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

# Choose the dashboard track
if(NOT DEFINED CTEST_DASHBOARD_TRACK)
  # Guess using the dashboard model
  if("${dashboard_model}" STREQUAL "Nightly")
    # Guess using the branch name
    if("${dashboard_git_branch}" STREQUAL "master")
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
  # RemoteModules
  if(DEFINED dashboard_module)
    set(CTEST_TEST_ARGS INCLUDE_LABEL ${dashboard_module})
    set(CTEST_DASHBOARD_TRACK RemoteModules)
  endif()
  # SuperBuild
  get_filename_component(_source_directory_abspath "${CTEST_SOURCE_DIRECTORY}" ABSOLUTE)
  get_filename_component(_source_directory_filename "${_source_directory_abspath}" NAME)
  message("_source_directory_filename : ${_source_directory_filename}")
  #if("${_source_directory_filename}" STREQUAL "SuperBuild")
    # set(CTEST_DASHBOARD_TRACK SuperBuild)
  #endif()
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
${dashboard_cache_for_${dashboard_current_branch}}
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

  # Look for updates.
  ctest_update(SOURCE ${dashboard_update_dir} RETURN_VALUE count)
  set(CTEST_CHECKOUT_COMMAND) # checkout on first iteration only
  safe_message("Found ${count} changed files")

  # add specific modules (works for OTB only)
  if(DEFINED dashboard_module AND DEFINED dashboard_module_url)
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

set(dashboard_done 0)
while(NOT dashboard_done)
  if(dashboard_loop)
    set(START_TIME ${CTEST_ELAPSED_TIME})
  endif()
  set(ENV{HOME} "${dashboard_user_home}")
  set(dashboard_current_branch ${dashboard_git_branch})

  # Checkout specific data branch if any
  if(DEFINED specific_data_branch_for_${dashboard_git_branch})
    execute_process(COMMAND ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=${specific_data_branch_for_${dashboard_git_branch}} -P ${_git_updater_script}
                    WORKING_DIRECTORY ${dashboard_otb_data_root})
    message("Set data branch to ${specific_data_branch_for_${branch}}")
  endif()

  # Run the main dashboard macro
  run_dashboard()

  # reset data to Nightly branch
  if(DEFINED specific_data_branch_for_${dashboard_git_branch})
    execute_process(COMMAND ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=nightly -P ${_git_updater_script}
                    WORKING_DIRECTORY ${dashboard_otb_data_root})
    message("Reset data")
  endif()

  # test additional feature branches
  if(number_additional_branches GREATER 0)
    # save default configuration
    set(ORIGINAL_CTEST_BUILD_NAME ${CTEST_BUILD_NAME})
    set(ORIGINAL_CTEST_GIT_UPDATE_CUSTOM ${CTEST_GIT_UPDATE_CUSTOM})
    set(ORIGINAL_CTEST_DASHBOARD_TRACK ${CTEST_DASHBOARD_TRACK})
    set(CTEST_DASHBOARD_TRACK FeatureBranches)
    # no install for additional branches
    if(DEFINED CTEST_BUILD_COMMAND)
      set(ORIGINAL_CTEST_BUILD_COMMAND ${CTEST_BUILD_COMMAND})
      if(DEFINED dashboard_build_command)
        set(CTEST_BUILD_COMMAND "${dashboard_build_command}")
      #else()
      #  unset(CTEST_BUILD_COMMAND)
      endif()
    endif()
    foreach(branch ${additional_branches})
      set(dashboard_current_branch ${branch})
      set(CTEST_BUILD_NAME  ${ORIGINAL_CTEST_BUILD_NAME}-${branch})
      set(CTEST_GIT_UPDATE_CUSTOM  ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=${branch} -P ${_git_updater_script})
      file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY}/Testing/Temporary)
      file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/Testing/Temporary)
      # Checkout specific data branch if any
      if(DEFINED specific_data_branch_for_${branch})
        execute_process(COMMAND ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=${specific_data_branch_for_${branch}} -P ${_git_updater_script}
                        WORKING_DIRECTORY ${dashboard_otb_data_root})
        message("Set data branch to ${specific_data_branch_for_${branch}}")
      endif()
      message("Run dashboard for ${branch}")
      run_dashboard()
      # reset data to Nightly branch
      if(DEFINED specific_data_branch_for_${branch})
        execute_process(COMMAND ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=nightly -P ${_git_updater_script}
                        WORKING_DIRECTORY ${dashboard_otb_data_root})
        message("Reset data")
      endif()
    endforeach()
    set(CTEST_DASHBOARD_TRACK ${ORIGINAL_CTEST_DASHBOARD_TRACK})
    set(CTEST_BUILD_NAME ${ORIGINAL_CTEST_BUILD_NAME})
    set(CTEST_GIT_UPDATE_CUSTOM ${ORIGINAL_CTEST_GIT_UPDATE_CUSTOM})
    if(DEFINED ORIGINAL_CTEST_BUILD_COMMAND)
      set(CTEST_BUILD_COMMAND ${ORIGINAL_CTEST_BUILD_COMMAND})
    endif()
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
