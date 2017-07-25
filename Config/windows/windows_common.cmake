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
#   CTEST_INSTALL_DIRECTORY    = Path to install directory (default :
#                               $CTEST_DASHBOARD_ROOT/install_
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
#   dashboard_otb_branch      = Git branch to test (default is 'nightly' when
#                               dashboard model is Nightly, 'develop' otherwise)
#   dashboard_git_features_list = Path to a file containing additional feature
#                               branches to build & test. (incompatible with
#                               SuperBuild & RemoteModules)
#   CTEST_GIT_COMMAND         = Git executable
#   CTEST_GIT_UPDATE_CUSTOM   = Custom Git update command to replace 'git pull'
#                               (default is to use a home-made updater script
#                               git_updater.cmake, which does more cleaning)
#   dashboard_remote_module   = Name of the remote module to enable
#                               (incompatible with SuperBuild and additional
#                               feature branches)
#  dashboard_remote_module_url      = URL of the remote module to enable
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

# Avoid non-ascii characters in tool output.
set(ENV{LC_ALL} C)

# Custom function to remove a folder (divide & conquer ...)
function(remove_folder_recurse dir)
  file(GLOB content "${dir}/*")
  foreach(item ${content})
    if(IS_DIRECTORY ${item})
      execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${item}
	RESULT_VARIABLE ret)
      if(ret)
	remove_folder_recurse(${item})
      endif()
    else()
      execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${item})
    endif()
  endforeach()
  execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${dir})
endfunction(remove_folder_recurse)

# Set CTEST_DASHBOARD_ROOT if not defined
if(NOT DEFINED CTEST_DASHBOARD_ROOT)
  if(WIN32)
    set(CTEST_DASHBOARD_ROOT "C:/dashboard")
  else()
    set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
  endif()
else()
  file(TO_CMAKE_PATH "${CTEST_DASHBOARD_ROOT}" CTEST_DASHBOARD_ROOT)
endif()

if(NOT DEFINED CTEST_CONFIGURATION_TYPE)
  set(CTEST_CONFIGURATION_TYPE ${CTEST_BUILD_CONFIGURATION})
endif()

if(DEFINED ENV{COMPILER_ARCH})
  set(COMPILER_ARCH "$ENV{COMPILER_ARCH}")
else()
  if(UNIX)
    execute_process(COMMAND uname -m OUTPUT_VARIABLE arch_ov
      RESULT_VARIABLE COMPILER_ARCH)
  endif()
endif()

if(NOT COMPILER_ARCH)
  message(FATAL_ERROR "No COMPILER_ARCH set. cannot continue.")
endif()

set(SUPERBUILD_BINARY_DIR   ${CTEST_DASHBOARD_ROOT}/otb/superbuild_${COMPILER_ARCH})

set(SUPERBUILD_INSTALL_DIR  ${CTEST_DASHBOARD_ROOT}/otb/install_sb_${COMPILER_ARCH})

#######################################################################################
#######################################################################################
# uncomment SET command belows to use another source, build, install, xdk directories 
# set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/src)
# set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/fbuild_${COMPILER_ARCH})
# set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/finstall_${COMPILER_ARCH})
# set(XDK_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/otb/finstall_${COMPILER_ARCH})
#
# OPTIONAL: only for package_only build
#set(SUPERBUILD_BINARY_DIR   ${CTEST_DASHBOARD_ROOT}/otb/fbuild_${COMPILER_ARCH})
#set(SUPERBUILD_INSTALL_DIR  ${CTEST_DASHBOARD_ROOT}/otb/finstall_${COMPILER_ARCH})
#######################################################################################
#######################################################################################

#uncomment below line to have a superbuild rebuild only OTB.
#setting this variable to TRUE will uninstall OTB from install tree
#and rebuild it.
#TODO: check output of ctest_update and set this variable if there
#are any changes to SuperBuild/CMake/External_*.cmake
#~ set(SUPERBUILD_REBUILD_OTB_ONLY TRUE)





# Select the model (Nightly, Experimental, Continuous).
if(NOT DEFINED dashboard_model)
  set(dashboard_model Nightly)
endif()
if(NOT "${dashboard_model}" MATCHES "^(Nightly|Experimental|Continuous)$")
  message(FATAL_ERROR "dashboard_model must be Nightly, Experimental, or Continuous")
endif()

if(DEFINED ENV{OTBNAS_PACKAGES_DIR})
  set(OTBNAS_PACKAGES_DIR "$ENV{OTBNAS_PACKAGES_DIR}")
endif()


# Look for a GIT command-line client.

find_program(CTEST_GIT_COMMAND NAMES git git.cmd)

if(NOT CTEST_GIT_COMMAND)
  message(FATAL_ERROR "No Git Found.")
endif()

# Default to a Release build.
if(NOT DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION Release)
endif()

