SET (ENV{DISPLAY} ":0.0")
 
SET (CTEST_SOURCE_DIRECTORY "C:/Users/jmalik/Dashboard/tools/src/ITK") 
SET (CTEST_BINARY_DIRECTORY "C:/Users/jmalik/Dashboard/tools/build/ITK-V4")

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
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
ITK_BUILD_ALL_MODULES:BOOL=ON
Module_ITK-Review:BOOL=ON
ITK_USE_REVIEW:BOOL=ON
BUILD_SHARED_LIBS:BOOL=OFF
")

SET( ITK_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/log.txt" )

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${ITK_RESULT_FILE}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

# remove the src directory
execute_process( COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_SOURCE_DIRECTORY}
                 OUTPUT_VARIABLE   CLEAN_STATUS
                 ERROR_VARIABLE    CLEAN_STATUS )
file(WRITE ${ITK_RESULT_FILE} ${CLEAN_STATUS})

# fresh git clone
execute_process( COMMAND ${CTEST_GIT_COMMAND} clone -n -- https://github.com/julienmalik/ITK.git  ${CTEST_SOURCE_DIRECTORY}
                 OUTPUT_VARIABLE CLONE_STATUS
                 ERROR_VARIABLE  CLONE_STATUS )
file(APPEND ${ITK_RESULT_FILE} ${CLONE_STATUS})

execute_process( COMMAND ${CTEST_GIT_COMMAND} checkout -b WarpImageFilterForVectorImage origin/WarpImageFilterForVectorImage
                 WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}
                 OUTPUT_VARIABLE CLONE_STATUS
                 ERROR_VARIABLE  CLONE_STATUS )
file(APPEND ${ITK_RESULT_FILE} ${CLONE_STATUS})

execute_process( COMMAND ${CTEST_GIT_COMMAND} submodule init
                 WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}
                 OUTPUT_VARIABLE CLONE_STATUS
                 ERROR_VARIABLE  CLONE_STATUS )
file(APPEND ${ITK_RESULT_FILE} ${CLONE_STATUS})

execute_process( COMMAND ${CTEST_GIT_COMMAND} submodule update --
                 WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}
                 OUTPUT_VARIABLE CLONE_STATUS
                 ERROR_VARIABLE  CLONE_STATUS )
file(APPEND ${ITK_RESULT_FILE} ${CLONE_STATUS})

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})
ctest_start(Experimental)
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${ITK_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit()
