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


# Select the model (Nightly, Experimental, Continuous).
if(NOT DEFINED dashboard_model)
  set(dashboard_model Nightly)
endif()
if(NOT "${dashboard_model}" MATCHES "^(Nightly|Experimental|Continuous)$")
  message(FATAL_ERROR "dashboard_model must be Nightly, Experimental, or Continuous")
endif()


# Look for a GIT command-line client.

find_program(CTEST_GIT_COMMAND NAMES git git.cmd)

if(NOT CTEST_GIT_COMMAND)
  message(FATAL_ERROR "No Git Found.")
endif()

if(DEFINED ENV{CTEST_BUILD_CONFIGURATION})
  set(CTEST_BUILD_CONFIGURATION "$ENV{CTEST_BUILD_CONFIGURATION}")
endif()

# Default to a Release build.
if(NOT DEFINED CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION Release)
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

if(DEFINED ENV{OTB_DATA_ROOT})
  file(TO_CMAKE_PATH "$ENV{OTB_DATA_ROOT}" OTB_DATA_ROOT)
else()
  message(FATAL_ERROR "No OTB_DATA_ROOT set. cannot continue.")
endif()


if(DEFINED ENV{XDK_INSTALL_DIR})
  file(TO_CMAKE_PATH "$ENV{XDK_INSTALL_DIR}" XDK_INSTALL_DIR)
endif()

if(DEFINED ENV{dashboard_no_clean})
  set(dashboard_no_clean "$ENV{dashboard_no_clean}")
endif()

if(DEFINED ENV{dashboard_no_update})
  set(dashboard_no_update "$ENV{dashboard_no_update}")
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
if(otb_data_use_largeinput)
	if(DEFINED ENV{OTB_DATA_LARGEINPUT_ROOT})
		file(TO_CMAKE_PATH "$ENV{OTB_DATA_LARGEINPUT_ROOT}" OTB_DATA_LARGEINPUT_ROOT)
	else()
		set(otb_data_use_largeinput FALSE)
		message(FATAL_ERROR "No OTB_DATA_LARGEINPUT_ROOT set. cannot continue.")
	endif()
endif()

#defaults

if(NOT DEFINED dashboard_otb_branch)
  if("${dashboard_model}" STREQUAL "Nightly")
    set(dashboard_otb_branch nightly)
  else()
    set(dashboard_otb_branch develop)
  endif()
endif()

string(STRIP "${dashboard_otb_branch}" dashboard_otb_branch)

if(NOT DEFINED dashboard_data_branch)
    set(dashboard_data_branch nightly)
  endif()
  
if(dashboard_build_target)
  string(REPLACE "-all" "" dashboard_label ${dashboard_build_target})
endif()

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

if(dashboard_label)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-${dashboard_label}")
  # we are sure this is an experimental build
  set(CTEST_DASHBOARD_TRACK Experimental)
endif()

if(NOT "${dashboard_otb_branch}" MATCHES "^(nightly|develop|release.([0-9]+)\\.([0-9]+))$")
  set(CTEST_BUILD_NAME "${dashboard_otb_branch}-${CTEST_BUILD_NAME}")
endif()

if(DASHBOARD_PACKAGE_ONLY)
  set(CTEST_BUILD_NAME "Package-${CTEST_BUILD_NAME}")
endif()

if(dashboard_remote_module)
  set(CTEST_BUILD_NAME "${dashboard_remote_module}-${CTEST_BUILD_NAME}")
endif()

if(DEFINED ENV{CTEST_SITE})
  set(CTEST_SITE "$ENV{CTEST_SITE}")
endif()

if(DEFINED ENV{CTEST_CMAKE_GENERATOR})
  set(CTEST_CMAKE_GENERATOR "$ENV{CTEST_CMAKE_GENERATOR}")
else()
	if(WIN32)
		if(DASHBOARD_SUPERBUILD OR DASHBOARD_PACKAGE_ONLY)
			set(CTEST_CMAKE_GENERATOR "NMake Makefiles JOM")
		else()
			set(CTEST_CMAKE_GENERATOR "Ninja")
		endif()
	else()
	   set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
	endif()
endif()

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
 	set(CTEST_SOURCE_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/SuperBuild/Packaging)
endif()
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


if(DEFINED ENV{CTEST_BINARY_DIRECTORY})
  file(TO_CMAKE_PATH "$ENV{CTEST_BINARY_DIRECTORY}" CTEST_BINARY_DIRECTORY)
endif()

