# TODO: update devutils based on option from nightly.bat
set(UPDATE_DEVUTILS ON)

set(LOGS_DIR "C:/dashboard/logs")
set(DEVUTILS_DIR "C:/dashboard/devutils")
set(SCRIPTS_DIR "C:/dashboard/devutils/Config/windows")

if(NOT DEFINED COMPILER_ARCH)
  message(FATAL_ERROR "COMPILER_ARCH not defined")
endif()

string(TIMESTAMP DATE_TIME)
set(_git_updater_script "${DEVUTILS_DIR}/Config/git_updater.cmake")
set(GIT_COMMAND git)

if(UPDATE_DEVUTILS)
message("${DATE_TIME}: Update OTB-DevUtils")
execute_process(COMMAND ${CMAKE_COMMAND} 
  -D GIT_COMMAND:PATH=${GIT_COMMAND} 
  -D TESTED_BRANCH:STRING=master 
  -P ${_git_updater_script}
  OUTPUT_FILE ${LOGS_DIR}/devutils.txt
  WORKING_DIRECTORY ${DEVUTILS_DIR})
endif()
message("${DATE_TIME}: compiler arch set to '${COMPILER_ARCH}'")  

foreach(dashboard_remote_module "SertitObject" "Mosaic" "otbGRM")
message("${DATE_TIME}: Bulding remote module ${dashboard_remote_module}")
  execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
  ${COMPILER_ARCH} 0 BUILD nightly nightly ${dashboard_remote_module}
  OUTPUT_FILE ${LOGS_DIR}/nightly_${COMPILER_ARCH}_nightly_${dashboard_remote_module}.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})
endforeach()

# SuperBuild
execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
   x64 0 SUPER_BUILD packaging_fixes master
  OUTPUT_FILE ${LOGS_DIR}/superbuild_x64.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})
  
execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
   x64 0 PACKAGE_OTB packaging_fixes master
  OUTPUT_FILE ${LOGS_DIR}/package_otb_x64.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})

execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
   x86 0 SUPER_BUILD packaging_fixes master
  OUTPUT_FILE ${LOGS_DIR}/superbuild_x86.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})

execute_process(COMMAND ${SCRIPTS_DIR}/dashboard.bat 
   x86 0 PACKAGE_OTB packaging_fixes master
  OUTPUT_FILE ${LOGS_DIR}/package_otb_x86.txt
  WORKING_DIRECTORY ${SCRIPTS_DIR})

  
set(FEATURE_BRANCHES_FILE "${DEVUTILS_DIR}/Config/feature_branches.txt")

message("Checking feature branches file : ${FEATURE_BRANCHES_FILE}")
file(STRINGS ${FEATURE_BRANCHES_FILE} FEATURE_BRANCHES_FILE_CONTENTS
REGEX "^ *([a-zA-Z0-9]|-|_|\\.)+ *([a-zA-Z0-9]|-|_|\\.)* *\$")

set(LIST_OF_BRANCHES)
list(APPEND LIST_OF_BRANCHES "nightly nightly")
list(APPEND LIST_OF_BRANCHES "release-5.8 release-5.8")
list(APPEND LIST_OF_BRANCHES ${FEATURE_BRANCHES_FILE_CONTENTS})

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
  WORKING_DIRECTORY ${SCRIPTS_DIR})
  
endforeach()


#set(ctest_files "${SCRIPTS_DIR}/SertitObject-VC2015.cmake" )