if(NOT DEFINED OTB_DATA_ROOT)
  if(DEFINED ENV{OTB_DATA_ROOT})
    file(TO_CMAKE_PATH "$ENV{OTB_DATA_ROOT}" OTB_DATA_ROOT)
  else()
    set(dashboard_no_test 1)
    message(WARNING "No OTB_DATA_ROOT set. cannot run tests. dashboard_no_test is set to 1")
  endif()
endif()

if(DEFINED ENV{dashboard_otb_branch})
  set(dashboard_otb_branch "$ENV{dashboard_otb_branch}")
endif()

if(DEFINED ENV{dashboard_data_branch})
  set(dashboard_data_branch "$ENV{dashboard_data_branch}")
endif()

if(DEFINED ENV{otb_data_use_largeinput})
  set(otb_data_use_largeinput "$ENV{otb_data_use_largeinput}")
endif()

if(DEFINED ENV{dashboard_remote_module})
  set(dashboard_remote_module "$ENV{dashboard_remote_module}")
endif()

if(DEFINED ENV{DASHBOARD_SUPERBUILD})
  set(DASHBOARD_SUPERBUILD "$ENV{DASHBOARD_SUPERBUILD}")
endif()

if(DEFINED ENV{DASHBOARD_PACKAGE_OTB})
  set(DASHBOARD_PACKAGE_OTB $ENV{DASHBOARD_PACKAGE_OTB})
endif()

if(DEFINED ENV{DASHBOARD_PACKAGE_XDK})
  set(DASHBOARD_PACKAGE_XDK $ENV{DASHBOARD_PACKAGE_XDK})
endif()

set(DASHBOARD_PACKAGE_ONLY FALSE)
if(DASHBOARD_PACKAGE_XDK OR DASHBOARD_PACKAGE_OTB)
  set(DASHBOARD_PACKAGE_ONLY TRUE)
endif()
#end of check env

set(CONFIGURE_OPTIONS)
if(DASHBOARD_SUPERBUILD AND WITH_CONTRIB)
  set(CONFIGURE_OPTIONS "-DBUILD_TESTING:BOOL=ON")
  foreach(remote_module "SertitObject" "Mosaic" "otbGRM" "OTBFFSforGMM")
    list(APPEND CONFIGURE_OPTIONS "-DModule_${remote_module}:BOOL=ON")
  endforeach()
endif()

if(DEFINED ENV{CTEST_SOURCE_DIRECTORY})
  file(TO_CMAKE_PATH "$ENV{CTEST_SOURCE_DIRECTORY}" CTEST_SOURCE_DIRECTORY)
endif()

# Set CTEST_SOURCE_DIRECTORY if not defined
if(NOT DEFINED CTEST_SOURCE_DIRECTORY)
  if(DEFINED dashboard_source_name)
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_source_name})
  else()
    set(CTEST_SOURCE_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/src)
  endif()
endif()

#do not move below code. we must set 
# Set source directory to update right after we decide on CTEST_SOURCE_DIRECTORY
if(NOT DEFINED dashboard_update_dir)
  set(dashboard_update_dir ${CTEST_SOURCE_DIRECTORY})
endif()

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# CTEST_SOURCE_DIRECTORY is changed depending on the condition
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
if(DASHBOARD_SUPERBUILD)
  set(CTEST_SOURCE_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/SuperBuild)
elseif(DASHBOARD_PACKAGE_ONLY) 
  set(CTEST_SOURCE_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/Packaging)
endif()
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
get_filename_component(_source_directory_abspath "${CTEST_SOURCE_DIRECTORY}" ABSOLUTE)
get_filename_component(_source_directory_filename "${_source_directory_abspath}" NAME)

# DEFAULT values for CTEST_INSTALL_DIRECTORY if not defined
if(NOT DEFINED CTEST_INSTALL_DIRECTORY)
  if(DASHBOARD_SUPERBUILD)
    set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/install_sb_${COMPILER_ARCH})
    set(XDK_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/otb/install_sb_${COMPILER_ARCH})
  else()
    set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/install_${COMPILER_ARCH})
    set(XDK_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/otb/xdk/install_sb_${COMPILER_ARCH})
  endif()
endif()

if(NOT DEFINED XDK_INSTALL_DIR)
  if(DASHBOARD_SUPERBUILD)
    set(XDK_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/otb/install_sb_${COMPILER_ARCH})
  else()
    set(XDK_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/otb/xdk/install_sb_${COMPILER_ARCH})
  endif()
endif()


#reset XDK_INSTALL_DIR when building packages: OTB and XDK
#if(DASHBOARD_PACKAGE_ONLY)
#set(XDK_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/otb/install_sb_${COMPILER_ARCH})
#endif()

# DEFAULT values for CTEST_BINARY_DIRECTORY if not defined
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  if(DEFINED dashboard_binary_name)
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  else()
    if(DASHBOARD_SUPERBUILD)
      set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/superbuild_${COMPILER_ARCH})
      set(OTB_BUILD_BIN_DIR  ${CTEST_BINARY_DIRECTORY}/OTB/build/bin)
    else()
      set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/build_${COMPILER_ARCH})
      set(OTB_BUILD_BIN_DIR  ${CTEST_BINARY_DIRECTORY}/bin)
    endif()
  endif()