# DEFAULT values for CTEST_BINARY_DIRECTORY if not defined
if(NOT DEFINED CTEST_BINARY_DIRECTORY)
  if(DEFINED dashboard_binary_name)
    set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name})
  else()
    if(DASHBOARD_SUPERBUILD)
      set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/build_sb_${COMPILER_ARCH})  
    elseif(DASHBOARD_PACKAGE_ONLY)
      set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/pkg_build_${COMPILER_ARCH})
    elseif(dashboard_remote_module)
      set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/remote_module_build_${COMPILER_ARCH})
    else()
      set(CTEST_BINARY_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/build_${COMPILER_ARCH})
    endif()
  endif()
endif()


if(DEFINED ENV{CTEST_INSTALL_DIRECTORY})
  file(TO_CMAKE_PATH "$ENV{CTEST_INSTALL_DIRECTORY}" CTEST_INSTALL_DIRECTORY)
endif()
# DEFAULT values for CTEST_INSTALL_DIRECTORY if not defined
if(NOT DEFINED CTEST_INSTALL_DIRECTORY)
  if(DASHBOARD_SUPERBUILD)
   set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/install_sb_${COMPILER_ARCH})
  elseif(DASHBOARD_PACKAGE_ONLY)
   set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/pkg_install_${COMPILER_ARCH})  
  elseif(dashboard_remote_module)
    set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/remote_module_install_${COMPILER_ARCH})
  else()
    set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/otb/install_${COMPILER_ARCH})
  endif()
endif()

# Choose the dashboard track
if(NOT DEFINED CTEST_DASHBOARD_TRACK)
  # Guess using the dashboard model
  if("${dashboard_model}" STREQUAL "Nightly")
    # Guess using the branch name
    if("${dashboard_otb_branch}" STREQUAL "master")
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
  # RemoteModules
  if(DEFINED dashboard_remote_module)
    set(CTEST_TEST_ARGS INCLUDE_LABEL ${dashboard_remote_module})
    set(CTEST_DASHBOARD_TRACK RemoteModules)
  endif()
endif()

#-----------------------------------------------------------------------------

# Send the main script as a note.
list(APPEND CTEST_NOTES_FILES
  "${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}"
  "${CMAKE_CURRENT_LIST_FILE}"
  )

  
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Creation of DEFAULT_CMAKE_CACHE starts here. That means all 
# common variables are set.
 set(DEFAULT_CMAKE_CACHE
	"BUILD_TESTING:BOOL=ON
	CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}
  "
	)

if(DASHBOARD_SUPERBUILD)
	list(APPEND CTEST_TEST_ARGS BUILD ${CTEST_BINARY_DIRECTORY}/OTB/build)

	if(DOWNLOAD_LOCATION)
		set(DEFAULT_CMAKE_CACHE "${DEFAULT_CMAKE_CACHE}
			DOWNLOAD_LOCATION:PATH=${DOWNLOAD_LOCATION}")
	endif()

else()

	if(XDK_INSTALL_DIR)
		set(DEFAULT_CMAKE_CACHE "
		${DEFAULT_CMAKE_CACHE}
    QT_BINARY_DIR:PATH=${XDK_INSTALL_DIR}/bin
		QT_INSTALL_TRANSLATIONS:PATH=${XDK_INSTALL_DIR}/translations
		QT_MOC_EXECUTABLE:FILEPATH=${XDK_INSTALL_DIR}/bin/moc
		QT_UIC_EXECUTABLE:FILEPATH=${XDK_INSTALL_DIR}/bin/uic
		QT_RCC_EXECUTABLE:FILEPATH=${XDK_INSTALL_DIR}/bin/rcc
		QT_INSTALL_PLUGINS:PATH=${XDK_INSTALL_DIR}/plugins
		QT_INSTALL_HEADERS:PATH=${XDK_INSTALL_DIR}/include
		QMAKE_MKSPECS:PATH=${XDK_INSTALL_DIR}/mkspecs"
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
  set(DEFAULT_CMAKE_CACHE 
  "
  ${DEFAULT_CMAKE_CACHE}
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
SUPERBUILD_BINARY_DIR:PATH=C:/dashboard/otb/superbuild_${COMPILER_ARCH}
SUPERBUILD_INSTALL_DIR:PATH=C:/dashboard/otb/install_sb_${COMPILER_ARCH}
OTB_WRAP_PYTHON:BOOL=ON
${dashboard_cache_packaging}
${dashboard_cache_for_${dashboard_otb_branch}}
GENERATE_PACKAGE:BOOL=${DASHBOARD_PACKAGE_OTB}
GENERATE_XDK:BOOL=${DASHBOARD_PACKAGE_XDK}
")
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
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION})
${cache_make_program}
${dashboard_cache}
${DEFAULT_CMAKE_CACHE}
${dashboard_cache_for_${dashboard_otb_branch}}
")
endmacro(write_cache)

# Start with a fresh build tree.
if(NOT dashboard_no_clean)
	if(EXISTS "${CTEST_BINARY_DIRECTORY}")
		message("Clearing build tree: ${CTEST_BINARY_DIRECTORY}")
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_BINARY_DIRECTORY})
	endif()

	if(EXISTS "${CTEST_INSTALL_DIRECTORY}")
		message("Clearing install tree: ${CTEST_INSTALL_DIRECTORY}")
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
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
macro(do_submit)
  ctest_submit()
  return()
