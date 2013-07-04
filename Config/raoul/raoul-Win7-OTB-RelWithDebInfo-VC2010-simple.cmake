SET (CTEST_SOURCE_DIRECTORY "C:/Users/jmalik/Dashboard/src/OTB")
SET (CTEST_BINARY_DIRECTORY "C:/Users/jmalik/Dashboard/build/OTB-RelWithDebInfo-VC2010-simple")

SET (CTEST_CMAKE_GENERATOR  "Visual Studio 10" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "raoul.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-Visual2010-RelWithDebInfo-Static-simple")
SET (CTEST_BUILD_CONFIGURATION "RelWithDebInfo")
SET (CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CMAKE_INSTALL_PREFIX:PATH=C:/Users/jmalik/Dashboard/install/OTB-RelWithDebInfo-VC2010-simple

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

OTB_DATA_ROOT:STRING=C:/Users/jmalik/Dashboard/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
#OTB_DATA_LARGEINPUT_ROOT:PATH=C:/Users/jmalik/Dashboard/src/OTB-LargeInput

")

#remove build dir
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