endif()

file(TO_NATIVE_PATH "${XDK_INSTALL_DIR}" XDK_INSTALL_DIR_NATIVE)

file(TO_NATIVE_PATH "${OTB_BUILD_BIN_DIR}" OTB_BUILD_BIN_DIR_NATIVE)


function(print_summary)
# Print summary information.
foreach(v
    CTEST_SITE
    CTEST_BUILD_NAME
    CTEST_SOURCE_DIRECTORY
    CTEST_BINARY_DIRECTORY
    CTEST_INSTALL_DIRECTORY
    CTEST_CMAKE_GENERATOR
    CTEST_BUILD_CONFIGURATION
    CTEST_GIT_COMMAND
    CTEST_GIT_UPDATE_OPTIONS
    CTEST_GIT_UPDATE_CUSTOM
    CTEST_CHECKOUT_COMMAND
    CTEST_USE_LAUNCHERS
    CTEST_DASHBOARD_TRACK
    CMAKE_MAKE_PROGRAM
    DASHBOARD_SUPERBUILD
    SUPERBUILD_REBUILD_OTB_ONLY
    DASHBOARD_PACKAGE_ONLY
    DOWNLOAD_LOCATION
    XDK_INSTALL_DIR
    CTEST_DROP_LOCATION
    dashboard_otb_branch
    dashboard_data_branch
    dashboard_update_dir
    OTBNAS_PACKAGES_DIR
    WITH_CONTRIB
    )
  set(vars "${vars}  ${v}=[${${v}}]\n")
endforeach(v)
message("ENV{PATH}=$ENV{PATH}")
message("Dashboard script configuration:\n${vars}\n")

endfunction() #print_summary

#only needed if generator is Visual studio
if(CTEST_CMAKE_GENERATOR MATCHES "Visual Studio")
  set(ENV{PATH} "$ENV{PATH};${OTB_BUILD_BIN_DIR_NATIVE}\\${CTEST_BUILD_CONFIGURATION}" )
else()
  set(ENV{PATH} "$ENV{PATH};${OTB_BUILD_BIN_DIR_NATIVE}" )
endif()

set(ENV{PATH} "$ENV{PATH};${XDK_INSTALL_DIR_NATIVE}\\bin" )
set(ENV{PATH} "$ENV{PATH};${XDK_INSTALL_DIR_NATIVE}\\lib" )

set(ENV{CMAKE_PREFIX_PATH} "${XDK_INSTALL_DIR}" )

set(ENV{GDAL_DATA} "${XDK_INSTALL_DIR_NATIVE}\\share\\gdal" )
set(ENV{GEOTIFF_CSV} "${XDK_INSTALL_DIR_NATIVE}\\share\\epsg_csv" )
set(ENV{PROJ_LIB} "${XDK_INSTALL_DIR_NATIVE}\\share" )

set(CTEST_ENVIRONMENT 
  "PATH=$ENV{PATH}
GDAL_DATA=$ENV{GDAL_DATA}
GEOTIFF_CSV=$ENV{GEOTIFF_CSV}
PROJ_LIB=$ENV{PROJ_LIB}
")

if(otb_data_use_largeinput)
  if(DEFINED ENV{OTB_DATA_LARGEINPUT_ROOT})
    file(TO_CMAKE_PATH "$ENV{OTB_DATA_LARGEINPUT_ROOT}" OTB_DATA_LARGEINPUT_ROOT)
  else()
    set(otb_data_use_largeinput FALSE)
    message("No OTB_DATA_LARGEINPUT_ROOT set. deactivating otb_data_use_largeinput.")
  endif()
endif()

#defaults
if(NOT DEFINED dashboard_otb_branch)
  if("${dashboard_model}" STREQUAL "Nightly")
    set(dashboard_otb_branch nightly)
  else()
    set(dashboard_otb_branch develop)
  endif()
endif() #if(NOT DEFINED dashboard_otb_branch)

string(STRIP "${dashboard_otb_branch}" dashboard_otb_branch)

if(NOT DEFINED dashboard_data_branch)
  set(dashboard_data_branch nightly)
endif()

if(dashboard_build_target)
  string(REPLACE "-all" "" dashboard_label ${dashboard_build_target})
endif()

set(SHELL_COMMAND)
if(WIN32)
  # Earlier we were using cmd.exe for shell_command
  # clink adds readline features to cmd such as tab completion for file and folders,
  # history of commands are saved after closing each cmd.exe.

  # This is a nice feature to have when we drop to shell on windows
  # On raoul and megatron, clink is installed clink.bat is found in PATH.
  # tab completion, loop through history etc.. are very important and useful
  # when debugging builds. after all, this "DROP_SHELL" option is specifically
  # used in debugging
  # clink.bat is a wrapper script with spawn a child cmd.exe with clink injected
  # see source of clink.bat for more information
  # CLINK is not BASH for WINDOWS!
  set(SHELL_COMMAND clink.bat)
else()
  find_program(SHELL_COMMAND NAMES bash)
endif()

if(DROP_SHELL)
  if(NOT SHELL_COMMAND)
    message(FATAL_ERROR "SHELL_COMMAND not found")
    return()
  endif()
    
    print_summary()
  execute_process(COMMAND 
    ${CTEST_GIT_COMMAND} checkout ${dashboard_otb_branch}
    WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}
    RESULT_VARIABLE checkout_rv
    ERROR_VARIABLE checkout_ev
  )
  if(checkout_rv)
    message(FATAL_ERROR 
    "git checkout failed with ${checkout_rv}: error: ${checkout_ev}")
    return()
  endif()
  execute_process(COMMAND  
    ${SHELL_COMMAND} 
    WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY}
  )

 return()
