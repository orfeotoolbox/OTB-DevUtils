#SET (ENV{DISPLAY} ":0.0")

#SET (dashboard_model Nightly)
SET (CTEST_DASHBOARD_ROOT "/home/otbtesting")

SET (CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/Monteverdi-Nightly/")
SET (CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/Monteverdi-Nightly/")
SET (CTEST_BUILD_CONFIGURATION Release)
SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k" )
SET (CTEST_SITE "pc-christophe.cst.cnes.fr" )
SET (CTEST_BUILD_NAME "Fedora20-64bits-${CTEST_BUILD_CONFIGURATION}")
SET (CTEST_HG_COMMAND "/usr/bin/hg")
SET (CTEST_HG_UPDATE_OPTIONS "-C")
SET (CTEST_USE_LAUNCHERS ON)

# should ctest wipe the binary tree before running
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)

# this is the initial cache to use for the binary tree, be careful to escape
# any quotes inside of this string if you use it
SET (CTEST_INITIAL_CACHE "
// Use Launchers for CDash reporting
CTEST_USE_LAUNCHERS:BOOL=ON
//Name of the build
BUILDNAME:STRING=${CTEST_BUILD_NAME}
//Name of the computer/site where compile is being run
SITE:STRING=${CTEST_SITE}
//LargeInput
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput
//Data root
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-Data
//Compilation options
CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-cpp
//Set up the build options
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
BUILD_TESTING:BOOL=ON
OTB_DIR:PATH=${INSTALLROOT}/orfeo/trunk/OTB-Nightly/Release
ITK_DIR:PATH=${INSTALLROOT}/itk/stable/Release/lib/cmake/ITK-4.6
")

SET( OTB_PULL_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/pull_result.txt" )

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${OTB_PULL_RESULT_FILE}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

execute_process( COMMAND ${CTEST_HG_COMMAND} pull http://hg.orfeo-toolbox.org/Monteverdi-Nightly
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
                 OUTPUT_VARIABLE   OTB_PULL_RESULT
                 ERROR_VARIABLE    OTB_PULL_RESULT )
file(WRITE ${OTB_PULL_RESULT_FILE} ${OTB_PULL_RESULT} )

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
