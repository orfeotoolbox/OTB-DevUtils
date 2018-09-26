# Are we in a release preparation ? if yes, superbuild and packaging will use the latest release branch
set(RELEASE_PREPARATION OFF)

set(LOGS_DIR "C:/dashboard/logs")

string(TIMESTAMP DATE_TIME)

#find devutils/Config directory relative to this file (nightly.cmake)
get_filename_component(DEVUTILS_CONFIG_DIR "${CMAKE_CURRENT_LIST_DIR}" PATH)

# macro common
include("${DEVUTILS_CONFIG_DIR}/macro_common.cmake")

#unmount and mount otbnas on R drive
execute_process(COMMAND "net" "use" "R:" "/delete" "/Y")
execute_process(COMMAND "net" "use" "R:" "\\\\otbnas.si.c-s.fr\\otbdata\\otb"  "/persistent:no")

#scripts_dir is a convenience variable for CMAKE_CURRENT_LIST_DIR. 
set(SCRIPTS_DIR "${CMAKE_CURRENT_LIST_DIR}")

include("${DEVUTILS_CONFIG_DIR}/config_stable.cmake")
if(NOT OTB_STABLE_VERSION)
  message(FATAL_ERROR "OTB_STABLE_VERSION is not set")
endif()
set(OTB_STABLE_BRANCH ${dashboard_git_branch})

# Input file where SuperBuild branch name is set
set(SUPERBUILD_BRANCH)
set(SUPERBUILD_DATA_BRANCH)
if(RELEASE_PREPARATION)
  set(SUPERBUILD_BRANCH "release-${OTB_STABLE_VERSION}")
  set(SUPERBUILD_DATA_BRANCH "release-${OTB_STABLE_VERSION}")
else()
  set(sb_file "${DEVUTILS_CONFIG_DIR}/superbuild_branch.txt")
  if(EXISTS ${sb_file})
    message("reading superbuild branch name from : ${sb_file}")
    parse_branch_list(${sb_file})
    list(GET _branch_list 0 SUPERBUILD_BRANCH)
    set(SUPERBUILD_DATA_BRANCH ${specific_data_branch_for_${SUPERBUILD_BRANCH}})
  endif()
endif()

if(NOT SUPERBUILD_DATA_BRANCH)
  set(SUPERBUILD_DATA_BRANCH nightly)
endif()

if(NOT SUPERBUILD_BRANCH)
  set(SUPERBUILD_BRANCH nightly)
endif()

convert_branch_to_filename(${SUPERBUILD_BRANCH} SUPERBUILD_BRANCH_OK)

message("SUPERBUILD_BRANCH=${SUPERBUILD_BRANCH}")
message("SUPERBUILD_DATA_BRANCH=${SUPERBUILD_DATA_BRANCH}")

set(LIST_OF_BRANCHES)
list(APPEND LIST_OF_BRANCHES nightly ${OTB_STABLE_BRANCH})

# LIST_OF_BRANCHES is updated with contents from feature_branches.txt

#CAREFUL when you update code below.
if(NOT DEFINED COMPILER_ARCH)
  message(FATAL_ERROR "COMPILER_ARCH not defined")
endif()

message("${DATE_TIME}: compiler arch set to '${COMPILER_ARCH}'")  

string(TIMESTAMP BUILD_START_DATE "%Y-%m-%d")
set(OTBNAS_PACKAGES_DIR "R:/Nightly/${BUILD_START_DATE}")

if(NOT EXISTS "${OTBNAS_PACKAGES_DIR}")
execute_process(COMMAND 
${CMAKE_COMMAND} -E make_directory ${OTBNAS_PACKAGES_DIR}
WORKING_DIRECTORY ${LOGS_DIR})
endif()

set(ENV{OTBNAS_PACKAGES_DIR} "${OTBNAS_PACKAGES_DIR}")

# RemoteModules
#foreach(dashboard_remote_module "SertitObject" "Mosaic" "otbGRM" "OTBFFSforGMM")
foreach(dashboard_remote_module "SertitObject" "Mosaic" "otbGRM" "OTBFFSforGMM")
message("${DATE_TIME}: Bulding remote module ${dashboard_remote_module}")
  execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
  ${COMPILER_ARCH} 0 BUILD nightly nightly ${dashboard_remote_module}
  OUTPUT_FILE ${LOGS_DIR}/nightly_${COMPILER_ARCH}_nightly_${dashboard_remote_module}.txt
  ERROR_FILE ${LOGS_DIR}/nightly_${COMPILER_ARCH}_nightly_${dashboard_remote_module}.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})
endforeach()

# SuperBuild
execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
   ${COMPILER_ARCH} 0 SUPER_BUILD ${SUPERBUILD_BRANCH} ${SUPERBUILD_DATA_BRANCH}
   OUTPUT_FILE ${LOGS_DIR}/superbuild_${SUPERBUILD_BRANCH_OK}_${COMPILER_ARCH}.txt
   ERROR_FILE ${LOGS_DIR}/superbuild_${SUPERBUILD_BRANCH_OK}_${COMPILER_ARCH}.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})

# Packaging  
execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
   ${COMPILER_ARCH} 0 PKG ${SUPERBUILD_BRANCH} ${SUPERBUILD_DATA_BRANCH}
   OUTPUT_FILE ${LOGS_DIR}/package_otb_${SUPERBUILD_BRANCH_OK}_${COMPILER_ARCH}.txt
   ERROR_FILE ${LOGS_DIR}/package_otb_${SUPERBUILD_BRANCH_OK}_${COMPILER_ARCH}.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})

# nightly latest release + Feature Branches
set(FEATURE_BRANCHES_FILE "${DEVUTILS_CONFIG_DIR}/feature_branches.txt")

message("Checking feature branches file : ${FEATURE_BRANCHES_FILE}")
parse_branch_list(${FEATURE_BRANCHES_FILE})
list(APPEND LIST_OF_BRANCHES ${_branch_list})

foreach(otb_branch ${LIST_OF_BRANCHES})
  # find the corresponding data branch
  set(data_branch ${specific_data_branch_for_${otb_branch}})
  if(NOT data_branch)
    set(data_branch "nightly")
  endif()

  # convert branch names for filenames
  convert_branch_to_filename(${otb_branch} otb_branch_clean)
  convert_branch_to_filename(${data_branch} data_branch_clean)

  message("${DATE_TIME}: Bulding otb branch '${otb_branch}' with data branch '${data_branch}'")
  message("${DATE_TIME}: Output will be logged on ${LOGS_DIR}/${otb_branch_clean}_${COMPILER_ARCH}_${data_branch_clean}.txt")
  execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
  ${COMPILER_ARCH} 0 BUILD ${otb_branch} ${data_branch}
  OUTPUT_FILE ${LOGS_DIR}/${otb_branch_clean}_${COMPILER_ARCH}_${data_branch_clean}.txt
  ERROR_FILE ${LOGS_DIR}/${otb_branch_clean}_${COMPILER_ARCH}_${data_branch_clean}.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})
  
endforeach()

#make sure otbnas is disconnected at end in case a build is broken
execute_process(COMMAND "net" "use" "R:" "/delete" "/Y")