endif()

# Check build name
if(DEFINED ENV{CTEST_BUILD_NAME_PREFIX})
  set(CTEST_BUILD_NAME_PREFIX "$ENV{CTEST_BUILD_NAME_PREFIX}")
endif()

if(NOT CTEST_BUILD_NAME)
  if(CTEST_BUILD_NAME_PREFIX)
    set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME_PREFIX}-${COMPILER_ARCH}-${CTEST_BUILD_CONFIGURATION}")
  else()  
    set(CTEST_BUILD_NAME "${CMAKE_SYSTEM_NAME}-${COMPILER_ARCH}-${CTEST_BUILD_CONFIGURATION}")
  endif()
endif()

if(DASHBOARD_SUPERBUILD)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-SuperBuild")
endif()

if(DASHBOARD_PACKAGE_ONLY)
  set(CTEST_BUILD_NAME "Package-${CTEST_BUILD_NAME}")
endif()

if(dashboard_label)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-${dashboard_label}")
endif()

if(NOT "${dashboard_otb_branch}" MATCHES "^(nightly|develop|release.([0-9]+)\\.([0-9]+))$")
  if(NOT (DASHBOARD_SUPERBUILD OR DASHBOARD_PACKAGE_ONLY))
    set(CTEST_BUILD_NAME "${dashboard_otb_branch}-${CTEST_BUILD_NAME}")
  endif()
endif()

# Append release-X.Y to CTEST_BUILD_NAME when building release branch for OTB
if("${dashboard_otb_branch}" MATCHES "^(release.([0-9]+)\\.([0-9]+))$")
  if(NOT (DASHBOARD_SUPERBUILD OR DASHBOARD_PACKAGE_ONLY))
    set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-${dashboard_otb_branch}")
  endif()
endif()

if(dashboard_remote_module)
  set(CTEST_BUILD_NAME "${dashboard_remote_module}-${CTEST_BUILD_NAME}")
endif()

if(WITH_CONTRIB)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-contrib")
endif()

if(DEFINED ENV{CTEST_SITE})
  set(CTEST_SITE "$ENV{CTEST_SITE}")
endif()

if(NOT CTEST_SITE)
  if(DEFINED ENV{COMPUTERNAME})
    message("CTEST_SITE is emtpy. setting this to value of SITE_NAME which is '$ENV{COMPUTERNAME}'")
    set(CTEST_SITE "$ENV{COMPUTERNAME}")
    set(CTEST_DASHBOARD_TRACK Experimental)
  else()
    message("CTEST_SITE and ENV{COMPUTERNAME} are emtpy. Cannot continue")
  endif()
endif()

if(NOT DEFINED CTEST_CMAKE_GENERATOR)
  if(DEFINED ENV{CTEST_CMAKE_GENERATOR})
    set(CTEST_CMAKE_GENERATOR "$ENV{CTEST_CMAKE_GENERATOR}")
  else() #if(DEFINED ENV{CTEST_CMAKE_GENERATOR})
    if(WIN32)
      if(DASHBOARD_SUPERBUILD OR DASHBOARD_PACKAGE_ONLY)
        set(CTEST_CMAKE_GENERATOR "NMake Makefiles JOM")
      else()
        set(CTEST_CMAKE_GENERATOR "Ninja")
      endif()
    else(WIN32)
      set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
    endif(WIN32)
  endif() #if(DEFINED ENV{CTEST_CMAKE_GENERATOR})
endif() #if(NOT DEFINED CTEST_CMAKE_GENERATOR)

if(DASHBOARD_SUPERBUILD)
  if(DEFINED ENV{DOWNLOAD_LOCATION})
    set(DOWNLOAD_LOCATION "$ENV{DOWNLOAD_LOCATION}")
  endif()
  
  if(DOWNLOAD_LOCATION)
    file(TO_CMAKE_PATH "${DOWNLOAD_LOCATION}" DOWNLOAD_LOCATION)
  endif()
endif()

