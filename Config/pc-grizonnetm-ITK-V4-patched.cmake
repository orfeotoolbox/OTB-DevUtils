SET (ENV{DISPLAY} ":101")
 
SET (CTEST_SOURCE_DIRECTORY "/home/otbtesting/Dashboards/My\ Tests/ITK") 
SET (CTEST_BINARY_DIRECTORY "/home/otbtesting/Dashboards/My\ Tests/ITK-patched-build")

# path to the OTB-NewStatistics patch (otb-itkv4 branch)
# be sure that the script launching this configuration file 
# update OTB-SandBox directory first to work with the last patch
SET(OTB_PATCH_PATH "/mnt/dd-2/OTB/trunk/OTB-SandBox/Patch/itkv4_modular_patch.diff")



# cmake and git commands
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "make -j6" )
SET (CTEST_GIT_COMMAND "/usr/bin/git")

# Project variables
SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_SITE "pc-grizonnetm" )
SET (CTEST_BUILD_NAME "ITKV4-patched")
SET (CTEST_BUILD_CONFIGURATION "Release")


SET (ITK_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=OFF
ITK_BUILD_ALL_MODULES:BOOL=ON
Module_ITK-Review:BOOL=ON
ITK_USE_REVIEW:BOOL=ON
")

SET( ITK_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/pull_result.txt" )
SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${ITK_RESULT_FILE}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

# remove the src directory
execute_process( COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_SOURCE_DIRECTORY}
                 WORKING_DIRECTORY "" 
                 OUTPUT_VARIABLE   CLEAN_STATUS
                 ERROR_VARIABLE    CLEAN_STATUS )

execute_process( COMMAND ${CTEST_GIT_COMMAND} clone -n -b OTB_ITKv4 -- "https://github.com/julienmalik/ITK.git"  ${CTEST_SOURCE_DIRECTORY}
                 OUTPUT_VARIABLE CLONE_STATUS
                 ERROR_VARIABLE  CLONE_STATUS )

execute_process( COMMAND ${CTEST_GIT_COMMAND} checkout
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}" 
                 OUTPUT_VARIABLE   CHECKOUT_STATUS
                 ERROR_VARIABLE    CHECKOUT_STATUS )

file(WRITE ${ITK_RESULT_FILE} ${CLEAN_STATUS} ${CLONE_STATUS} ${CHECKOUT_STATUS} )

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})
ctest_start(Experimental)
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${ITK_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