endmacro()

 execute_process(COMMAND ${CMAKE_COMMAND} 
  -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} 
  -D TESTED_BRANCH:STRING=${dashboard_data_branch} 
  -P ${_git_updater_script}
  WORKING_DIRECTORY ${OTB_DATA_ROOT})
  
 
if(COMMAND dashboard_hook_start)
   dashboard_hook_start()
endif()
  
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
	DOWNLOAD_LOCATION
	CMAKE_PREFIX_PATH
	XDK_INSTALL_DIR
	CTEST_DROP_LOCATION
  dashboard_otb_branch
  dashboard_data_branch
  dashboard_update_dir
    )
  set(vars "${vars}  ${v}=[${${v}}]\n")
endforeach(v)
message("Dashboard script configuration:\n${vars}\n")

if(COMMAND dashboard_hook_init)
  dashboard_hook_init()
endif()
  
  ctest_start(${dashboard_model} TRACK ${CTEST_DASHBOARD_TRACK})
  
  write_cache()

  # Look for updates.
  if(NOT dashboard_no_update)
    ctest_update(SOURCE ${dashboard_update_dir} RETURN_VALUE count)
    set(CTEST_CHECKOUT_COMMAND) # checkout on first iteration only
    safe_message("Found ${count} changed files")
  else()
    safe_message("dashboard_no_update is set. skipping update sources")
  endif()
  
  # add specific modules (works for OTB only)
  if(DEFINED dashboard_remote_module AND DEFINED dashboard_remote_module_url)
    execute_process(COMMAND "${CTEST_GIT_COMMAND}" "clone" "${dashboard_remote_module_url}"  "${dashboard_update_dir}/Modules/Remote/${dashboard_remote_module}" RESULT_VARIABLE rv)
    if(NOT rv EQUAL 0)
      message(FATAL_ERROR "Cannot checkout remote module: ${rv}")
    endif()
  endif()

  if(dashboard_fresh OR NOT dashboard_continuous OR count GREATER 0)
    
	if(NOT dashboard_no_configure)
    safe_message("Running ctest_configure() on ${CTEST_BINARY_DIRECTORY}")
		ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}" 	RETURN_VALUE _configure_rv)
		ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})

		if(NOT _configure_rv EQUAL 0)
			do_submit()
		endif()
	endif()

    if(COMMAND dashboard_hook_build)
      dashboard_hook_build()
    endif()
	  
	if(dashboard_build_target)
    message("building requested target ${dashboard_build_target} on ${CTEST_BINARY_DIRECTORY}")
	  ctest_build( BUILD "${CTEST_BINARY_DIRECTORY}" 
	              TARGET "${dashboard_build_target}"
				  RETURN_VALUE _build_rv)
	else()
	  ctest_build( BUILD "${CTEST_BINARY_DIRECTORY}" RETURN_VALUE _build_rv)
	endif()
	
    if(NOT dashboard_no_test)
      if(COMMAND dashboard_hook_test)
        dashboard_hook_test()
      endif()
    
    if(dashboard_label)
	   list(APPEND CTEST_TEST_ARGS INCLUDE_LABEL ${dashboard_label})
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
		do_submit()
    endif()
    if(COMMAND dashboard_hook_end)
      dashboard_hook_end()
    endif()
  endif()

 execute_process(COMMAND ${CMAKE_COMMAND} 
  -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} 
  -D TESTED_BRANCH:STRING=nightly
  -P ${_git_updater_script}
  WORKING_DIRECTORY ${OTB_DATA_ROOT})
  
ctest_sleep(5)

if(DEFINED dashboard_remote_module AND DEFINED dashboard_remote_module_url)
  file(REMOVE_RECURSE "${dashboard_update_dir}/Modules/Remote/${dashboard_remote_module}")
endif()

