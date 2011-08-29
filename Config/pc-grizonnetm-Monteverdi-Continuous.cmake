SET (CTEST_SOURCE_DIRECTORY "/mnt/dd-2/OTB/trunk/Continuous/Monteverdi/")
SET (CTEST_BINARY_DIRECTORY "/mnt/dd-2/OTB/Continuous/Monteverdi/")

SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k" )
SET (CTEST_SITE "pc-grizonnetm")
SET (CTEST_BUILD_NAME "Monteverdi-Ubuntu10.4-64bits-Release")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "/usr/bin/hg")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (ENV{DISPLAY} ":0")

SET (CTEST_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_LARGEINPUT_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data/LargeInput
OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data
CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
CMAKE_OSX_ARCHITECTURES:STRING=i386
CMAKE_BUILD_TYPE:STRING=Release
OTB_DIR:STRING=/mnt/dd-2/OTB/Continuous/OTB
BUILD_TESTING:BOOL=ON
")

SET( PULL_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/pull_result.txt" )

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${PULL_RESULT_FILE}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

execute_process( COMMAND ${CTEST_HG_COMMAND} pull http://hg.orfeo-toolbox.org/Monteverdi
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
                 OUTPUT_VARIABLE   PULL_RESULT
                 ERROR_VARIABLE    PULL_RESULT )
file(WRITE ${PULL_RESULT_FILE} ${PULL_RESULT} )

ctest_start(Continuous TRACK "Continuous Monteverdi")
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