# Check for required variables.
foreach(req
    CTEST_CMAKE_GENERATOR
    CTEST_SITE
    CTEST_BUILD_NAME
    )
  if(NOT DEFINED ${req})
    message(FATAL_ERROR "you must ${req} before calling otb_common.cmake")
  endif()
endforeach(req)


#if(NOT dashboard_build_target)
#	set(dashboard_build_target install)
#endif()
#for superbuild
#set(dashboard_build_target PACKAGE-OTB)

# Create build command
# if(NOT DEFINED CTEST_BUILD_COMMAND)
# if(DEFINED dashboard_build_command)
# if(DEFINED dashboard_build_target)
#use custom target
# set(CTEST_BUILD_COMMAND "${dashboard_build_command} ${dashboard_build_target}")
# else()
# if(NOT dashboard_no_install)
#       default target : install
# set(CTEST_BUILD_COMMAND "${dashboard_build_command} install")
# else()
# set(CTEST_BUILD_COMMAND "${dashboard_build_command}")
# endif()
# endif()
# endif()
# endif()

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
if(NOT DEFINED dashboard_git_url)
  set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
endif()

if(NOT DEFINED dashboard_git_crlf)
  if(UNIX)
    set(dashboard_git_crlf false)
  else(UNIX)
    set(dashboard_git_crlf true)
  endif(UNIX)
endif()

if(EXISTS ${CTEST_SCRIPT_DIRECTORY}/git_updater.cmake)
  set(_git_updater_script ${CTEST_SCRIPT_DIRECTORY}/git_updater.cmake)
elseif(EXISTS ${CTEST_SCRIPT_DIRECTORY}/../git_updater.cmake)
  set(_git_updater_script ${CTEST_SCRIPT_DIRECTORY}/../git_updater.cmake)
elseif(EXISTS ${CTEST_SCRIPT_DIRECTORY}/../../git_updater.cmake)
  set(_git_updater_script ${CTEST_SCRIPT_DIRECTORY}/../../git_updater.cmake)
endif()

if(NOT DEFINED CTEST_GIT_UPDATE_CUSTOM)
  set(CTEST_GIT_UPDATE_CUSTOM ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=${dashboard_otb_branch} -P ${_git_updater_script})
endif()

# Choose the dashboard track
if(NOT DEFINED CTEST_DASHBOARD_TRACK)
  # Guess using the dashboard model
  if("${dashboard_model}" STREQUAL "Nightly")
    # Guess using the branch name (except with superbuild)
    if("${_source_directory_filename}" MATCHES "^SuperBuild$")
      set(CTEST_DASHBOARD_TRACK SuperBuild)
    elseif("${_source_directory_filename}" MATCHES "^Packaging$")
      set(CTEST_DASHBOARD_TRACK Packaging)
    elseif("${dashboard_otb_branch}" STREQUAL "master")
      set(CTEST_DASHBOARD_TRACK Nightly)
    elseif("${dashboard_otb_branch}" MATCHES "^(nightly|develop)$")
      set(CTEST_DASHBOARD_TRACK Develop)
    elseif("${dashboard_otb_branch}" MATCHES "^release-[0-9]+\\.[0-9]+\$")
      set(CTEST_DASHBOARD_TRACK LatestRelease)
    else()
      set(CTEST_DASHBOARD_TRACK FeatureBranches)
    endif()
    
  elseif("${dashboard_model}" STREQUAL "Continuous")
    set(CTEST_DASHBOARD_TRACK Continuous)
  elseif("${dashboard_model}" STREQUAL "Experimental")
    set(CTEST_DASHBOARD_TRACK Experimental)
  endif()
endif()

# RemoteModules
if(DEFINED dashboard_remote_module)
  set(CTEST_TEST_ARGS INCLUDE_LABEL ${dashboard_remote_module})
  set(CTEST_DASHBOARD_TRACK RemoteModules)
endif()

if(dashboard_label)
  set(CTEST_TEST_ARGS INCLUDE_LABEL ${dashboard_label})
  set(CTEST_DASHBOARD_TRACK Experimental)
endif()

if(DASHBOARD_SUPERBUILD)
  if(WITH_CONTRIB)
    set(CTEST_TEST_ARGS BUILD ${CTEST_BINARY_DIRECTORY})
  else()
    set(CTEST_TEST_ARGS BUILD ${CTEST_BINARY_DIRECTORY}/OTB/build)
  endif()
endif()

#-----------------------------------------------------------------------------

# Send the main script as a note.
list(APPEND CTEST_NOTES_FILES
  "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
  "${CMAKE_CURRENT_LIST_FILE}"
  )


if(DASHBOARD_SUPERBUILD)
  set(CTEST_NOTES_FILES
    "${CTEST_BINARY_DIRECTORY}/OTB/src/OTB-stamp/OTB-configure-out.log"
    "${CTEST_BINARY_DIRECTORY}/OTB/src/OTB-stamp/OTB-configure-err.log"    
    )
endif()


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Creation of DEFAULT_CMAKE_CACHE starts here. That means all 
# common variables are set.
set(DEFAULT_CMAKE_CACHE	"BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}
  "
  )

