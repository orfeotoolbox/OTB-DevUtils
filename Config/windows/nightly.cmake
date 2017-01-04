# TODO: update devutils based on option from nightly.bat
set(UPDATE_DEVUTILS ON)

set(LOGS_DIR "C:/dashboard/logs")

#unmount and mount otbnas on R drive 
execute_process(COMMAND "net" "use" "R:" "/delete" "/Y")
execute_process(COMMAND "net" "use" "R:" "\\\\otbnas.si.c-s.fr\\otbdata\\otb"  "/persistent:no")

set(ENV{EXIT_PROMPT} "1")

#find devutils/Config directory relative to this file (nightly.cmake)
get_filename_component(DEVUTILS_CONFIG_DIR "${CMAKE_CURRENT_LIST_DIR}" PATH)

#scripts_dir is a convenience variable for CMAKE_CURRENT_LIST_DIR. 
set(SCRIPTS_DIR "${CMAKE_CURRENT_LIST_DIR}")

#we can only build on branch of superbuild. Latest release or nightly
set(SUPERBUILD_BRANCH nightly)
set(SUPERBUILD_DATA_BRANCH master)

# handle SuperBuild branch
message("Checking branches file : ${DEVUTILS_CONFIG_DIR}/superbuild_branch.txt")
if(EXISTS ${DEVUTILS_CONFIG_DIR}/superbuild_branch.txt)
  file(STRINGS ${DEVUTILS_CONFIG_DIR}/superbuild_branch.txt
    _superbuild_branch_content REGEX "^ *([a-zA-Z0-9]|-|_|\\.)+ *\$")
  if(_superbuild_branch_content)
    list(GET _superbuild_branch_content 0 SUPERBUILD_BRANCH)
  endif()
endif()

message("SUPERBUILD_BRANCH=${SUPERBUILD_BRANCH}")
message("SUPERBUILD_DATA_BRANCH=${SUPERBUILD_DATA_BRANCH}")

set(LIST_OF_BRANCHES)
list(APPEND LIST_OF_BRANCHES "nightly nightly")
list(APPEND LIST_OF_BRANCHES "release-5.8 release-5.8")

# LIST_OF_BRANCHES is updated with contents from feature_branches.txt

#CAREFUL when you update code below.
if(NOT DEFINED COMPILER_ARCH)
  message(FATAL_ERROR "COMPILER_ARCH not defined")
endif()

string(TIMESTAMP DATE_TIME)
set(_git_updater_script "${DEVUTILS_CONFIG_DIR}/git_updater.cmake")
set(GIT_COMMAND git)

if(UPDATE_DEVUTILS)
message("${DATE_TIME}: Update OTB-DevUtils")
execute_process(COMMAND ${CMAKE_COMMAND} 
  -D GIT_COMMAND:PATH=${GIT_COMMAND} 
  -D TESTED_BRANCH:STRING=master 
  -P ${_git_updater_script}
  OUTPUT_FILE ${LOGS_DIR}/devutils.txt
  ERROR_FILE ${LOGS_DIR}/devutils.txt
  WORKING_DIRECTORY ${DEVUTILS_CONFIG_DIR})
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
   OUTPUT_FILE ${LOGS_DIR}/superbuild_${SUPERBUILD_BRANCH}_${COMPILER_ARCH}.txt
   ERROR_FILE ${LOGS_DIR}/superbuild_${SUPERBUILD_BRANCH}_${COMPILER_ARCH}.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})

# Packaging  
execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
   ${COMPILER_ARCH} 0 PACKAGE_OTB ${SUPERBUILD_BRANCH} ${SUPERBUILD_DATA_BRANCH}
   OUTPUT_FILE ${LOGS_DIR}/package_otb_${SUPERBUILD_BRANCH}_${COMPILER_ARCH}.txt
   ERROR_FILE ${LOGS_DIR}/package_otb_${SUPERBUILD_BRANCH}_${COMPILER_ARCH}.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})

# nightly latest release + Feature Branches
set(FEATURE_BRANCHES_FILE "${DEVUTILS_CONFIG_DIR}/feature_branches.txt")

message("Checking feature branches file : ${FEATURE_BRANCHES_FILE}")
file(STRINGS ${FEATURE_BRANCHES_FILE} FEATURE_BRANCHES_FILE_CONTENTS
REGEX "^ *([a-zA-Z0-9]|-|_|\\.)+ *([a-zA-Z0-9]|-|_|\\.)* *\$")

list(APPEND LIST_OF_BRANCHES ${FEATURE_BRANCHES_FILE_CONTENTS})
list(REVERSE LIST_OF_BRANCHES)


foreach(branch_input ${LIST_OF_BRANCHES})
  set(otb_branch)
  set(data_branch)
  string(REGEX REPLACE 
  "^ *(([a-zA-Z0-9]|-|_|\\.)+) *(([a-zA-Z0-9]|-|_|\\.)*) *\$" "\\1" otb_branch ${branch_input})
 string(REGEX REPLACE 
 "^ *(([a-zA-Z0-9]|-|_|\\.)+) *(([a-zA-Z0-9]|-|_|\\.)*) *\$" "\\3" data_branch ${branch_input})
 
  if(NOT data_branch)
    set(data_branch "nightly")
  endif()
  
  string(STRIP ${data_branch} data_branch)
  string(STRIP ${otb_branch} otb_branch)
  
  message("${DATE_TIME}: Bulding otb branch '${otb_branch}' with data branch '${data_branch}'")
  message("${DATE_TIME}: Output will be logged on ${LOGS_DIR}/${otb_branch}_${COMPILER_ARCH}_${data_branch}.txt")
  execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
  ${COMPILER_ARCH} 0 BUILD ${otb_branch} ${data_branch}
  OUTPUT_FILE ${LOGS_DIR}/${otb_branch}_${COMPILER_ARCH}_${data_branch}.txt
  ERROR_FILE ${LOGS_DIR}/${otb_branch}_${COMPILER_ARCH}_${data_branch}.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})
  
endforeach()


#make sure otbnas is disconnected at end in case a build is broken
execute_process(COMMAND "net" "use" "R:" "/delete" "/Y")
