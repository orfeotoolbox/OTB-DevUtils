SET(ENV{DISPLAY} ":0.0")
SET(ENV{TSOCKS_CONF_FILE} "/home2/otbval/.tsocks.conf")

SET (CTEST_SOURCE_DIRECTORY "/home2/otbval/OTB-OUTILS/itk-v4/src/ITK/") 
SET (CTEST_BINARY_DIRECTORY "/home2/otbval/OTB-OUTILS/itk-v4/build/ITK")

# cmake and git commands
SET (CTEST_CMAKE_COMMAND "/ORFEO/otbval/OTB-OUTILS/cmake/2.8.2/install/bin/cmake" )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k" )
SET (CTEST_GIT_COMMAND "/usr/bin/git")

find_program(CTEST_TSOCKS_COMMAND NAMES tsocks)

# Project variables
SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_SITE "dora.c-s.fr" )
SET (CTEST_BUILD_NAME "ITKV4-patched")
SET (CTEST_BUILD_CONFIGURATION "Release")


SET (ITK_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
CMAKE_BUILD_TYPE:STRING=Release
BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
ITK_USE_CONCEPT_CHECKING:BOOL=ON
ITK_BUILD_ALL_MODULES:BOOL=ON
Module_ITK-Review:BOOL=ON
ITK_USE_REVIEW:BOOL=ON
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wextra
CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wextra
")


ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

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
execute_process( COMMAND ${CTEST_TSOCKS_COMMAND} ${CTEST_GIT_COMMAND} clone -b WarpImageFilterForVectorImage git://github.com/julienmalik/ITK.git ${CTEST_SOURCE_DIRECTORY}
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

ctest_start(Experimental)
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${ITK_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit()