if(DASHBOARD_SUPERBUILD)
  if(DOWNLOAD_LOCATION)
    set(DEFAULT_CMAKE_CACHE "${DEFAULT_CMAKE_CACHE}
DOWNLOAD_LOCATION:PATH=${DOWNLOAD_LOCATION}")
  endif()

else()

  if(XDK_INSTALL_DIR)
    set(DEFAULT_CMAKE_CACHE "${DEFAULT_CMAKE_CACHE}
QT_BINARY_DIR:PATH=${XDK_INSTALL_DIR}/bin
QT_INSTALL_TRANSLATIONS:PATH=${XDK_INSTALL_DIR}/translations
QT_MOC_EXECUTABLE:FILEPATH=${XDK_INSTALL_DIR}/bin/moc
QT_UIC_EXECUTABLE:FILEPATH=${XDK_INSTALL_DIR}/bin/uic
QT_RCC_EXECUTABLE:FILEPATH=${XDK_INSTALL_DIR}/bin/rcc
QT_INSTALL_PLUGINS:PATH=${XDK_INSTALL_DIR}/plugins
QT_INSTALL_HEADERS:PATH=${XDK_INSTALL_DIR}/include
QT_MKSPECS_DIR:PATH=${XDK_INSTALL_DIR}/mkspecs  
QT_QTCORE_LIBRARY_RELEASE:FILEPATH=${XDK_INSTALL_DIR}/lib/QtCore4.lib
QT_QTCORE_INCLUDE_DIR:PATH=${XDK_INSTALL_DIR}/include/QtCore
QT_HEADERS_DIR:PATH=${XDK_INSTALL_DIR}/include/
    "
      )
  endif()
endif()

if(NOT DEFINED dashboard_build_shared)
  set(dashboard_build_shared ON)
endif()

set(DEFAULT_CMAKE_CACHE 
  "
${DEFAULT_CMAKE_CACHE}
BUILD_SHARED_LIBS:BOOL=${dashboard_build_shared}
"
  )

if(WIN32)
  set(DEFAULT_CMAKE_CACHE  "${DEFAULT_CMAKE_CACHE}
CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON
  "
    )
endif()

if(otb_data_use_largeinput)
  set(DEFAULT_CMAKE_CACHE 
    "
${DEFAULT_CMAKE_CACHE}
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=${OTB_DATA_LARGEINPUT_ROOT}
"
    )
endif()

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE:: CTEST_BUILD_COMMAND will skip ctest_build( ) arguments.
# It doesn't matter you have dashboard_build_target set
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
if(DASHBOARD_PACKAGE_ONLY)
  if(DASHBOARD_PACKAGE_XDK)
    set(CTEST_BUILD_COMMAND "jom PACKAGE-XDK" )
  else()
    set(CTEST_BUILD_COMMAND "jom PACKAGE-OTB" )
  endif()
endif()

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE:: RESET whatever 'dashboard_cache' set and use the below 
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
if(dashboard_remote_module)
  set(dashboard_cache
    "
OTB_BUILD_DEFAULT_MODULES:BOOL=OFF
Module_${dashboard_remote_module}:BOOL=ON
"
    )
endif()


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE:: RESET whatever 'dashboard_cache' set and use the below 
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
if(DASHBOARD_PACKAGE_ONLY)
  set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}
BUILD_TESTING:BOOL=ON
SUPERBUILD_BINARY_DIR:PATH=${SUPERBUILD_BINARY_DIR}
SUPERBUILD_INSTALL_DIR:PATH=${SUPERBUILD_INSTALL_DIR}
OTB_WRAP_PYTHON:BOOL=ON
${dashboard_cache_packaging}
${dashboard_cache_for_${dashboard_otb_branch}}
GENERATE_PACKAGE:BOOL=${DASHBOARD_PACKAGE_OTB}
GENERATE_XDK:BOOL=${DASHBOARD_PACKAGE_XDK}
")

  if(WITH_CONTRIB)
    set(dashboard_cache "${dashboard_cache} \n NAME_SUFFIX:STRING=-contrib")
  endif()

endif(DASHBOARD_PACKAGE_ONLY)

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
            COMMAND \"${CTEST_GIT_COMMAND}\" clone  
			--depth=1  
			--branch=${dashboard_otb_branch} 
			\"${dashboard_git_url}\" 
			\"${dashboard_update_dir}\" )   ")

  set(CTEST_CHECKOUT_COMMAND "\"${CMAKE_COMMAND}\" -P \"${ctest_checkout_script}\"")

endif()

# CTest delayed initialization is broken, so we put the
# CTestConfig.cmake info here.
set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "https")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)


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
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
${cache_make_program}
${dashboard_cache}
${DEFAULT_CMAKE_CACHE}
${dashboard_cache_for_${dashboard_otb_branch}}
")
endmacro(write_cache)

