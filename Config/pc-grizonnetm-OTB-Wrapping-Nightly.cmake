SET (CTEST_SOURCE_DIRECTORY "/mnt/dd-2/OTB/trunk/OTB-Wrapping-Nightly/")
SET (CTEST_BINARY_DIRECTORY "/mnt/dd-2/OTB/OTB-Binary-Wrapping-Nightly/")

SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k" )
SET (CTEST_SITE "pc-grizonnetm.cst.cnes.fr")
SET (CTEST_BUILD_NAME "Ubuntu10.4-64bits-Release")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "/usr/bin/hg")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (CTEST_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput

CMAKE_C_COMPILER:FILEPATH=/usr/bin/gcc
CMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
CMAKE_BUILD_TYPE:STRING=Release

OTB_DIR:STRING=/mnt/dd-2/OTB/OTB-Binary-Nightly

BUILD_TESTING:BOOL=ON

CableSwig_DIR:STRING=/usr/lib/CableSwig
#SWIG_DIR:STRING=/home/otbtesting/local/swig-1.3.40-build/share/swig/1.3.40
SWIG_DIR:STRING=/usr/share/swig1.3/
#SWIG_EXECUTABLE:STRING=/home/otbtesting/local/swig-1.3.40-build/bin/swig
SWIG_EXECUTABLE:STRING=/usr/bin/swig
SWIG_VERSION:STRING=1.3.40
WRAP_ITK_DIMS:STRING=2
WRAP_ITK_JAVA:BOOL=ON 
WRAP_ITK_PYTHON:BOOL=ON 
")

SET( PULL_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/pull_result.txt" )

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${PULL_RESULT_FILE}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

execute_process( COMMAND ${CTEST_HG_COMMAND} pull http://hg.orfeo-toolbox.org/OTB-Wrapping
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
                 OUTPUT_VARIABLE   PULL_RESULT
                 ERROR_VARIABLE    PULL_RESULT )
file(WRITE ${PULL_RESULT_FILE} ${PULL_RESULT} )

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
