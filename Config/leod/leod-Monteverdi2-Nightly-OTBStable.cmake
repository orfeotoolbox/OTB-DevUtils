SET (ENV{DISPLAY} ":0")

SET (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/Dashboard/nightly/Monteverdi2-Release-OTBStable/src")
SET (CTEST_BINARY_DIRECTORY "$ENV{HOME}/Dashboard/nightly/Monteverdi2-Release-OTBStable/build")

SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k" )
SET (CTEST_SITE "leod.c-s.fr")
SET (CTEST_BUILD_NAME "MacOSX10.8-Release-OTBStable")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "/opt/local/bin/hg")
SET (CTEST_HG_UPDATE_OPTIONS "-C")
SET (CTEST_USE_LAUNCHERS ON)

SET (CTEST_INITIAL_CACHE "

BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

CMAKE_LIBRARY_PATH:PATH=/opt/local/lib
CMAKE_INCLUDE_PATH:PATH=/opt/local/include

BUILD_SHARED_LIBS:BOOL=OFF
CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=$ENV{HOME}/Dashboard/nightly/Monteverdi2-Release-OTBStable/install

#OTB_DATA_USE_LARGEINPUT:BOOL=ON
#OTB_DATA_LARGEINPUT_ROOT:STRING=/Users/otbval/Data/OTB-LargeInput
#OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -Wno-gnu -Wno-overloaded-virtual
#CMAKE_OSX_ARCHITECTURES:STRING=i386

OTB_DIR:STRING=$ENV{HOME}/Dashboard/stable/OTB-Release-stable/build

Monteverdi2_USE_CPACK:BOOL=ON
")


SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})
ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}" TARGET package)
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()