if(DASHBOARD_SUPERBUILD)
  if(SUPERBUILD_REBUILD_OTB_ONLY)
    set(dashboard_no_clean 1)
    message("SUPERBUILD_REBUILD_OTB_ONLY is set. \n ${CTEST_BINARY_DIRECTORY} will not be cleared. [ dashboard_no_clean=${dashboard_no_clean} ]")
    execute_process(
      COMMAND ${CMAKE_COMMAND} 
      --build ${CTEST_BINARY_DIRECTORY}/OTB/build
      --target uninstall
      WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY}/OTB/build
      RESULT_VARIABLE uninstall_otb_rv
      )
    
    if(uninstall_otb_rv)
      message("Uninstall OTB from ${CTEST_INSTALL_DIRECTORY} - FAILED")
    else()
      message("Uninstall OTB from ${CTEST_INSTALL_DIRECTORY} - OK")
    endif()
    
    # execute_process(
    # COMMAND ${CMAKE_COMMAND} 
    # --build ${CTEST_BINARY_DIRECTORY}
    # --target OTB_DEPENDS
    # WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY}
    # RESULT_VARIABLE otb_depends_rv
    # )
    # if(otb_depends_rv)
    # message("Build target OTB_DEPENDS - FAILED")
    # else()
    # message("Build target OTB_DEPENDS - OK")
    # endif()
    
    if(WITH_CONTRIB)
      get_filename_component(CTEST_SOURCE_DIRECTORY ${CTEST_SOURCE_DIRECTORY} PATH)
      set(CTEST_BINARY_DIRECTORY ${CTEST_BINARY_DIRECTORY}/OTB/build)
      message("changing source and build directory [WITH_CONTRIB=1]")
      set(dashboard_build_target install)
    else()
      execute_process(COMMAND ${CMAKE_COMMAND} 
        -E remove_directory ${CTEST_BINARY_DIRECTORY}/OTB
        WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY}
        RESULT_VARIABLE clear_otb_build_dir_rv)
      
      if(clear_otb_build_dir_rv)
        message("remove OTB directory from ${CTEST_BINARY_DIRECTORY} - FAILED")
      else()
        message("remove OTB directory from ${CTEST_BINARY_DIRECTORY} - OK")
      endif()  

    endif() #  if(NOT WITH_CONTRIB)
    
  endif() #if(SUPERBUILD_REBUILD_OTB_ONLY)
endif() #if(DASHBOARD_SUPERBUILD)

# Start with a fresh build tree.
if(NOT dashboard_no_clean)
  if(EXISTS "${CTEST_BINARY_DIRECTORY}")
    message("Clearing build tree: ${CTEST_BINARY_DIRECTORY}")
    remove_folder_recurse(${CTEST_BINARY_DIRECTORY})
  endif()
  
  if(EXISTS "${CTEST_INSTALL_DIRECTORY}")
    message("Clearing install tree: ${CTEST_INSTALL_DIRECTORY}")
    remove_folder_recurse(${CTEST_INSTALL_DIRECTORY})
  endif()
endif()

