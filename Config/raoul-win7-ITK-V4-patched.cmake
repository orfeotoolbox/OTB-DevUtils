SET (ENV{DISPLAY} ":0.0")
 
SET (CTEST_SOURCE_DIRECTORY "C:/Users/jmalik/Dashboard/tools/src/ITK") 
SET (CTEST_BINARY_DIRECTORY "C:/Users/jmalik/Dashboard/tools/build/ITK-V4")

# path to the OTB-NewStatistics patch (otb-itkv4 branch)
# be sure that the script launching this configuration file 
# update OTB-SandBox directory first to work with the last patch
SET(OTB_PATCH_PATH "C:/Users/jmalik/Dashboard/src/OTB-SandBox/Patch/itkv4_patch.diff")

# cmake and git commands
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe" )
SET (CTEST_GIT_COMMAND "C:/Program Files (x86)/Git/bin/git.exe")

# Project variables
SET (CTEST_CMAKE_GENERATOR  "Visual Studio 9 2008" )
SET (CTEST_SITE "raoul.c-s.fr" )
SET (CTEST_BUILD_NAME "ITKV4-patched")
SET (CTEST_BUILD_CONFIGURATION "Release")

SET (ITK_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=OFF
ITK_USE_REVIEW:BOOL=ON 
")

SET( ITK_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/pull_result.txt" )
SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${ITK_RESULT_FILE}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start(Nightly)
#ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${ITK_INITIAL_CACHE})

# clean the directory : remove the non tracked files if any
execute_process( COMMAND ${CTEST_GIT_COMMAND} clean -f
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}" 
                 OUTPUT_VARIABLE   CLEAN_STATUS
                 ERROR_VARIABLE    CLEAN_STATUS
                 )
execute_process( COMMAND ${CTEST_GIT_COMMAND} checkout a65ced9240312bd1117abff330139247fc7c94eb
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}" 
                 OUTPUT_VARIABLE   CHECKOUT_STATUS
                 ERROR_VARIABLE    CHECKOUT_STATUS
                 )
                 
# Apply the patch after updating the repository
# print the changes added with the patch
execute_process( COMMAND ${CTEST_GIT_COMMAND} apply --stat ${OTB_PATCH_PATH}
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}" 
                 OUTPUT_VARIABLE   PATCH_STATUS
                 ERROR_VARIABLE    PATCH_STATUS
                 )

# apply the patch
execute_process( COMMAND ${CTEST_GIT_COMMAND} apply  ${OTB_PATCH_PATH}
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}" 
                 OUTPUT_VARIABLE   APPLY_PATCH_STATUS
                 ERROR_VARIABLE    APPLY_PATCH_STATUS
                 )
file(WRITE ${ITK_RESULT_FILE} ${CLEAN_STATUS} ${CHECKOUT_STATUS} ${PATCH_STATUS} ${APPLY_PATCH_STATUS} )

ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")