#create ctestconfig.cmake if not exists in source and binary directory
if(NOT EXISTS "${CTEST_BINARY_DIRECTORY}/CTestConfig.cmake" AND 
    NOT EXISTS "${CTEST_SOURCE_DIRECTORY}/CTestConfig.cmake" 
    )
  message("CTestConfig.cmake does not exists in CTEST_BINARY_DIRECTORY and CTEST_SOURCE_DIRECTORY. we create one now in CTEST_BINARY_DIRECTORY")
  file(WRITE "${CTEST_BINARY_DIRECTORY}/CTestConfig.cmake"
    "
set(CTEST_PROJECT_NAME \"OTB\")
set(CTEST_NIGHTLY_START_TIME \"20:00:00 CEST\")
set(CTEST_DROP_METHOD \"https\")
set(CTEST_DROP_SITE \"dash.orfeo-toolbox.org\")
set(CTEST_DROP_LOCATION \"/submit.php?project=OTB\")
set(CTEST_DROP_SITE_CDASH TRUE)
"
    )
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

if(OTB_DATA_ROOT)
  execute_process(COMMAND ${CMAKE_COMMAND} 
    -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} 
    -D TESTED_BRANCH:STRING=${dashboard_data_branch} 
    -P ${_git_updater_script}
    WORKING_DIRECTORY ${OTB_DATA_ROOT})
endif()  

if(COMMAND dashboard_hook_start)
  dashboard_hook_start()
endif()


print_summary()

if(COMMAND dashboard_hook_init)
  dashboard_hook_init()
endif()

ctest_start(${dashboard_model} TRACK ${CTEST_DASHBOARD_TRACK})

# Look for updates.
if(NOT dashboard_no_update)
  ctest_update(SOURCE ${dashboard_update_dir} RETURN_VALUE count)
  set(CTEST_CHECKOUT_COMMAND) # checkout on first iteration only
  message("Found ${count} changed files")
else()
  message("dashboard_no_update is set. skipping update sources")
endif()

# add specific modules (works for OTB only)
if(DEFINED dashboard_remote_module AND DEFINED dashboard_remote_module_url)
  execute_process(COMMAND "${CTEST_GIT_COMMAND}" "clone" "${dashboard_remote_module_url}"  "${dashboard_update_dir}/Modules/Remote/${dashboard_remote_module}" RESULT_VARIABLE rv)
  if(NOT rv EQUAL 0)
    message(FATAL_ERROR "Cannot checkout remote module: ${rv}")
  endif()
endif()

macro(dashboard_copy_packages)
  set(copy_packages_failed TRUE)
  file(GLOB otb_package_file "${CTEST_BINARY_DIRECTORY}/OTB*.zip")
  if(otb_package_file)
    if(EXISTS "${OTBNAS_PACKAGES_DIR}")
      get_filename_component(package_file_name ${otb_package_file} NAME)
      # copy packages to otbnas
      message("Copying '${otb_package_file}' to '${OTBNAS_PACKAGES_DIR}/${package_file_name}'")
      execute_process(
	COMMAND ${CMAKE_COMMAND} 
	-E copy
	"${otb_package_file}"
	"${OTBNAS_PACKAGES_DIR}/${package_file_name}"
	RESULT_VARIABLE copy_rv
	WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY})
      
      if(copy_rv EQUAL 0)
	set(copy_packages_failed FALSE)
      endif()
    endif() #exists OTBNAS_PACKAGES_DIR
  endif()  #otb_package_file

  if(copy_packages_failed)
    message("Cannot copy '${otb_package_file}' to '${OTBNAS_PACKAGES_DIR}/${package_file_name}'")
  else()
    message("Copied '${otb_package_file}' to '${OTBNAS_PACKAGES_DIR}/${package_file_name}'")
  endif()
endmacro(dashboard_copy_packages)


macro(dashboard_reset_sources)
  message("reset otb-data to master branch" )
  if(OTB_DATA_ROOT)
    execute_process(COMMAND ${CMAKE_COMMAND} 
      -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} 
      -D TESTED_BRANCH:STRING=master
      -P ${_git_updater_script}
      WORKING_DIRECTORY ${OTB_DATA_ROOT})
  endif()
  
  message("reset otb to develop branch" )
  execute_process(COMMAND ${CMAKE_COMMAND} 
    -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} 
    -D TESTED_BRANCH:STRING=develop
    -P ${_git_updater_script}
    WORKING_DIRECTORY ${dashboard_update_dir})
endmacro(dashboard_reset_sources)


file(GLOB remote_module_dirs "${dashboard_update_dir}/Modules/Remote/*")
foreach(remote_module_dir ${remote_module_dirs})
  
  if( EXISTS${remote_module_dir} AND IS_DIRECTORY ${remote_module_dir})
    message( "Removing ${dashboard_update_dir}/Modules/Remote/${remote_module_dir}")
    file(REMOVE_RECURSE "${dashboard_update_dir}/Modules/Remote/${dashboard_remote_module}")
  endif()
  
  
endforeach()
# special setting for ctest_submit(), issue with CA checking
set(CTEST_CURL_OPTIONS "CURLOPT_SSL_VERIFYPEER_OFF")

#if(dashboard_fresh OR NOT dashboard_continuous OR count GREATER 0)

if(NOT dashboard_no_configure)
  write_cache()
  message("Running ctest_configure() on ${CTEST_BINARY_DIRECTORY}")
  if(CONFIGURE_OPTIONS)
    ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}" OPTIONS "${CONFIGURE_OPTIONS}"	RETURN_VALUE _configure_rv)
  else()
    ctest_configure(BUILD "${CTEST_BINARY_DIRECTORY}" 	RETURN_VALUE _configure_rv)
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})

  if(NOT _configure_rv EQUAL 0)
    ctest_submit()
    return()
  endif()
endif() #NOT dashboard_no_configure

if(COMMAND dashboard_hook_build)
  dashboard_hook_build()
endif()

if(NOT dashboard_no_build)
  if(dashboard_build_target)
    message("building requested target ${dashboard_build_target} on ${CTEST_BINARY_DIRECTORY}")
    ctest_build( BUILD "${CTEST_BINARY_DIRECTORY}" 
      TARGET "${dashboard_build_target}"
      RETURN_VALUE _build_rv)
  else()
    ctest_build( BUILD "${CTEST_BINARY_DIRECTORY}" RETURN_VALUE _build_rv)
  endif()
endif() #if(NOT dashboard_no_build)


if(NOT dashboard_no_test)
  if(COMMAND dashboard_hook_test)
    dashboard_hook_test()
  endif()
  ctest_test(${CTEST_TEST_ARGS})
endif()

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

# if(NOT dashboard_no_update)
#   dashboard_reset_sources()
# endif()

if(DASHBOARD_PACKAGE_ONLY)
  dashboard_copy_packages()
endif()

#endif()

